import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reward_model.dart';

class RewardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // إضافة نقاط مكافآت
  Future<RewardPoint> addPoints(
    String userId,
    int points,
    String source, {
    String? orderId,
    String? description,
  }) async {
    try {
      final batch = _firestore.batch();
      
      // إنشاء سجل النقاط
      final pointRef = _firestore.collection('reward_points').doc();
      final rewardPoint = RewardPoint(
        id: pointRef.id,
        userId: userId,
        points: points,
        type: 'earned',
        source: source,
        timestamp: DateTime.now(),
        orderId: orderId,
        description: description,
      );

      batch.set(pointRef, rewardPoint.toMap());

      // تحديث إجمالي نقاط المستخدم
      final userRef = _firestore.collection('users').doc(userId);
      batch.update(userRef, {
        'points': FieldValue.increment(points),
      });

      await batch.commit();
      return rewardPoint;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // استبدال النقاط
  Future<RewardPoint> redeemPoints(
    String userId,
    int points,
    String source, {
    String? orderId,
    String? description,
  }) async {
    try {
      // التحقق من رصيد النقاط
      final user = await _firestore.collection('users').doc(userId).get();
      final currentPoints = user.data()?['points'] ?? 0;
      
      if (currentPoints < points) {
        throw 'Insufficient points';
      }

      final batch = _firestore.batch();
      
      // إنشاء سجل الاستبدال
      final pointRef = _firestore.collection('reward_points').doc();
      final rewardPoint = RewardPoint(
        id: pointRef.id,
        userId: userId,
        points: points,
        type: 'redeemed',
        source: source,
        timestamp: DateTime.now(),
        orderId: orderId,
        description: description,
      );

      batch.set(pointRef, rewardPoint.toMap());

      // تحديث رصيد نقاط المستخدم
      batch.update(user.reference, {
        'points': FieldValue.increment(-points),
      });

      await batch.commit();
      return rewardPoint;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // الحصول على سجل النقاط
  Stream<List<RewardPoint>> getPointsHistory(String userId) {
    return _firestore
        .collection('reward_points')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => RewardPoint.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // الحصول على رصيد النقاط الحالي
  Future<int> getCurrentPoints(String userId) async {
    try {
      final user = await _firestore.collection('users').doc(userId).get();
      return user.data()?['points']?.toInt() ?? 0;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // الحصول على برامج المكافآت النشطة
  Stream<List<RewardProgram>> getActivePrograms() {
    return _firestore
        .collection('reward_programs')
        .where('isActive', isEqualTo: true)
        .where('endDate', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => RewardProgram.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // التحقق من أهلية الإحالة
  Future<bool> checkReferralEligibility(String userId) async {
    try {
      final orders = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'delivered')
          .get();

      return orders.docs.length >= 3; // مثال: يجب إكمال 3 طلبات على الأقل
    } catch (e) {
      throw _handleError(e);
    }
  }

  // معالجة مكافأة الإحالة
  Future<void> processReferralReward(String referrerId, String referredId) async {
    try {
      final batch = _firestore.batch();

      // إضافة نقاط للمُحيل
      final referrerPoint = RewardPoint(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: referrerId,
        points: 50, // مثال: 50 نقطة للإحالة
        type: 'earned',
        source: 'referral',
        timestamp: DateTime.now(),
        description: 'Referral reward for inviting a new user',
      );

      batch.set(
        _firestore.collection('reward_points').doc(referrerPoint.id),
        referrerPoint.toMap(),
      );

      // إضافة نقاط للمُحال
      final referredPoint = RewardPoint(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        userId: referredId,
        points: 25, // مثال: 25 نقطة للمستخدم الجديد
        type: 'earned',
        source: 'referral',
        timestamp: DateTime.now(),
        description: 'Welcome bonus for joining through referral',
      );

      batch.set(
        _firestore.collection('reward_points').doc(referredPoint.id),
        referredPoint.toMap(),
      );

      // تحديث نقاط المستخدمين
      batch.update(
        _firestore.collection('users').doc(referrerId),
        {'points': FieldValue.increment(50)},
      );

      batch.update(
        _firestore.collection('users').doc(referredId),
        {'points': FieldValue.increment(25)},
      );

      await batch.commit();
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic e) {
    if (e is FirebaseException) {
      switch (e.code) {
        case 'not-found':
          return 'المستخدم غير موجود';
        case 'permission-denied':
          return 'ليس لديك صلاحية لهذا الإجراء';
        default:
          return 'حدث خطأ ما';
      }
    }
    return e.toString();
  }
}