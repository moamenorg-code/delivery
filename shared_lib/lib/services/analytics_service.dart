import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // إحصائيات عامة
  Future<Map<String, dynamic>> getGeneralStats() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);

    final ordersRef = _firestore.collection('orders');
    
    // إحصائيات اليوم
    final dailyStats = await _getStatsForPeriod(
      ordersRef,
      startOfDay,
      now,
    );

    // إحصائيات الأسبوع
    final weeklyStats = await _getStatsForPeriod(
      ordersRef,
      startOfWeek,
      now,
    );

    // إحصائيات الشهر
    final monthlyStats = await _getStatsForPeriod(
      ordersRef,
      startOfMonth,
      now,
    );

    return {
      'daily': dailyStats,
      'weekly': weeklyStats,
      'monthly': monthlyStats,
    };
  }

  // إحصائيات لفترة محددة
  Future<Map<String, dynamic>> _getStatsForPeriod(
    CollectionReference ordersRef,
    DateTime start,
    DateTime end,
  ) async {
    final orders = await ordersRef
        .where('createdAt', isGreaterThanOrEqual: start)
        .where('createdAt', lessThanOrEqual: end)
        .get();

    double totalRevenue = 0;
    int completedOrders = 0;
    int cancelledOrders = 0;
    double avgOrderValue = 0;

    for (var doc in orders.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['status'] == 'delivered') {
        totalRevenue += data['total'] ?? 0;
        completedOrders++;
      } else if (data['status'] == 'cancelled') {
        cancelledOrders++;
      }
    }

    if (completedOrders > 0) {
      avgOrderValue = totalRevenue / completedOrders;
    }

    return {
      'totalRevenue': totalRevenue,
      'completedOrders': completedOrders,
      'cancelledOrders': cancelledOrders,
      'avgOrderValue': avgOrderValue,
      'totalOrders': orders.docs.length,
    };
  }

  // إحصائيات المطاعم
  Future<List<Map<String, dynamic>>> getRestaurantStats(String restaurantId) async {
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: i)));

    final stats = await Future.wait(
      days.map((day) async {
        final start = DateTime(day.year, day.month, day.day);
        final end = DateTime(day.year, day.month, day.day, 23, 59, 59);

        final orders = await _firestore
            .collection('orders')
            .where('restaurantId', isEqualTo: restaurantId)
            .where('createdAt', isGreaterThanOrEqual: start)
            .where('createdAt', lessThanOrEqual: end)
            .get();

        double revenue = 0;
        int completed = 0;

        for (var doc in orders.docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['status'] == 'delivered') {
            revenue += data['total'] ?? 0;
            completed++;
          }
        }

        return {
          'date': DateFormat('yyyy-MM-dd').format(day),
          'revenue': revenue,
          'orders': orders.docs.length,
          'completedOrders': completed,
        };
      }),
    );

    return stats;
  }

  // إحصائيات المندوبين
  Future<Map<String, dynamic>> getDriverStats(String driverId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final orders = await _firestore
        .collection('orders')
        .where('driverId', isEqualTo: driverId)
        .where('createdAt', isGreaterThanOrEqual: startOfDay)
        .get();

    int completedDeliveries = 0;
    double totalEarnings = 0;
    double avgDeliveryTime = 0;
    List<double> deliveryTimes = [];

    for (var doc in orders.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['status'] == 'delivered') {
        completedDeliveries++;
        totalEarnings += data['deliveryFee'] ?? 0;

        // حساب وقت التوصيل
        final acceptedAt = (data['acceptedAt'] as Timestamp).toDate();
        final deliveredAt = (data['deliveredAt'] as Timestamp).toDate();
        final deliveryTime = deliveredAt.difference(acceptedAt).inMinutes;
        deliveryTimes.add(deliveryTime.toDouble());
      }
    }

    if (deliveryTimes.isNotEmpty) {
      avgDeliveryTime = deliveryTimes.reduce((a, b) => a + b) / deliveryTimes.length;
    }

    return {
      'totalOrders': orders.docs.length,
      'completedDeliveries': completedDeliveries,
      'totalEarnings': totalEarnings,
      'avgDeliveryTime': avgDeliveryTime,
      'performance': _calculatePerformanceScore(
        completedDeliveries,
        orders.docs.length,
        avgDeliveryTime,
      ),
    };
  }

  // حساب درجة أداء المندوب
  double _calculatePerformanceScore(
    int completed,
    int total,
    double avgDeliveryTime,
  ) {
    if (total == 0) return 0;

    // معدل إكمال الطلبات (60%)
    final completionRate = (completed / total) * 60;

    // وقت التوصيل (40%)
    // افتراض أن 30 دقيقة هو الوقت المثالي
    final timeScore = max(0, (60 - avgDeliveryTime) / 30) * 40;

    return completionRate + timeScore;
  }

  // تحليل رضا العملاء
  Future<Map<String, dynamic>> getCustomerSatisfaction() async {
    final orders = await _firestore
        .collection('orders')
        .where('status', isEqualTo: 'delivered')
        .where('customerRating', isGreaterThan: 0)
        .get();

    List<double> ratings = [];
    Map<int, int> ratingDistribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (var doc in orders.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final rating = (data['customerRating'] as num).toDouble();
      ratings.add(rating);
      ratingDistribution[rating.round()] = 
          (ratingDistribution[rating.round()] ?? 0) + 1;
    }

    double avgRating = 0;
    if (ratings.isNotEmpty) {
      avgRating = ratings.reduce((a, b) => a + b) / ratings.length;
    }

    return {
      'averageRating': avgRating,
      'totalRatings': ratings.length,
      'distribution': ratingDistribution,
      'satisfactionRate': (avgRating / 5) * 100,
    };
  }
}