import 'package:json_annotation/json_annotation.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderModel {
  final String id;
  final String customerId;
  final String restaurantId;
  final String? driverId;
  final List<OrderItem> items;
  final String status;
  final double total;
  final double deliveryFee;
  final Location customerLocation;
  final Location restaurantLocation;
  final DateTime createdAt;
  final DateTime? deliveredAt;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.restaurantId,
    this.driverId,
    required this.items,
    required this.status,
    required this.total,
    required this.deliveryFee,
    required this.customerLocation,
    required this.restaurantLocation,
    required this.createdAt,
    this.deliveredAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);
}

@JsonSerializable()
class OrderItem {
  final String id;
  final String name;
  final int quantity;
  final double price;
  final Map<String, dynamic>? options;

  OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    this.options,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}

@JsonSerializable()
class Location {
  final double lat;
  final double lng;

  Location({
    required this.lat,
    required this.lng,
  });

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  Map<String, dynamic> toJson() => _$LocationToJson(this);
}