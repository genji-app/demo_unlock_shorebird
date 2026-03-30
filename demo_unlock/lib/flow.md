Hãy thực hiện những yêu cầu sau đây:
1. Tạo màn hình splash có loading.
2. Tạo màn hình mode fake.
3. Tạo màn hình mode betting.

2. Trong màn hình splash hãy handle những việc sau đây:

Step 1. Check key unlock ở local storage(sử dụng sharepreference) -> đã unlock thì mở mode betting, ngược lại thì mở mode app fake rồi chuyển qua step 2

Từ step 2 là chạy async với mode app fake chứ ko được block UI
Step 2. Check ngày unlock
- Mục đích: để ngăn chặn app request trong khâu review, tránh bị nghi ngờ
- Ngày unlock = ngày submit app + 3 ngày (ko tính cuối tuần). Nếu ngày unlock nằm ở thứ 7 hoặc chủ nhật thì + 2 ngày nữa.
- Nếu current date >= ngày unlock thì chuyển qua step 3.
- Ngược lại thì open màn hình mode fake.

Step 3. Get config
- rawgit config (chính)[https://raw.githubusercontent.com/dev-itto/configs/main/sun/config/sappv363.json]. Sử dụng ApiClient với link.

nếu có lỗi kết nối thì retry (max 3 lần, interval 3s), hết lượt retry thì hiển thị diloag báo lỗi và hỏi thử lại, user bấm nút OK retry tiếp, còn nếu cancel thì move sang màn hình mode fake.

Trong config chứa [api_domain] dùng cho step 4.

Step 4. Check unlock cmd
<!-- - Mục đích: check xem user đã vào landing page chưa, nếu vào rồi thì cho mở mode betting. Chưa vào thì vẫn ở mote app fake. Tránh trường hợp ai cũng mở được mode betting dẫn tới chết app (bị store quét) -->
- thực hiện call api url: [api_domain]/ca/res?command=[app-bundle-id](com.sun88.sport)
- api trả về status=0 là OK, move sang màn hình mode betting và lưu lại key ở local storage để lần sau mở app thì ko cần check unlock lại nữa.
- nếu có lỗi kết nối thì retry như step 3.

- Hãy Không viết tóm tắt, tài liệu, giải thích, giữ nguyên và follow rule tại .cursor/rules