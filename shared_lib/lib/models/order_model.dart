import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String customerId;
  final String? driverId;
  final String restaurantId;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final String status; // pending, accepted, picking, delivering, delivered, cancelled
  final Map<String, dynamic> deliveryAddress;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? transactionId;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? pickedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final String? cancelReason;
  final double? customerRating;
  final String? customerReview;
  final double? driverRating;
  final String? driverReview;
  final List<OrderStatusUpdate> statusUpdates;
  final List<OrderIssue> issues;

  OrderModel({
    required this.id,
    required this.customerId,
    this.driverId,
    required this.restaurantId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    this.discount = 0,
    required this.total,
    required this.status,
    required this.deliveryAddress,
    this.paymentMethod,
    this.paymentStatus,
    this.transactionId,
    required this.createdAt,
    this.acceptedAt,
    this.pickedAt,
    this.deliveredAt,
    this.cancelledAt,
    this.cancelReason,
    this.customerRating,
    this.customerReview,
    this.driverRating,
    this.driverReview,
    this.statusUpdates = const [],
    this.issues = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'driverId': driverId,
      'restaurantId': restaurantId,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'total': total,
      'status': status,
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'transactionId': transactionId,
      'createdAt': Timestamp.fromDate(createdAt),
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'pickedAt': pickedAt != null ? Timestamp.fromDate(pickedAt!) : null,
      'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'cancelReason': cancelReason,
      'customerRating': customerRating,
      'customerReview': customerReview,
      'driverRating': driverRating,
      'driverReview': driverReview,
      'statusUpdates': statusUpdates.map((update) => update.toMap()).toList(),
      'issues': issues.map((issue) => issue.toMap()).toList(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      customerId: map['customerId'],
      driverId: map['driverId'],
      restaurantId: map['restaurantId'],
      items: List<OrderItem>.from(
        map['items']?.map((x) => OrderItem.fromMap(x)) ?? [],
      ),
      subtotal: map['subtotal']?.toDouble() ?? 0.0,
      deliveryFee: map['deliveryFee']?.toDouble() ?? 0.0,
      discount: map['discount']?.toDouble() ?? 0.0,
      total: map['total']?.toDouble() ?? 0.0,
      status: map['status'] ?? 'pending',
      deliveryAddress: Map<String, dynamic>.from(map['deliveryAddress'] ?? {}),
      paymentMethod: map['paymentMethod'],
      paymentStatus: map['paymentStatus'],
      transactionId: map['transactionId'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      acceptedAt: map['acceptedAt'] != null 
          ? (map['acceptedAt'] as Timestamp).toDate()
          : null,
      pickedAt: map['pickedAt'] != null 
          ? (map['pickedAt'] as Timestamp).toDate()
          : null,
      deliveredAt: map['deliveredAt'] != null 
          ? (map['deliveredAt'] as Timestamp).toDate()
          : null,
      cancelledAt: map['cancelledAt'] != null 
          ? (map['cancelledAt'] as Timestamp).toDate()
          : null,
      cancelReason: map['cancelReason'],
      customerRating: map['customerRating']?.toDouble(),
      customerReview: map['customerReview'],
      driverRating: map['driverRating']?.toDouble(),
      driverReview: map['driverReview'],
      statusUpdates: List<OrderStatusUpdate>.from(
        map['statusUpdates']?.map((x) => OrderStatusUpdate.fromMap(x)) ?? [],
      ),
      issues: List<OrderIssue>.from(
        map['issues']?.map((x) => OrderIssue.fromMap(x)) ?? [],
      ),
    );
  }
}

class OrderItem {
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final double total;
  final List<String> options;
  final String? notes;

  OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
    this.options = const [],
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'total': total,
      'options': options,
      'notes': notes,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'],
      name: map['name'],
      quantity: map['quantity']?.toInt() ?? 0,
      price: map['price']?.toDouble() ?? 0.0,
      total: map['total']?.toDouble() ?? 0.0,
      options: List<String>.from(map['options'] ?? []),
      notes: map['notes'],
    );
  }
}

class OrderStatusUpdate {
  final String status;
  final String? note;
  final DateTime timestamp;
  final String updatedBy;

  OrderStatusUpdate({
    required this.status,
    this.note,
    required this.timestamp,
    required this.updatedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'note': note,
      'timestamp': Timestamp.fromDate(timestamp),
      'updatedBy': updatedBy,
    };
  }

  factory OrderStatusUpdate.fromMap(Map<String, dynamic> map) {
    return OrderStatusUpdate(
      status: map['status'],
      note: map['note'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      updatedBy: map['updatedBy'],
    );
  }
}

class OrderIssue {
  final String type; // complaint, refund, etc.
  final String description;
  final String status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? resolution;

  OrderIssue({
    required this.type,
    required this.description,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
    this.resolution,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'description': description,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'resolution': resolution,
    };
  }

  factory OrderIssue.fromMap(Map<String, dynamic> map) {
    return OrderIssue(
      type: map['type'],
      description: map['description'],
      status: map['status'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      resolvedAt: map['resolvedAt'] != null 
          ? (map['resolvedAt'] as Timestamp).toDate()
          : null,
      resolution: map['resolution'],
    );
  }
}