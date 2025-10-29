import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talabat_clone_flutter/app.dart';

void main() {
  testWidgets('App should display the home screen', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('Welcome to Talabat Clone'), findsOneWidget);
  });

  testWidgets('Customer screen should have a button to create order', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Navigate to customer home screen
    await tester.tap(find.byKey(Key('customerHomeButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(Key('createOrderButton')), findsOneWidget);
  });

  testWidgets('Courier screen should display orders', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Navigate to courier dashboard
    await tester.tap(find.byKey(Key('courierDashboardButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(Key('ordersList')), findsOneWidget);
  });

  testWidgets('Admin screen should have user management option', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Navigate to admin dashboard
    await tester.tap(find.byKey(Key('adminDashboardButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(Key('manageUsersButton')), findsOneWidget);
  });
}