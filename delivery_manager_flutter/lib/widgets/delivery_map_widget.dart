import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/driver_model.dart';
import '../models/order_model.dart';

class DeliveryMapWidget extends StatelessWidget {
  final List<DriverModel>? drivers;
  final List<OrderModel>? orders;
  final Function(DriverModel)? onDriverTap;
  final Function(OrderModel)? onOrderTap;

  const DeliveryMapWidget({
    Key? key,
    this.drivers,
    this.orders,
    this.onDriverTap,
    this.onOrderTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(31.9539, 35.9106), // مركز عمان
        zoom: 12.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        // طبقة المندوبين
        if (drivers != null)
          MarkerLayer(
            markers: drivers!.map((driver) => Marker(
              point: LatLng(
                driver.currentLocation.lat,
                driver.currentLocation.lng,
              ),
              builder: (context) => GestureDetector(
                onTap: () => onDriverTap?.call(driver),
                child: Icon(
                  Icons.delivery_dining,
                  color: driver.isAvailable ? Colors.green : Colors.orange,
                  size: 30,
                ),
              ),
            )).toList(),
          ),
        // طبقة الطلبات
        if (orders != null)
          MarkerLayer(
            markers: orders!.map((order) => Marker(
              point: LatLng(
                order.customerLocation.lat,
                order.customerLocation.lng,
              ),
              builder: (context) => GestureDetector(
                onTap: () => onOrderTap?.call(order),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 30,
                ),
              ),
            )).toList(),
          ),
      ],
    );
  }
}