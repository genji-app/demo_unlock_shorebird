import 'package:demo_unlock/screens/betting_mode_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BettingModeScreen builds', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BettingModeScreen(),
      ),
    );
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
