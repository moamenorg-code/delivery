import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // تسجيل الدخول باستخدام البريد الإلكتروني
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // تحديث وقت آخر تسجيل دخول
      await _firestore.collection('users').doc(result.user!.uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      // جلب بيانات المستخدم
      final userData = await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .get();

      return UserModel.fromMap(userData.data()!, userData.id);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // إنشاء حساب جديد
  Future<UserModel> signUpWithEmail(
    String email,
    String password,
    String name,
    String phone,
    String role,
  ) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel(
        id: result.user!.uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
        createdAt: DateTime.now(),
      );

      // حفظ بيانات المستخدم في Firestore
      await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(user.toMap());

      return user;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // مسح البيانات المحلية
      await _auth.signOut();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // تحديث الملف الشخصي
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? profileImage,
    Map<String, dynamic>? address,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not logged in';

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (profileImage != null) updates['profileImage'] = profileImage;
      if (address != null) updates['address'] = address;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(updates);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // إعادة تعيين كلمة المرور
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // تحديث كلمة المرور
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not logged in';

      // إعادة المصادقة
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);

      // تحديث كلمة المرور
      await user.updatePassword(newPassword);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // الحصول على المستخدم الحالي
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userData = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      return UserModel.fromMap(userData.data()!, userData.id);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // معالجة أخطاء المصادقة
  String _handleAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'لم يتم العثور على المستخدم';
        case 'wrong-password':
          return 'كلمة المرور غير صحيحة';
        case 'email-already-in-use':
          return 'البريد الإلكتروني مستخدم بالفعل';
        case 'invalid-email':
          return 'البريد الإلكتروني غير صالح';
        case 'weak-password':
          return 'كلمة المرور ضعيفة';
        case 'operation-not-allowed':
          return 'العملية غير مسموح بها';
        default:
          return 'حدث خطأ ما';
      }
    }
    return e.toString();
  }
}