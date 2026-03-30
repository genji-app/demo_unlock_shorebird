# Hướng dẫn đóng gói module Unlock + Shorebird

Tài liệu mô tả cách tách phần **unlock flow**, **network/config**, **Shorebird update**, và **splash có inject** thành một Flutter package dùng lại cho nhiều app. Không thay thế cấu hình Shorebird CLI (`shorebird.yaml`) hay signing từng app.

---

## 1. Mục tiêu

- Một package (ví dụ `unlock_shorebird_kit`) chứa logic và UI “khung” có thể tái sử dụng.
- App host chỉ cung cấp: màn **betting**, màn **fake**, và callback **khởi động lại app** sau patch.

---

## 2. Phạm vi nên đưa vào package

| Thư mục / file | Ghi chú |
|----------------|---------|
| `lib/flow/` | `unlock_flow_coordinator.dart`, `unlock_flow_config.dart`, `unlock_shorebird_launch_coordinator.dart` |
| `lib/models/` | `unlock_command_response.dart` + file generated (`.freezed.dart`, `.g.dart`) hoặc bỏ freezed, chỉ dùng `json_serializable` / hand-parse |
| `lib/network/` | `api_client.dart`, `config_loader.dart`, `plain_body_dio_transformer.dart` |
| `lib/shorebird/update/` | Bloc, state, event, `shorebird_restart_snackbar.dart`, `update.dart` (export) |
| `lib/screens/splash_mode_screen.dart` | Nhận `bettingScreenBuilder`, `fakeScreenBuilder`, `executeRestartWithFade` |

**Giữ lại ở app host (không đưa vào package):**

- `lib/core/restart_scope.dart` (phụ thuộc `terminate_restart`, có thể copy vào host hoặc tách package `app_restart` riêng).
- `lib/screens/betting_mode_screen.dart`, `fake_mode_screen.dart` và mọi màn hình/domain riêng sản phẩm.
- `main.dart`, theme, routing tổng thể.

---

## 3. Điều kiện đã đáp ứng trong repo hiện tại

- **`SplashModeScreen`**: builder betting/fake + `executeRestartWithFade` (`Future<bool> Function(BuildContext)` → thường [RestartScope.executeRestartApp]: fade rồi [TerminateRestart] full process).
- **`executeShowShorebirdRestartSnackbar`**: nhận cùng `executeRestartWithFade(context)` khi user bấm khởi động lại.
- Shorebird `restartRequired`: lần đầu chỉ gọi `executeRestartWithFade` (không snackbar); sau đó snackbar + cùng callback. Mọi đường restart có fade; [RestartScope.executeProcessRestartOnly] chỉ dùng nội bộ sau bước fade.

Tham chiếu tích hợp mẫu: `lib/main.dart`.

---

## 4. Các bước triển khai đóng gói

### Bước 1: Tạo package Flutter

```bash
flutter create --template=package unlock_shorebird_kit
```

Đặt tên package theo `pubspec.yaml` (ví dụ `unlock_shorebird_kit`). `publish_to: 'none'` nếu chỉ dùng nội bộ / Git.

### Bước 2: Sao chép mã nguồn

Copy các file/thư mục liệt kê ở mục 2 vào `unlock_shorebird_kit/lib/`, giữ cấu trúc con hợp lý (ví dụ `lib/src/flow/...` hoặc flat theo thói quen team).

### Bước 3: Sửa import

Thay toàn bộ `package:demo_unlock/...` bằng `package:unlock_shorebird_kit/...` (hoặc tên package bạn chọn).

Chạy:

```bash
dart analyze
```

### Bước 4: `pubspec.yaml` của package

Khai báo tối thiểu (phiên bản có thể chỉnh theo dự án):

```yaml
environment:
  sdk: ^3.10.0

dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  dio: ^5.7.0
  shared_preferences: ^2.5.3
  shorebird_code_push: ^2.0.5
  flutter_bloc: ^9.1.1
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.8.0
```

**Lưu ý:** Host cần gọi `TerminateRestart.instance.initialize()` trong `main` trước `runApp` (xem `lib/main.dart`). Package có thể chỉ nhận callback restart từ host. Trên **iOS**, thêm `CFBundleURLTypes` theo [README terminate_restart](https://pub.dev/packages/terminate_restart) (đã có mẫu trong `ios/Runner/Info.plist` của repo này).

### Bước 5: Phụ thuộc từ app host

**Path (mono-repo):**

```yaml
dependencies:
  unlock_shorebird_kit:
    path: ../unlock_shorebird_kit
```

**Git (private):**

```yaml
dependencies:
  unlock_shorebird_kit:
    git:
      url: git@github.com:org/unlock_shorebird_kit.git
      ref: main
```

### Bước 6: Tích hợp trong app

1. Bọc root bằng widget restart (ví dụ `RestartScope` như `lib/main.dart`).
2. `MaterialApp` `home` (hoặc route đầu) dùng `SplashModeScreen` với:

   - `bettingScreenBuilder` → widget màn chính sau unlock.
   - `fakeScreenBuilder` → widget “fake” / review.
   - `executeRestartWithFade` → thường là `RestartScope.executeRestartApp` (fade rồi `TerminateRestart` với `terminate: true`).

3. Cấu hình URL và ngày submit trong `UnlockFlowConfig` (hoặc override bằng fork / inject sau này nếu bạn mở rộng API).

---

## 5. Cấu hình từ xa

- **`UnlockFlowConfig.apiDomainConfigUrl`**: JSON chứa khóa `api_domain`.
- **`UnlockFlowConfig.bundleIdConfigUrl`**: JSON chứa khóa `bundleId` (ví dụ file `s88` trên GitHub).
- **`appSubmitDate`**: dùng cho bước kiểm tra ngày unlock trong coordinator.

Chi tiết nghiệp vụ từng bước: xem `lib/flow.md` (trong repo demo).

---

## 6. Shorebird và khởi động lại sau patch

- Mỗi app vẫn có **`shorebird.yaml`** và bản build/release riêng; package chỉ dùng `shorebird_code_push` trong code.
- Host nên dùng **full process restart** (`terminate_restart` qua `RestartScope`) để patch Dart/native được nạp; chỉ rebuild widget không đủ.
- Phần animation Android (fade activity) nếu có nằm ở project host (`android/...`), không nằm trong Dart package.

---

## 7. Checklist trước khi coi là “đóng gói xong”

- [ ] `dart analyze` sạch lỗi trên package và trên app host.
- [ ] Chạy app host: splash → fake/betting đúng kỳ vọng; retry mạng hoạt động.
- [ ] Sau patch Shorebird, snackbar gọi đúng `executeRestartWithFade` (có fade như lần đầu).
- [ ] Generated code (`*.g.dart`, `*.freezed.dart`) đã commit hoặc CI chạy `build_runner`.
- [ ] README package: 1 đoạn “Getting started” + ví dụ `SplashModeScreen(...)` giống `main.dart`.

---

## 8. Mở rộng sau (tùy chọn)

- Inject `UnlockFlowCoordinator` / `UnlockShorebirdLaunchCoordinator` qua constructor để test dễ hơn.
- Thay `UnlockFlowConfig` hằng số bằng class cấu hình truyền từ host.
- Tách `RestartScope` thành package nhỏ `flutter_app_restart` nếu nhiều app dùng chung.

---

*Tài liệu này mô tả quy trình; không thay thế việc đọc `pub.dev` / Shorebird docs khi publish hoặc lên store.*
