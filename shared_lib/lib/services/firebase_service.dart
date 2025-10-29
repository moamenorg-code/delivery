import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/errors/failures.dart';
import '../core/utils/logger.dart';

class FirebaseService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // المستخدمين
  Future<void> createUser(Map<String, dynamic> userData) async {
    try {
      final docRef = _firestore.collection('users').doc(userData['id']);
      
      await docRef.set({
        ...userData,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.i('User created successfully: ${userData['id']}');
    } catch (e, stackTrace) {
      AppLogger.e('Error creating user', e, stackTrace);
      throw FirebaseFailure(
        message: 'حدث خطأ أثناء إنشاء المستخدم',
        error: e,
      );
    }
  }

  // المطاعم
  Future<void> createRestaurant(Map<String, dynamic> restaurantData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthFailure(message: 'يجب تسجيل الدخول أولاً');
      }

      await _checkUserRole(user.uid, 'restaurant_admin');

      final docRef = _firestore.collection('restaurants').doc(restaurantData['id']);
      await docRef.set({
        ...restaurantData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'adminId': user.uid,
      });

      AppLogger.i('Restaurant created successfully: ${restaurantData['id']}');
    } catch (e, stackTrace) {
      AppLogger.e('Error creating restaurant', e, stackTrace);
      if (e is FirebaseFailure) rethrow;
      throw FirebaseFailure(
        message: 'حدث خطأ أثناء إنشاء المطعم',
        error: e,
      );
    }
  }

  // الطلبات
  Future<String> createOrder(Map<String, dynamic> orderData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthFailure(message: 'يجب تسجيل الدخول أولاً');
      }

      final orderRef = _firestore.collection('orders').doc();
      final orderWithMetadata = {
        ...orderData,
        'id': orderRef.id,
        'customerId': user.uid,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await orderRef.set(orderWithMetadata);
      
      AppLogger.i('Order created successfully: ${orderRef.id}');
      return orderRef.id;
    } catch (e, stackTrace) {
      AppLogger.e('Error creating order', e, stackTrace);
      if (e is FirebaseFailure) rethrow;
      throw FirebaseFailure(
        message: 'حدث خطأ أثناء إنشاء الطلب',
        error: e,
      );
    }
  }

  // تحديث حالة الطلب
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthFailure(message: 'يجب تسجيل الدخول أولاً');
      }

      // التحقق من صلاحية تحديث الطلب
      await _checkOrderUpdatePermission(orderId, user.uid);

      final docRef = _firestore.collection('orders').doc(orderId);
      await docRef.update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': user.uid,
      });

      AppLogger.i('Order status updated successfully: $orderId -> $status');
    } catch (e, stackTrace) {
      AppLogger.e('Error updating order status', e, stackTrace);
      if (e is FirebaseFailure) rethrow;
      throw FirebaseFailure(
        message: 'حدث خطأ أثناء تحديث حالة الطلب',
        error: e,
      );
    }
  }

  // المندوبين
  Future<void> updateDriverLocation(String driverId, GeoPoint location) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthFailure(message: 'يجب تسجيل الدخول أولاً');
      }

      if (user.uid != driverId) {
        throw const AuthorizationFailure(
          message: 'ليس لديك صلاحية لتحديث هذا الموقع',
        );
      }

      final docRef = _firestore.collection('drivers').doc(driverId);
      await docRef.update({
        'currentLocation': location,
        'lastLocationUpdate': FieldValue.serverTimestamp(),
      });

      AppLogger.i('Driver location updated successfully: $driverId');
    } catch (e, stackTrace) {
      AppLogger.e('Error updating driver location', e, stackTrace);
      if (e is FirebaseFailure) rethrow;
      throw FirebaseFailure(
        message: 'حدث خطأ أثناء تحديث موقع المندوب',
        error: e,
      );
    }
  }

  // التحقق من دور المستخدم
  Future<void> _checkUserRole(String userId, String requiredRole) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userRole = userDoc.data()?['role'];
      
      if (userRole != requiredRole) {
        throw AuthorizationFailure(
          message: 'ليس لديك صلاحية كافية. الدور المطلوب: $requiredRole',
        );
      }
    } catch (e) {
      if (e is FirebaseFailure) rethrow;
      throw FirebaseFailure(
        message: 'حدث خطأ أثناء التحقق من الصلاحيات',
        error: e,
      );
    }
  }

  // التحقق من صلاحية تحديث الطلب
  Future<void> _checkOrderUpdatePermission(String orderId, String userId) async {
    try {
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();
      final orderData = orderDoc.data();
      
      if (orderData == null) {
        throw const NotFoundFailure(message: 'الطلب غير موجود');
      }

      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userRole = userDoc.data()?['role'];

      bool hasPermission = userRole == 'admin' || 
                          userId == orderData['customerId'] ||
                          userId == orderData['driverId'] ||
                          userId == orderData['restaurantId'];

      if (!hasPermission) {
        throw const AuthorizationFailure(
          message: 'ليس لديك صلاحية لتحديث هذا الطلب',
        );
      }
    } catch (e) {
      if (e is FirebaseFailure) rethrow;
      throw FirebaseFailure(
        message: 'حدث خطأ أثناء التحقق من صلاحيات تحديث الطلب',
        error: e,
      );
    }
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