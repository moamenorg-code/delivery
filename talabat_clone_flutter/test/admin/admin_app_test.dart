import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_lib/controllers/admin_controller.dart';
import 'package:shared_lib/controllers/user_controller.dart';
import 'package:shared_lib/models/user_model.dart';
import 'package:shared_lib/models/report_model.dart';

void main() {
  late AdminController adminController;
  late UserController userController;

  setUp(() {
    Get.reset();
    adminController = AdminController();
    userController = UserController();
    Get.put(adminController);
    Get.put(userController);
  });

  group('Admin App - User Management', () {
    test('should list all users', () async {
      // Act
      final users = await adminController.getAllUsers();

      // Assert
      expect(users, isNotEmpty);
      expect(users.first, isA<UserModel>());
    });

    test('should filter users by role', () async {
      // Act
      final drivers = await adminController.getUsersByRole('driver');

      // Assert
      expect(drivers, isNotEmpty);
      expect(drivers.every((user) => user.role == 'driver'), isTrue);
    });

    test('should update user status', () async {
      // Arrange
      final userId = 'user1';

      // Act
      final result = await adminController.updateUserStatus(
        userId,
        UserStatus.suspended,
      );

      // Assert
      expect(result, isTrue);
      final user = await userController.getUser(userId);
      expect(user.status, UserStatus.suspended);
    });
  });

  group('Admin App - Restaurant Management', () {
    test('should approve new restaurant', () async {
      // Arrange
      final restaurantId = 'restaurant1';

      // Act
      final result = await adminController.approveRestaurant(restaurantId);

      // Assert
      expect(result, isTrue);
    });

    test('should generate restaurant performance report', () async {
      // Arrange
      final restaurantId = 'restaurant1';
      final startDate = DateTime.now().subtract(const Duration(days: 30));
      final endDate = DateTime.now();

      // Act
      final report = await adminController.generateRestaurantReport(
        restaurantId,
        startDate,
        endDate,
      );

      // Assert
      expect(report, isNotNull);
      expect(report.totalOrders, isNonNegative);
      expect(report.totalRevenue, isNonNegative);
      expect(report.averageRating, inInclusiveRange(0, 5));
    });
  });

  group('Admin App - Financial Management', () {
    test('should process restaurant payouts', () async {
      // Act
      final result = await adminController.processRestaurantPayouts();

      // Assert
      expect(result, isNotNull);
      expect(result.successful, isTrue);
      expect(result.failedTransactions, isEmpty);
    });

    test('should process driver payouts', () async {
      // Act
      final result = await adminController.processDriverPayouts();

      // Assert
      expect(result, isNotNull);
      expect(result.successful, isTrue);
      expect(result.failedTransactions, isEmpty);
    });

    test('should generate financial reports', () async {
      // Arrange
      final startDate = DateTime.now().subtract(const Duration(days: 30));
      final endDate = DateTime.now();

      // Act
      final report = await adminController.generateFinancialReport(
        startDate,
        endDate,
      );

      // Assert
      expect(report, isNotNull);
      expect(report.totalRevenue, isNonNegative);
      expect(report.totalCommissions, isNonNegative);
      expect(report.netProfit, isNonNegative);
    });
  });

  group('Admin App - System Management', () {
    test('should update commission rates', () async {
      // Act
      final result = await adminController.updateCommissionRates({
        'restaurant': 0.15,
        'driver': 0.10,
      });

      // Assert
      expect(result, isTrue);
    });

    test('should update delivery zones', () async {
      // Arrange
      final zones = [
        {
          'name': 'Zone 1',
          'coordinates': [
            {'lat': 30.0444, 'lng': 31.2357},
            {'lat': 30.0544, 'lng': 31.2357},
            {'lat': 30.0544, 'lng': 31.2457},
            {'lat': 30.0444, 'lng': 31.2457},
          ],
          'baseDeliveryFee': 15.0,
        }
      ];

      // Act
      final result = await adminController.updateDeliveryZones(zones);

      // Assert
      expect(result, isTrue);
    });

    test('should generate system performance report', () async {
      // Act
      final report = await adminController.generateSystemReport();

      // Assert
      expect(report, isNotNull);
      expect(report.activeUsers, isNonNegative);
      expect(report.activeDrivers, isNonNegative);
      expect(report.activeRestaurants, isNonNegative);
      expect(report.averageDeliveryTime, isNonNegative);
      expect(report.systemUptime, isNonNegative);
    });
  });
}