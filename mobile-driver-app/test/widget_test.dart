import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:logistics_driver_app/main.dart';

void main() {
  testWidgets('DriverApp builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: DriverApp()));
    // First frame renders the splash screen while session restore runs in
    // the background - this just confirms the app boots with no exceptions.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
