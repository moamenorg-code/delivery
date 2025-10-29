import 'package:json_annotation/json_annotation.dart';
import 'order_model.dart';

part 'driver_model.g.dart';

@JsonSerializable()
class DriverModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String status;
  final Location currentLocation;
  final double rating;
  final int totalDeliveries;
  final String? currentOrderId;

  DriverModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.status,
    required this.currentLocation,
    required this.rating,
    required this.totalDeliveries,
    this.currentOrderId,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) =>
      _$DriverModelFromJson(json);

  Map<String, dynamic> toJson() => _$DriverModelToJson(this);

  bool get isAvailable => status == 'available';
}