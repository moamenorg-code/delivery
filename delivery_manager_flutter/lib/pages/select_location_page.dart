import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import '../../../shared_lib/lib/services/location_service.dart';
import '../../../shared_lib/lib/widgets/common_widgets.dart';

class SelectLocationPage extends StatefulWidget {
  const SelectLocationPage({Key? key}) : super(key: key);

  @override
  State<SelectLocationPage> createState() => _SelectLocationPageState();
}

class _SelectLocationPageState extends State<SelectLocationPage> {
  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  
  LatLng? _selectedLocation;
  String? _selectedAddress;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      final location = await _locationService.getCurrentLocation();
      _selectLocation(location);
      _mapController.move(location, 15);
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في الحصول على الموقع الحالي',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final location = await _locationService.getCoordinatesFromAddress(query);
      _selectLocation(location);
      _mapController.move(location, 15);
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في البحث عن العنوان',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectLocation(LatLng location) async {
    setState(() {
      _selectedLocation = location;
      _isLoading = true;
    });

    try {
      final address = await _locationService.getAddressFromCoordinates(location);
      setState(() => _selectedAddress = address);
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في الحصول على العنوان',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _confirmLocation() {
    if (_selectedLocation != null && _selectedAddress != null) {
      Get.back(result: {
        'location': _selectedLocation,
        'address': _selectedAddress,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر موقع التوصيل'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomTextField(
              label: 'ابحث عن عنوان',
              controller: _searchController,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  FocusScope.of(context).unfocus();
                },
              ),
              onSubmitted: _searchLocation,
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: const LatLng(30.0444, 31.2357), // Cairo
                    zoom: 13,
                    onTap: (_, point) => _selectLocation(point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    if (_selectedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedLocation!,
                            builder: (ctx) => const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          if (_selectedAddress != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _selectedAddress!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'تأكيد الموقع',
                    onPressed: _confirmLocation,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}