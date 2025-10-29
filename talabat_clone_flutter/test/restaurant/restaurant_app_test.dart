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

  group('Restaurant App - Menu Management', () {
    test('should update menu items', () async {
      // Arrange
      final restaurant = RestaurantModel(
        id: '1',
        name: 'Test Restaurant',
        categories: ['Test'],
        menu: [],
        rating: 4.5,
        isOpen: true,
        location: {'lat': 30.0444, 'lng': 31.2357},
      );

      // Act
      final updatedMenu = await restaurantController.updateMenu(
        restaurant.id,
        [
          MenuItem(
            id: '1',
            name: 'New Item',
            description: 'Test Description',
            price: 100,
            category: 'Test Category',
            isAvailable: true,
          ),
        ],
      );

      // Assert
      expect(updatedMenu, isNotNull);
      expect(updatedMenu.length, 1);
      expect(updatedMenu.first.name, 'New Item');
    });

    test('should toggle item availability', () async {
      // Arrange
      final menuItem = MenuItem(
        id: '1',
        name: 'Test Item',
        description: 'Test Description',
        price: 100,
        category: 'Test Category',
        isAvailable: true,
      );

      // Act
      final updatedItem = await restaurantController.toggleItemAvailability(
        '1',
        menuItem.id,
      );

      // Assert
      expect(updatedItem.isAvailable, false);
    });
  });

  group('Restaurant App - Order Management', () {
    test('should receive new orders', () async {
      // Arrange
      final newOrder = OrderModel(
        id: '1',
        customerId: 'customer1',
        restaurantId: '1',
        items: [
          OrderItem(
            id: '1',
            name: 'Test Item',
            price: 100,
            quantity: 2,
          ),
        ],
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        deliveryAddress: {
          'address': 'Test Address',
          'lat': 30.0444,
          'lng': 31.2357,
        },
      );

      // Act
      final orders = orderController.getRestaurantOrders('1');

      // Assert
      await expectLater(
        orders,
        emits(contains(newOrder)),
      );
    });

    test('should update order status', () async {
      // Arrange
      final order = OrderModel(
        id: '1',
        customerId: 'customer1',
        restaurantId: '1',
        items: [],
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        deliveryAddress: {
          'address': 'Test Address',
          'lat': 30.0444,
          'lng': 31.2357,
        },
      );

      // Act
      final updatedOrder = await orderController.updateOrderStatus(
        order.id,
        OrderStatus.preparing,
      );

      // Assert
      expect(updatedOrder.status, OrderStatus.preparing);
    });

    test('should generate order reports', () async {
      // Act
      final report = await restaurantController.generateOrderReport(
        '1',
        DateTime.now().subtract(const Duration(days: 7)),
        DateTime.now(),
      );

      // Assert
      expect(report, isNotNull);
      expect(report.totalOrders, isNonNegative);
      expect(report.totalRevenue, isNonNegative);
    });
  });
}