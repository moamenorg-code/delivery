import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_manager_flutter/app.dart';

void main() {
  testWidgets('App loads and displays home screen', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Verify that the home screen is displayed
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('Delivery card displays correct information', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Assuming there is a delivery card widget with specific text
    expect(find.text('Delivery ID: 123'), findsOneWidget);
    expect(find.text('Status: Pending'), findsOneWidget);
  });

  testWidgets('Map screen shows OpenStreetMap', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Navigate to the map screen
    await tester.tap(find.byIcon(Icons.map));
    await tester.pumpAndSettle();

    // Verify that the map is displayed
    expect(find.byType(MapScreen), findsOneWidget);
  });
}