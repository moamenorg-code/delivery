import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // المستخدمين
  Future<void> createUser(Map<String, dynamic> userData) async {
    try {
      await _firestore
          .collection('users')
          .doc(userData['id'])
          .set({
            ...userData,
            'createdAt': FieldValue.serverTimestamp(),
            'lastLoginAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw 'حدث خطأ أثناء إنشاء المستخدم: $e';
    }
  }

  // المطاعم
  Future<void> createRestaurant(Map<String, dynamic> restaurantData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'يجب تسجيل الدخول أولاً';

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.data()?['role'] != 'restaurant_admin') {
        throw 'ليس لديك صلاحية لإنشاء مطعم';
      }

      await _firestore
          .collection('restaurants')
          .doc(restaurantData['id'])
          .set({
            ...restaurantData,
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw 'حدث خطأ أثناء إنشاء المطعم: $e';
    }
  }

  // الطلبات
  Future<String> createOrder(Map<String, dynamic> orderData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'يجب تسجيل الدخول أولاً';

      final orderRef = _firestore.collection('orders').doc();
      await orderRef.set({
        ...orderData,
        'id': orderRef.id,
        'customerId': user.uid,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return orderRef.id;
    } catch (e) {
      throw 'حدث خطأ أثناء إنشاء الطلب: $e';
    }
  }

  // تحديث حالة الطلب
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'يجب تسجيل الدخول أولاً';

      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'حدث خطأ أثناء تحديث حالة الطلب: $e';
    }
  }

  // المندوبين
  Future<void> updateDriverLocation(String driverId, GeoPoint location) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'يجب تسجيل الدخول أولاً';

      if (user.uid != driverId) throw 'ليس لديك صلاحية لتحديث هذا الموقع';

      await _firestore.collection('drivers').doc(driverId).update({
        'currentLocation': location,
        'lastLocationUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'حدث خطأ أثناء تحديث موقع المندوب: $e';
    }
  }

  // المعاملات المالية
  Future<void> createTransaction(Map<String, dynamic> transactionData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'يجب تسجيل الدخول أولاً';

      final transactionRef = _firestore.collection('transactions').doc();
      await transactionRef.set({
        ...transactionData,
        'id': transactionRef.id,
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'حدث خطأ أثناء إنشاء المعاملة: $e';
    }
  }

  // الاستماع للتغييرات في الوقت الحقيقي
  Stream<DocumentSnapshot> streamOrder(String orderId) {
    return _firestore.collection('orders').doc(orderId).snapshots();
  }

  Stream<DocumentSnapshot> streamDriverLocation(String driverId) {
    return _firestore.collection('drivers').doc(driverId).snapshots();
  }

  Stream<QuerySnapshot> streamRestaurants() {
    return _firestore
        .collection('restaurants')
        .where('isOpen', isEqualTo: true)
        .snapshots();
  }

  // الاستعلامات المتقدمة
  Future<List<DocumentSnapshot>> searchRestaurants(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection('restaurants')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      return querySnapshot.docs;
    } catch (e) {
      throw 'حدث خطأ أثناء البحث عن المطاعم: $e';
    }
  }

  Future<List<DocumentSnapshot>> getNearbyRestaurants(
    GeoPoint location,
    double radiusInKm,
  ) async {
    try {
      // تحتاج إلى إضافة GeoFlutterFire للبحث بناءً على الموقع
      // هذا مثال مبسط
      final querySnapshot = await _firestore
          .collection('restaurants')
          .where('isOpen', isEqualTo: true)
          .get();

      return querySnapshot.docs;
    } catch (e) {
      throw 'حدث خطأ أثناء البحث عن المطاعم القريبة: $e';
    }
  }
}