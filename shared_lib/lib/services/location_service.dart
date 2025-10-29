import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// خدمة إدارة المواقع والخرائط
class LocationService {
  static const String _nominatimBaseUrl = 'https://nominatim.openstreetmap.org';
  static const String _osrmBaseUrl = 'http://router.project-osrm.org';
  
  final http.Client _httpClient;
  
  LocationService({http.Client? httpClient}) 
      : _httpClient = httpClient ?? http.Client();

  /// التحقق من صلاحيات وخدمات الموقع
  Future<bool> checkLocationAvailability() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission != LocationPermission.denied && 
           permission != LocationPermission.deniedForever;
  }

  /// الحصول على الموقع الحالي
  Future<LatLng> getCurrentLocation() async {
    bool available = await checkLocationAvailability();
    if (!available) {
      throw LocationServiceException('Location services are not available');
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      throw LocationServiceException('Failed to get current location: $e');
    }
  }

  /// تحويل العنوان إلى إحداثيات
  Future<LatLng> getCoordinatesFromAddress(String address) async {
    try {
      final encodedAddress = Uri.encodeComponent(address);
      final response = await _httpClient.get(
        Uri.parse('$_nominatimBaseUrl/search?format=json&q=$encodedAddress'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        if (results.isNotEmpty) {
          final location = results.first;
          return LatLng(
            double.parse(location['lat']),
            double.parse(location['lon']),
          );
        }
      }
      throw LocationServiceException('Address not found');
    } catch (e) {
      throw LocationServiceException('Failed to get coordinates: $e');
    }
  }

  /// تحويل الإحداثيات إلى عنوان
  Future<String> getAddressFromCoordinates(LatLng coordinates) async {
    try {
      final response = await _httpClient.get(
        Uri.parse(
          '$_nominatimBaseUrl/reverse?format=json'
          '&lat=${coordinates.latitude}'
          '&lon=${coordinates.longitude}'
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'] ?? 'عنوان غير معروف';
      }
      throw LocationServiceException('Failed to get address');
    } catch (e) {
      throw LocationServiceException('Failed to get address: $e');
    }
  }

  /// حساب المسافة بين نقطتين
  double calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  /// تنسيق المسافة كنص مقروء
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} متر';
    } else {
      double kilometers = distanceInMeters / 1000;
      return '${kilometers.toStringAsFixed(1)} كم';
    }
  }

  /// الحصول على التوجيهات بين نقطتين
  Future<List<LatLng>> getDirections(LatLng start, LatLng end) async {
    try {
      final response = await _httpClient.get(
        Uri.parse(
          '$_osrmBaseUrl/route/v1/driving/'
          '${start.longitude},${start.latitude};'
          '${end.longitude},${end.latitude}'
          '?overview=full&geometries=geojson'
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 'Ok') {
          final coordinates = data['routes'][0]['geometry']['coordinates'] as List;
          return coordinates
              .map((coord) => LatLng(coord[1] as double, coord[0] as double))
              .toList();
        }
      }
      throw LocationServiceException('Failed to get directions');
    } catch (e) {
      throw LocationServiceException('Failed to get directions: $e');
    }
  }

  /// تنظيف الموارد
  void dispose() {
    _httpClient.close();
  }
}

/// استثناء خاص بخدمة المواقع
class LocationServiceException implements Exception {
  final String message;
  LocationServiceException(this.message);
  
  @override
  String toString() => message;
}