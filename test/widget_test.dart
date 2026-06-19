import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:medicare_app/main.dart';

void main() {
  testWidgets('MediCare smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MediCareApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
