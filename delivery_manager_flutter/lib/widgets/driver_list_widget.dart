import 'package:flutter/material.dart';
import '../models/driver_model.dart';

class DriverListWidget extends StatelessWidget {
  final List<DriverModel>? drivers;
  final Function(DriverModel)? onDriverTap;
  final bool isCompact;

  const DriverListWidget({
    Key? key,
    this.drivers,
    this.onDriverTap,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (drivers == null || drivers!.isEmpty) {
      return const Center(
        child: Text('لا يوجد مندوبين'),
      );
    }

    return ListView.builder(
      itemCount: drivers!.length,
      itemBuilder: (context, index) {
        final driver = drivers![index];
        return DriverCard(
          driver: driver,
          onTap: () => onDriverTap?.call(driver),
          isCompact: isCompact,
        );
      },
    );
  }
}

class DriverCard extends StatelessWidget {
  final DriverModel driver;
  final VoidCallback? onTap;
  final bool isCompact;

  const DriverCard({
    Key? key,
    required this.driver,
    this.onTap,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    child: Text(driver.name[0]),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        if (!isCompact) ...[
                          const SizedBox(height: 4),
                          Text(driver.phone),
                        ],
                      ],
                    ),
                  ),
                  _buildStatusChip(driver.status),
                ],
              ),
              if (!isCompact) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(
                      'التقييم',
                      '${driver.rating}',
                      Icons.star,
                      Colors.amber,
                    ),
                    _buildStatColumn(
                      'عدد التوصيلات',
                      '${driver.totalDeliveries}',
                      Icons.delivery_dining,
                      Colors.blue,
                    ),
                    if (driver.currentOrderId != null)
                      _buildStatColumn(
                        'الطلب الحالي',
                        '#${driver.currentOrderId}',
                        Icons.shopping_bag,
                        Colors.purple,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'available':
        color = Colors.green;
        text = 'متاح';
        break;
      case 'busy':
        color = Colors.orange;
        text = 'مشغول';
        break;
      case 'offline':
        color = Colors.grey;
        text = 'غير متصل';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Chip(
      label: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }

  Widget _buildStatColumn(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}