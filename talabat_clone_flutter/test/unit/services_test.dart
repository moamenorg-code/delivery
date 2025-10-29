import 'package:flutter_test/flutter_test.dart';
import 'package:talabat_clone_flutter/src/services/api_service.dart';
import 'package:talabat_clone_flutter/src/services/auth_service.dart';
import 'package:talabat_clone_flutter/src/services/geo_service.dart';
import 'package:talabat_clone_flutter/src/services/push_service.dart';

void main() {
  group('API Service Tests', () {
    test('Fetch data from API', () async {
      final apiService = ApiService();
      final data = await apiService.fetchData();
      expect(data, isNotNull);
    });
  });

  group('Auth Service Tests', () {
    test('User login', () async {
      final authService = AuthService();
      final result = await authService.login('test@example.com', 'password');
      expect(result, isTrue);
    });

    test('User registration', () async {
      final authService = AuthService();
      final result = await authService.register('test@example.com', 'password');
      expect(result, isTrue);
    });
  });

  group('Geo Service Tests', () {
    test('Get user location', () async {
      final geoService = GeoService();
      final location = await geoService.getUserLocation();
      expect(location, isNotNull);
    });
  });

  group('Push Service Tests', () {
    test('Send push notification', () async {
      final pushService = PushService();
      final result = await pushService.sendNotification('Hello');
      expect(result, isTrue);
    });
  });
}