import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_lib/controllers/driver_controller.dart';
import 'package:shared_lib/controllers/order_controller.dart';
import 'package:shared_lib/models/order_model.dart';
import 'package:shared_lib/services/location_service.dart';

void main() {
  late DriverController driverController;
  late OrderController orderController;
  late LocationService locationService;

  setUp(() {
    Get.reset();
    driverController = DriverController();
    orderController = OrderController();
    locationService = LocationService();
    Get.put(driverController);
    Get.put(orderController);
    Get.put(locationService);
  });

  group('Driver App - Order Management', () {
    test('should list available orders', () async {
      // Arrange
      final driverId = 'driver1';
      
      // Act
      final orders = driverController.getAvailableOrders();

      // Assert
      await expectLater(
        orders,
        emitsThrough(isNotEmpty),
      );
    });

    test('should accept order', () async {
      // Arrange
      final order = OrderModel(
        id: '1',
        customerId: 'customer1',
        restaurantId: '1',
        items: [],
        status: OrderStatus.readyForPickup,
        createdAt: DateTime.now(),
        deliveryAddress: {
          'address': 'Test Address',
          'lat': 30.0444,
          'lng': 31.2357,
        },
      );

      // Act
      final acceptedOrder = await driverController.acceptOrder(
        order.id,
        'driver1',
      );

      // Assert
      expect(acceptedOrder.driverId, 'driver1');
      expect(acceptedOrder.status, OrderStatus.pickedUp);
    });

    test('should update order status during delivery', () async {
      // Arrange
      final orderId = '1';
      final driverId = 'driver1';

      // Act
      final updatedOrder = await driverController.updateDeliveryStatus(
        orderId,
        OrderStatus.delivering,
      );

      // Assert
      expect(updatedOrder.status, OrderStatus.delivering);
    });
  });

  group('Driver App - Location Tracking', () {
    test('should update driver location', () async {
      // Arrange
      final driverId = 'driver1';
      final location = {'lat': 30.0444, 'lng': 31.2357};

      // Act
      final result = await driverController.updateLocation(
        driverId,
        location,
      );

      // Assert
      expect(result, isTrue);
    });

    test('should calculate estimated delivery time', () async {
      // Arrange
      final pickup = {'lat': 30.0444, 'lng': 31.2357};
      final delivery = {'lat': 30.0544, 'lng': 31.2457};

      // Act
      final estimate = await locationService.calculateDeliveryEstimate(
        pickup,
        delivery,
      );

      // Assert
      expect(estimate.duration, isNonNegative);
      expect(estimate.distance, isNonNegative);
    });
  });

  group('Driver App - Earnings Management', () {
    test('should calculate trip earnings', () async {
      // Arrange
      final orderId = '1';
      final distance = 5.0; // km

      // Act
      final earnings = await driverController.calculateTripEarnings(
        orderId,
        distance,
      );

      // Assert
      expect(earnings, isPositive);
    });

    test('should generate earnings report', () async {
      // Arrange
      final driverId = 'driver1';
      final startDate = DateTime.now().subtract(const Duration(days: 7));
      final endDate = DateTime.now();

      // Act
      final report = await driverController.generateEarningsReport(
        driverId,
        startDate,
        endDate,
      );

      // Assert
      expect(report.totalEarnings, isNonNegative);
      expect(report.totalTrips, isNonNegative);
      expect(report.totalDistance, isNonNegative);
    });
  });
}