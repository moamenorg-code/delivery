import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantModel {
  final String id;
  final String name;
  final String description;
  final String coverImage;
  final String logoImage;
  final List<String> categories;
  final Map<String, dynamic> location;
  final Map<String, dynamic> workingHours;
  final double rating;
  final int totalRatings;
  final int totalOrders;
  final double minOrderAmount;
  final double deliveryFee;
  final int avgDeliveryTime;
  final bool isActive;
  final List<String> features; // takeaway, delivery, etc.
  final Map<String, dynamic> settings;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.description,
    required this.coverImage,
    required this.logoImage,
    required this.categories,
    required this.location,
    required this.workingHours,
    this.rating = 0,
    this.totalRatings = 0,
    this.totalOrders = 0,
    required this.minOrderAmount,
    required this.deliveryFee,
    required this.avgDeliveryTime,
    this.isActive = true,
    this.features = const [],
    this.settings = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'coverImage': coverImage,
      'logoImage': logoImage,
      'categories': categories,
      'location': location,
      'workingHours': workingHours,
      'rating': rating,
      'totalRatings': totalRatings,
      'totalOrders': totalOrders,
      'minOrderAmount': minOrderAmount,
      'deliveryFee': deliveryFee,
      'avgDeliveryTime': avgDeliveryTime,
      'isActive': isActive,
      'features': features,
      'settings': settings,
    };
  }

  factory RestaurantModel.fromMap(Map<String, dynamic> map, String id) {
    return RestaurantModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      coverImage: map['coverImage'] ?? '',
      logoImage: map['logoImage'] ?? '',
      categories: List<String>.from(map['categories'] ?? []),
      location: Map<String, dynamic>.from(map['location'] ?? {}),
      workingHours: Map<String, dynamic>.from(map['workingHours'] ?? {}),
      rating: map['rating']?.toDouble() ?? 0.0,
      totalRatings: map['totalRatings']?.toInt() ?? 0,
      totalOrders: map['totalOrders']?.toInt() ?? 0,
      minOrderAmount: map['minOrderAmount']?.toDouble() ?? 0.0,
      deliveryFee: map['deliveryFee']?.toDouble() ?? 0.0,
      avgDeliveryTime: map['avgDeliveryTime']?.toInt() ?? 30,
      isActive: map['isActive'] ?? true,
      features: List<String>.from(map['features'] ?? []),
      settings: Map<String, dynamic>.from(map['settings'] ?? {}),
    );
  }
}