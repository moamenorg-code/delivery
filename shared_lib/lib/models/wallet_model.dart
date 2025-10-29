import 'package:cloud_firestore/cloud_firestore.dart';

class WalletTransaction {
  final String id;
  final String userId;
  final double amount;
  final String type; // deposit, withdrawal, order_payment, refund
  final String status; // pending, completed, failed
  final DateTime timestamp;
  final String? reference;
  final String? description;

  WalletTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.status,
    required this.timestamp,
    this.reference,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'type': type,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
      'reference': reference,
      'description': description,
    };
  }

  factory WalletTransaction.fromMap(Map<String, dynamic> map, String id) {
    return WalletTransaction(
      id: id,
      userId: map['userId'],
      amount: map['amount']?.toDouble() ?? 0.0,
      type: map['type'] ?? '',
      status: map['status'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      reference: map['reference'],
      description: map['description'],
    );
  }
}