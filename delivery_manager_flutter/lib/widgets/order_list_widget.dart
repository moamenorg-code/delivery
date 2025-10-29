import 'package:flutter/material.dart';
import '../models/order_model.dart';

class OrderListWidget extends StatelessWidget {
  final List<OrderModel>? orders;
  final Function(OrderModel)? onOrderTap;
  final bool isCompact;

  const OrderListWidget({
    Key? key,
    this.orders,
    this.onOrderTap,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (orders == null || orders!.isEmpty) {
      return const Center(
        child: Text('لا توجد طلبات'),
      );
    }

    return ListView.builder(
      itemCount: orders!.length,
      itemBuilder: (context, index) {
        final order = orders![index];
        return OrderCard(
          order: order,
          onTap: () => onOrderTap?.call(order),
          isCompact: isCompact,
        );
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;
  final bool isCompact;

  const OrderCard({
    Key? key,
    required this.order,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'طلب #${order.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              if (!isCompact) ...[
                const SizedBox(height: 8),
                Text('العميل: ${order.customerId}'),
                const SizedBox(height: 4),
                Text('المطعم: ${order.restaurantId}'),
                const SizedBox(height: 8),
                _buildItemsList(order.items),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الإجمالي: \$${order.total}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!isCompact)
                    Text(
                      'رسوم التوصيل: \$${order.deliveryFee}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
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
      case 'pending':
        color = Colors.orange;
        text = 'قيد الانتظار';
        break;
      case 'accepted':
        color = Colors.blue;
        text = 'تم القبول';
        break;
      case 'picked_up':
        color = Colors.purple;
        text = 'تم الاستلام';
        break;
      case 'delivered':
        color = Colors.green;
        text = 'تم التوصيل';
        break;
      case 'cancelled':
        color = Colors.red;
        text = 'ملغي';
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

  Widget _buildItemsList(List<OrderItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          '${item.quantity}x ${item.name} (\$${item.price})',
          style: TextStyle(color: Colors.grey[600]),
        ),
      )).toList(),
    );
  }
}