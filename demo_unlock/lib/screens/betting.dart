import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class BettingPage extends StatefulWidget {
  const BettingPage({super.key, required this.version});
  final String version;
  @override
  State<BettingPage> createState() => _BettingPageState();
}

class _BettingPageState extends State<BettingPage> {
  late final Future<PackageInfo> _packageInfoFuture =
      PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: _packageInfoFuture,
      builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
        final String versionLabel = _buildVersionLabel(snapshot);
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Betting Page Test shorebird: ${widget.version}',
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Betting Page Test shorebird: ${Platform.isIOS ? 'iOS' : 'Android'}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  versionLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 18),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _buildVersionLabel(AsyncSnapshot<PackageInfo> snapshot) {
    if (snapshot.connectionState != ConnectionState.done) {
      return 'Đang tải phiên bản...';
    }
    if (snapshot.hasError || snapshot.data == null) {
      return 'Không đọc được phiên bản';
    }
    final PackageInfo info = snapshot.data!;
    final String version = info.version;
    final String build = info.buildNumber;
    if (version.isEmpty && build.isEmpty) {
      return '—';
    }
    if (version.isNotEmpty && build.isNotEmpty) {
      return 'Phiên bản: $version ($build)';
    }
    if (version.isNotEmpty) {
      return 'Phiên bản: $version';
    }
    return 'Bản build: $build';
  }
}
