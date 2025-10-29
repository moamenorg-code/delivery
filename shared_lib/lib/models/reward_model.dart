import 'package:cloud_firestore/cloud_firestore.dart';

class RewardPoint {
  final String id;
  final String userId;
  final int points;
  final String type; // earned, redeemed
  final String source; // order, referral, promotion
  final DateTime timestamp;
  final String? orderId;
  final String? description;

  RewardPoint({
    required this.id,
    required this.userId,
    required this.points,
    required this.type,
    required this.source,
    required this.timestamp,
    this.orderId,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'points': points,
      'type': type,
      'source': source,
      'timestamp': Timestamp.fromDate(timestamp),
      'orderId': orderId,
      'description': description,
    };
  }

  factory RewardPoint.fromMap(Map<String, dynamic> map, String id) {
    return RewardPoint(
      id: id,
      userId: map['userId'],
      points: map['points']?.toInt() ?? 0,
      type: map['type'] ?? '',
      source: map['source'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      orderId: map['orderId'],
      description: map['description'],
    );
  }
}

class RewardProgram {
  final String id;
  final String name;
  final String description;
  final Map<String, int> earnRules; // e.g., {'order': 10, 'referral': 50}
  final Map<String, int> redeemRules; // e.g., {'100': 10} (points: discount)
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;

  RewardProgram({
    required this.id,
    required this.name,
    required this.description,
    required this.earnRules,
    required this.redeemRules,
    required this.startDate,
    this.endDate,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'earnRules': earnRules,
      'redeemRules': redeemRules,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'isActive': isActive,
    };
  }

  factory RewardProgram.fromMap(Map<String, dynamic> map, String id) {
    return RewardProgram(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      earnRules: Map<String, int>.from(map['earnRules'] ?? {}),
      redeemRules: Map<String, int>.from(map['redeemRules'] ?? {}),
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: map['endDate'] != null 
          ? (map['endDate'] as Timestamp).toDate() 
          : null,
      isActive: map['isActive'] ?? true,
    );
  }
}