import 'dart:async';

import 'package:demo_unlock/core/restart_scope.dart';
import 'package:flutter/material.dart';

class FakeModeScreen extends StatelessWidget {
  const FakeModeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mode Fake'),
        actions: [
          IconButton(
            onPressed: () {
              unawaited(RestartScope.executeRestartApp(context));
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: const Center(
        child: Text('App is running in fake mode.'),
      ),
    );
  }
}
