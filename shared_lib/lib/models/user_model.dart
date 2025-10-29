import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // customer, driver, admin
  final String? profileImage;
  final String? fcmToken;
  final Map<String, dynamic>? address;
  final double? rating;
  final int points;
  final double walletBalance;
  final List<String> favoriteRestaurants;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;
  final String? language;
  final bool darkMode;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImage,
    this.fcmToken,
    this.address,
    this.rating,
    this.points = 0,
    this.walletBalance = 0.0,
    this.favoriteRestaurants = const [],
    this.preferences = const {},
    required this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
    this.language = 'ar',
    this.darkMode = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'profileImage': profileImage,
      'fcmToken': fcmToken,
      'address': address,
      'rating': rating,
      'points': points,
      'walletBalance': walletBalance,
      'favoriteRestaurants': favoriteRestaurants,
      'preferences': preferences,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'isActive': isActive,
      'language': language,
      'darkMode': darkMode,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'customer',
      profileImage: map['profileImage'],
      fcmToken: map['fcmToken'],
      address: map['address'],
      rating: map['rating']?.toDouble(),
      points: map['points']?.toInt() ?? 0,
      walletBalance: map['walletBalance']?.toDouble() ?? 0.0,
      favoriteRestaurants: List<String>.from(map['favoriteRestaurants'] ?? []),
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastLoginAt: map['lastLoginAt'] != null 
          ? (map['lastLoginAt'] as Timestamp).toDate()
          : null,
      isActive: map['isActive'] ?? true,
      language: map['language'] ?? 'ar',
      darkMode: map['darkMode'] ?? false,
    );
  }
}