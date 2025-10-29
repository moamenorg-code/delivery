import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  // الحصول على الموقع الحالي
  Future<LatLng> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // التحقق من تفعيل خدمة الموقع
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    // التحقق من الأذونات
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied';
    }

    // الحصول على الموقع
    final position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  // تحويل العنوان إلى إحداثيات
  Future<LatLng> getCoordinatesFromAddress(String address) async {
    // يمكن استخدام Nominatim API (خدمة OpenStreetMap للبحث عن العناوين)
    final url = 'https://nominatim.openstreetmap.org/search?format=json&q=$address';
    // TODO: استخدام http package للحصول على الإحداثيات
    // هذه قيم افتراضية للمثال
    return const LatLng(30.0444, 31.2357);
  }

  // تحويل الإحداثيات إلى عنوان
  Future<String> getAddressFromCoordinates(LatLng coordinates) async {
    final url = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=${coordinates.latitude}&lon=${coordinates.longitude}';
    // TODO: استخدام http package للحصول على العنوان
    // هذا عنوان افتراضي للمثال
    return 'القاهرة، مصر';
  }

  // حساب المسافة بين نقطتين
  double calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  // الحصول على التوجيهات بين نقطتين
  Future<List<LatLng>> getDirections(LatLng start, LatLng end) async {
    // يمكن استخدام OSRM API للحصول على المسار
    final url = 'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';
    // TODO: استخدام http package للحصول على المسار
    // هذه قيم افتراضية للمثال
    return [
      start,
      const LatLng(30.0444, 31.2357),
      end,
    ];
  }
}