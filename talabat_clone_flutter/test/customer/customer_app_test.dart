import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_lib/controllers/restaurant_controller.dart';
import 'package:shared_lib/controllers/order_controller.dart';
import 'package:shared_lib/models/restaurant_model.dart';
import 'package:shared_lib/models/order_model.dart';

void main() {
  late RestaurantController restaurantController;
  late OrderController orderController;

  setUp(() {
    Get.reset();
    restaurantController = RestaurantController();
    orderController = OrderController();
    Get.put(restaurantController);
    Get.put(orderController);
  });

  group('Customer App - Restaurant Browsing', () {
    test('should filter restaurants by category', () {
      // Arrange
      final restaurants = [
        RestaurantModel(
          id: '1',
          name: 'Pizza Place',
          categories: ['بيتزا'],
          rating: 4.5,
          isOpen: true,
          location: {'lat': 30.0444, 'lng': 31.2357},
        ),
        RestaurantModel(
          id: '2',
          name: 'Burger Joint',
          categories: ['برجر'],
          rating: 4.0,
          isOpen: true,
          location: {'lat': 30.0444, 'lng': 31.2357},
        ),
      ];
      restaurantController.restaurants.addAll(restaurants);

      // Act
      restaurantController.setCategory('بيتزا');

      // Assert
      expect(restaurantController.filteredRestaurants.length, 1);
      expect(restaurantController.filteredRestaurants.first.name, 'Pizza Place');
    });

    test('should search restaurants by name', () {
      // Arrange
      final restaurants = [
        RestaurantModel(
          id: '1',
          name: 'Pizza Place',
          categories: ['بيتزا'],
          rating: 4.5,
          isOpen: true,
          location: {'lat': 30.0444, 'lng': 31.2357},
        ),
        RestaurantModel(
          id: '2',
          name: 'Burger Joint',
          categories: ['برجر'],
          rating: 4.0,
          isOpen: true,
          location: {'lat': 30.0444, 'lng': 31.2357},
        ),
      ];
      restaurantController.restaurants.addAll(restaurants);

      // Act
      restaurantController.setSearchQuery('pizza');

      // Assert
      expect(restaurantController.filteredRestaurants.length, 1);
      expect(restaurantController.filteredRestaurants.first.name, 'Pizza Place');
    });
  });

  group('Customer App - Order Management', () {
    test('should create new order', () async {
      // Arrange
      final restaurant = RestaurantModel(
        id: '1',
        name: 'Test Restaurant',
        categories: ['Test'],
        rating: 4.5,
        isOpen: true,
        location: {'lat': 30.0444, 'lng': 31.2357},
      );

      // Act
      final order = await orderController.createOrder(
        restaurantId: restaurant.id,
        items: [
          OrderItem(
            id: '1',
            name: 'Test Item',
            price: 100,
            quantity: 2,
          ),
        ],
        deliveryAddress: {
          'address': 'Test Address',
          'lat': 30.0444,
          'lng': 31.2357,
        },
      );

      // Assert
      expect(order, isNotNull);
      expect(order.status, OrderStatus.pending);
      expect(order.total, 200);
    });

    test('should track order status', () async {
      // Arrange
      final order = await orderController.createOrder(
        restaurantId: '1',
        items: [
          OrderItem(
            id: '1',
            name: 'Test Item',
            price: 100,
            quantity: 1,
          ),
        ],
        deliveryAddress: {
          'address': 'Test Address',
          'lat': 30.0444,
          'lng': 31.2357,
        },
      );

      // Act
      final status = orderController.trackOrder(order.id);

      // Assert
      expect(status, isNotNull);
      await expectLater(
        status,
        emitsThrough(OrderStatus.pending),
      );
    });
  });
}