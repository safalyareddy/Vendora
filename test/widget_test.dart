import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wholesale_pro_app/main.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(WholesaleApp());

    // Allow layouts + animations to settle and splash timers to run
    await tester.pump();
    await tester.pump(Duration(milliseconds: 1000));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
