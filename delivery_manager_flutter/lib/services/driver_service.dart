import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/driver_model.dart';

class DriverService {
  final String baseUrl;
  final String apiKey;

  DriverService({
    required this.baseUrl,
    required this.apiKey,
  });

  // جلب المندوبين النشطين
  Future<List<DriverModel>> getActiveDrivers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/drivers/available'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => DriverModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load drivers');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // تحديث حالة المندوب
  Future<void> updateDriverStatus(String driverId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/drivers/$driverId/status'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': status}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update driver status');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // جلب إحصائيات المندوب
  Future<DriverStats> getDriverStats(String driverId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/drivers/$driverId/stats'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DriverStats.fromJson(data);
      } else {
        throw Exception('Failed to load driver stats');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // الاستماع لتحديثات المندوبين
  Stream<List<DriverModel>> listenToActiveDrivers() {
    // هنا يمكن استخدام Firebase أو WebSocket
    // هذا مثال بسيط باستخدام Stream.periodic
    return Stream.periodic(const Duration(seconds: 10), (_) {
      return getActiveDrivers();
    }).asyncMap((future) => future);
  }
}

class DriverStats {
  final int totalDeliveries;
  final double totalEarnings;
  final double averageRating;
  final int completedToday;

  DriverStats({
    required this.totalDeliveries,
    required this.totalEarnings,
    required this.averageRating,
    required this.completedToday,
  });

  factory DriverStats.fromJson(Map<String, dynamic> json) {
    return DriverStats(
      totalDeliveries: json['totalDeliveries'],
      totalEarnings: json['totalEarnings'].toDouble(),
      averageRating: json['averageRating'].toDouble(),
      completedToday: json['completedToday'],
    );
  }
}