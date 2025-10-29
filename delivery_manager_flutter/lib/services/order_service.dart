import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/order_model.dart';

class OrderService {
  final String baseUrl;
  final String apiKey;

  OrderService({
    required this.baseUrl,
    required this.apiKey,
  });

  // جلب الطلبات النشطة
  Future<List<OrderModel>> getActiveOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/orders?status=active'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // جلب إحصائيات اليوم
  Future<DailyStats> getTodayStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/orders/stats/today'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DailyStats.fromJson(data);
      } else {
        throw Exception('Failed to load stats');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // تحديث حالة الطلب
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/orders/$orderId/status'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': status}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update order status');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // تعيين مندوب للطلب
  Future<void> assignDriver(String orderId, String driverId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/orders/$orderId/assign'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({'driverId': driverId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to assign driver');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // الاستماع للتحديثات المباشرة للطلبات
  Stream<List<OrderModel>> listenToActiveOrders() {
    // هنا يمكن استخدام Firebase أو WebSocket
    // هذا مثال بسيط باستخدام Stream.periodic
    return Stream.periodic(const Duration(seconds: 10), (_) {
      return getActiveOrders();
    }).asyncMap((future) => future);
  }
}

class DailyStats {
  final int totalOrders;
  final double totalSales;
  final int completedOrders;
  final int canceledOrders;

  DailyStats({
    required this.totalOrders,
    required this.totalSales,
    required this.completedOrders,
    required this.canceledOrders,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      totalOrders: json['totalOrders'],
      totalSales: json['totalSales'].toDouble(),
      completedOrders: json['completedOrders'],
      canceledOrders: json['canceledOrders'],
    );
  }
}