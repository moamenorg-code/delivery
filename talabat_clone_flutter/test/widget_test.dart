import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talabat_clone_flutter/app.dart';
import 'package:get/get.dart';
import '../../shared_lib/lib/controllers/restaurant_controller.dart';
import '../../shared_lib/lib/models/restaurant_model.dart';

void main() {
  setUp(() {
    Get.reset();
    final restaurantController = RestaurantController();
    Get.put(restaurantController);
  });

  group('App Navigation Tests', () {
    testWidgets('App should display the home screen', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      expect(find.text('Welcome to Talabat Clone'), findsOneWidget);
    });

    testWidgets('Customer screen should have a button to create order', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      await tester.tap(find.byKey(const Key('customerHomeButton')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('createOrderButton')), findsOneWidget);
    });

    testWidgets('Courier screen should display orders', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      await tester.tap(find.byKey(const Key('courierDashboardButton')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('ordersList')), findsOneWidget);
    });

    testWidgets('Admin screen should have user management option', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      await tester.tap(find.byKey(const Key('adminDashboardButton')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('manageUsersButton')), findsOneWidget);
    });
  });

  group('Restaurant List Tests', () {
    testWidgets('Should show loading indicator when loading restaurants',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      await tester.tap(find.byKey(const Key('customerHomeButton')));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Should show restaurant cards when data is loaded',
        (WidgetTester tester) async {
      final controller = Get.find<RestaurantController>();
      controller.restaurants.addAll([
        RestaurantModel(
          id: '1',
          name: 'Test Restaurant',
          description: 'Test Description',
          coverImage: 'https://example.com/image.jpg',
          logoImage: 'https://example.com/logo.jpg',
          categories: ['Test Category'],
          location: {'lat': 30.0444, 'lng': 31.2357},
          rating: 4.5,
        ),
      ]);

      await tester.pumpWidget(MyApp());
      await tester.tap(find.byKey(const Key('customerHomeButton')));
      await tester.pumpAndSettle();

      expect(find.text('Test Restaurant'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
    });

    testWidgets('Should filter restaurants when searching',
        (WidgetTester tester) async {
      final controller = Get.find<RestaurantController>();
      controller.restaurants.addAll([
        RestaurantModel(
          id: '1',
          name: 'Pizza Restaurant',
          description: 'Best Pizza',
          coverImage: 'https://example.com/image1.jpg',
          logoImage: 'https://example.com/logo1.jpg',
          categories: ['بيتزا'],
          location: {'lat': 30.0444, 'lng': 31.2357},
          rating: 4.5,
        ),
        RestaurantModel(
          id: '2',
          name: 'Burger Restaurant',
          description: 'Best Burger',
          coverImage: 'https://example.com/image2.jpg',
          logoImage: 'https://example.com/logo2.jpg',
          categories: ['برجر'],
          location: {'lat': 30.0444, 'lng': 31.2357},
          rating: 4.0,
        ),
      ]);

      await tester.pumpWidget(MyApp());
      await tester.tap(find.byKey(const Key('customerHomeButton')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(SearchBar), 'Pizza');
      await tester.pumpAndSettle();

      expect(find.text('Pizza Restaurant'), findsOneWidget);
      expect(find.text('Burger Restaurant'), findsNothing);
    });
  });

  group('Restaurant Details Tests', () {
    testWidgets('Should show restaurant details when tapped',
        (WidgetTester tester) async {
      final controller = Get.find<RestaurantController>();
      final restaurant = RestaurantModel(
        id: '1',
        name: 'Test Restaurant',
        description: 'Test Description',
        coverImage: 'https://example.com/image.jpg',
        logoImage: 'https://example.com/logo.jpg',
        categories: ['Test Category'],
        location: {'lat': 30.0444, 'lng': 31.2357},
        rating: 4.5,
      );
      controller.restaurants.add(restaurant);

      await tester.pumpWidget(MyApp());
      await tester.tap(find.byKey(const Key('customerHomeButton')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test Restaurant'));
      await tester.pumpAndSettle();

      expect(find.text('Test Restaurant'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
      expect(find.text('4.5'), findsOneWidget);
    });
  });