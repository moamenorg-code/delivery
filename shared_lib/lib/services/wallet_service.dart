import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wallet_model.dart';

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // إضافة رصيد للمحفظة
  Future<WalletTransaction> addBalance(
    String userId,
    double amount,
    String type,
    {String? reference, String? description}
  ) async {
    try {
      final batch = _firestore.batch();
      
      // إنشاء المعاملة
      final transactionRef = _firestore.collection('wallet_transactions').doc();
      final transaction = WalletTransaction(
        id: transactionRef.id,
        userId: userId,
        amount: amount,
        type: type,
        status: 'completed',
        timestamp: DateTime.now(),
        reference: reference,
        description: description,
      );

      batch.set(transactionRef, transaction.toMap());

      // تحديث رصيد المحفظة
      final userRef = _firestore.collection('users').doc(userId);
      batch.update(userRef, {
        'walletBalance': FieldValue.increment(amount),
      });

      await batch.commit();
      return transaction;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // خصم رصيد من المحفظة
  Future<WalletTransaction> deductBalance(
    String userId,
    double amount,
    String type,
    {String? reference, String? description}
  ) async {
    try {
      // التحقق من كفاية الرصيد
      final user = await _firestore.collection('users').doc(userId).get();
      final currentBalance = user.data()?['walletBalance'] ?? 0.0;
      
      if (currentBalance < amount) {
        throw 'Insufficient balance';
      }

      final batch = _firestore.batch();
      
      // إنشاء المعاملة
      final transactionRef = _firestore.collection('wallet_transactions').doc();
      final transaction = WalletTransaction(
        id: transactionRef.id,
        userId: userId,
        amount: -amount, // قيمة سالبة للخصم
        type: type,
        status: 'completed',
        timestamp: DateTime.now(),
        reference: reference,
        description: description,
      );

      batch.set(transactionRef, transaction.toMap());

      // تحديث رصيد المحفظة
      batch.update(user.reference, {
        'walletBalance': FieldValue.increment(-amount),
      });

      await batch.commit();
      return transaction;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // الحصول على المعاملات
  Stream<List<WalletTransaction>> getTransactions(String userId) {
    return _firestore
        .collection('wallet_transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => WalletTransaction.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // الحصول على الرصيد الحالي
  Future<double> getCurrentBalance(String userId) async {
    try {
      final user = await _firestore.collection('users').doc(userId).get();
      return user.data()?['walletBalance']?.toDouble() ?? 0.0;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // تعليق معاملة
  Future<void> holdTransaction(String transactionId) async {
    try {
      await _firestore
          .collection('wallet_transactions')
          .doc(transactionId)
          .update({'status': 'held'});
    } catch (e) {
      throw _handleError(e);
    }
  }

  // استرداد معاملة
  Future<void> refundTransaction(String transactionId) async {
    try {
      final transaction = await _firestore
          .collection('wallet_transactions')
          .doc(transactionId)
          .get();
      
      final data = transaction.data()!;
      if (data['type'] != 'payment') {
        throw 'Only payment transactions can be refunded';
      }

      final batch = _firestore.batch();

      // تحديث حالة المعاملة الأصلية
      batch.update(transaction.reference, {'status': 'refunded'});

      // إنشاء معاملة استرداد جديدة
      final refundRef = _firestore.collection('wallet_transactions').doc();
      final refund = WalletTransaction(
        id: refundRef.id,
        userId: data['userId'],
        amount: data['amount'].abs(), // تحويل القيمة لموجبة
        type: 'refund',
        status: 'completed',
        timestamp: DateTime.now(),
        reference: transactionId,
        description: 'Refund for transaction ${transaction.id}',
      );

      batch.set(refundRef, refund.toMap());

      // تحديث رصيد المحفظة
      final userRef = _firestore.collection('users').doc(data['userId']);
      batch.update(userRef, {
        'walletBalance': FieldValue.increment(data['amount'].abs()),
      });

      await batch.commit();
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic e) {
    if (e is FirebaseException) {
      switch (e.code) {
        case 'not-found':
          return 'المعاملة غير موجودة';
        case 'permission-denied':
          return 'ليس لديك صلاحية لهذا الإجراء';
        default:
          return 'حدث خطأ ما';
      }
    }
    return e.toString();
  }
}