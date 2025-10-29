import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../models/restaurant_model.dart';
import '../models/user_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // إنشاء طلب جديد
  Future<String> createOrder(OrderModel order) async {
    try {
      // التحقق من المطعم
      final restaurant = await _firestore
          .collection('restaurants')
          .doc(order.restaurantId)
          .get();
      
      if (!restaurant.exists) {
        throw 'Restaurant not found';
      }

      // التحقق من الحد الأدنى للطلب
      final restaurantData = RestaurantModel.fromMap(restaurant.data()!, restaurant.id);
      if (order.subtotal < restaurantData.minOrderAmount) {
        throw 'Order amount is below minimum required: ${restaurantData.minOrderAmount}';
      }

      // إنشاء الطلب
      final ref = await _firestore.collection('orders').add(order.toMap());
      
      // تحديث معرف الطلب
      await ref.update({'id': ref.id});

      // تحديث إحصائيات المطعم
      await restaurant.reference.update({
        'totalOrders': FieldValue.increment(1),
      });

      return ref.id;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // تحديث حالة الطلب
  Future<void> updateOrderStatus(
    String orderId,
    String status,
    String updatedBy, {
    String? note,
  }) async {
    try {
      final batch = _firestore.batch();
      final orderRef = _firestore.collection('orders').doc(orderId);

      // تحديث الحالة
      final statusUpdate = OrderStatusUpdate(
        status: status,
        note: note,
        timestamp: DateTime.now(),
        updatedBy: updatedBy,
      );

      batch.update(orderRef, {
        'status': status,
        '${status}At': FieldValue.serverTimestamp(),
        'statusUpdates': FieldValue.arrayUnion([statusUpdate.toMap()]),
      });

      // إذا كانت الحالة "تم التسليم"، قم بتحديث إحصائيات المندوب
      if (status == 'delivered') {
        final order = await orderRef.get();
        final orderData = order.data()!;
        
        if (orderData['driverId'] != null) {
          final driverRef = _firestore
              .collection('drivers')
              .doc(orderData['driverId']);
          
          batch.update(driverRef, {
            'totalDeliveries': FieldValue.increment(1),
            'totalEarnings': FieldValue.increment(orderData['deliveryFee'] ?? 0),
          });
        }
      }

      await batch.commit();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // تعيين مندوب للطلب
  Future<void> assignDriver(String orderId, String driverId) async {
    try {
      final batch = _firestore.batch();
      final orderRef = _firestore.collection('orders').doc(orderId);
      final driverRef = _firestore.collection('drivers').doc(driverId);

      // التحقق من المندوب
      final driver = await driverRef.get();
      if (!driver.exists || !(driver.data()?['available'] ?? false)) {
        throw 'Driver not available';
      }

      // تحديث الطلب
      batch.update(orderRef, {
        'driverId': driverId,
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      // تحديث حالة المندوب
      batch.update(driverRef, {
        'available': false,
        'currentOrderId': orderId,
      });

      await batch.commit();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // إضافة مشكلة للطلب
  Future<void> addOrderIssue(
    String orderId,
    String type,
    String description,
  ) async {
    try {
      final issue = OrderIssue(
        type: type,
        description: description,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await _firestore.collection('orders').doc(orderId).update({
        'issues': FieldValue.arrayUnion([issue.toMap()]),
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  // إضافة تقييم للطلب
  Future<void> rateOrder(
    String orderId,
    String raterType,
    double rating,
    String? review,
  ) async {
    try {
      final batch = _firestore.batch();
      final orderRef = _firestore.collection('orders').doc(orderId);

      // تحديث تقييم الطلب
      final updates = <String, dynamic>{
        '${raterType}Rating': rating,
        '${raterType}Review': review,
      };
      batch.update(orderRef, updates);

      // تحديث متوسط تقييم المندوب أو المطعم
      final order = await orderRef.get();
      final orderData = OrderModel.fromMap(order.data()!, order.id);

      if (raterType == 'customer' && orderData.driverId != null) {
        final driverRef = _firestore.collection('drivers').doc(orderData.driverId);
        await _updateRating(driverRef, rating);
      } else if (raterType == 'driver') {
        final customerRef = _firestore.collection('users').doc(orderData.customerId);
        await _updateRating(customerRef, rating);
      }

      await batch.commit();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // تحديث متوسط التقييم
  Future<void> _updateRating(
    DocumentReference ref,
    double newRating,
  ) async {
    final doc = await ref.get();
    final currentRating = doc.data()?['rating'] ?? 0.0;
    final totalRatings = doc.data()?['totalRatings'] ?? 0;

    final newTotalRating = (currentRating * totalRatings + newRating);
    final newTotalRatings = totalRatings + 1;
    final updatedRating = newTotalRating / newTotalRatings;

    await ref.update({
      'rating': updatedRating,
      'totalRatings': newTotalRatings,
    });
  }

  // معالجة الأخطاء
  String _handleError(dynamic e) {
    if (e is FirebaseException) {
      switch (e.code) {
        case 'not-found':
          return 'لم يتم العثور على الطلب';
        case 'permission-denied':
          return 'ليس لديك صلاحية لهذا الإجراء';
        default:
          return 'حدث خطأ ما';
      }
    }
    return e.toString();
  }
}