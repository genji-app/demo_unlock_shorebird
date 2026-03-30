import 'package:demo_unlock/core/restart_scope.dart';
import 'package:demo_unlock/screens/betting_mode_screen.dart';
import 'package:demo_unlock/screens/fake_mode_screen.dart';
import 'package:unlock_shorebird_kit/unlock_shorebird_kit.dart';
import 'package:flutter/material.dart';
import 'package:terminate_restart/terminate_restart.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  TerminateRestart.instance.initialize();
  runApp(
    const RestartScope(
      child: DemoUnlockApp(),
    ),
  );
}

class DemoUnlockApp extends StatelessWidget {
  const DemoUnlockApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo Unlock',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: SplashModeScreen(
        bettingScreenBuilder: () => const BettingModeScreen(),
        fakeScreenBuilder: () => const FakeModeScreen(),
        executeRestartWithFade: RestartScope.executeRestartApp,
      ),
    );
  }
}
