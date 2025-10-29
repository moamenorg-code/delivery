import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:talabat_clone_flutter/src/providers/auth_provider.dart';
import 'package:talabat_clone_flutter/src/providers/orders_provider.dart';
import 'package:talabat_clone_flutter/src/providers/deliveries_provider.dart';

void main() {
  group('AuthProvider Tests', () {
    test('Initial state should be logged out', () {
      final authProvider = AuthProvider();
      expect(authProvider.isLoggedIn, false);
    });

    // Add more tests for AuthProvider methods
  });

  group('OrdersProvider Tests', () {
    test('Initial orders list should be empty', () {
      final ordersProvider = OrdersProvider();
      expect(ordersProvider.orders, isEmpty);
    });

    // Add more tests for OrdersProvider methods
  });

  group('DeliveriesProvider Tests', () {
    test('Initial deliveries list should be empty', () {
      final deliveriesProvider = DeliveriesProvider();
      expect(deliveriesProvider.deliveries, isEmpty);
    });

    // Add more tests for DeliveriesProvider methods
  });
}