import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../widgets/order_list_widget.dart';
import '../widgets/driver_list_widget.dart';
import '../widgets/delivery_map_widget.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Get.toNamed('/profile'),
          ),
        ],
      ),
      body: Row(
        children: [
          // القائمة الجانبية
          NavigationRail(
            selectedIndex: controller.selectedIndex,
            onDestinationSelected: controller.changeIndex,
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('لوحة التحكم'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.delivery_dining),
                label: Text('الطلبات'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('المندوبين'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.restaurant),
                label: Text('المطاعم'),
              ),
            ],
          ),
          
          // المحتوى الرئيسي
          Expanded(
            child: Obx(() {
              switch (controller.selectedIndex) {
                case 0:
                  return _buildDashboard();
                case 1:
                  return const OrderListWidget();
                case 2:
                  return const DriverListWidget();
                case 3:
                  return const RestaurantsPage();
                default:
                  return const SizedBox();
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return Row(
      children: [
        // الإحصائيات والمعلومات
        Expanded(
          flex: 2,
          child: Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'نظرة عامة',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatsGrid(),
                  const SizedBox(height: 16),
                  const Text(
                    'الطلبات النشطة',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Obx(() => ListView.builder(
                      itemCount: controller.activeOrders.length,
                      itemBuilder: (context, index) {
                        final order = controller.activeOrders[index];
                        return ListTile(
                          title: Text('طلب #${order.id}'),
                          subtitle: Text(order.status),
                          trailing: Text('\$${order.total}'),
                          onTap: () => controller.viewOrderDetails(order),
                        );
                      },
                    )),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // خريطة التتبع
        Expanded(
          flex: 3,
          child: Card(
            margin: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'خريطة التتبع المباشر',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: DeliveryMapWidget(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: 2,
      children: [
        _buildStatCard(
          'الطلبات اليوم',
          controller.todayOrders.toString(),
          Icons.shopping_bag,
        ),
        _buildStatCard(
          'المندوبين النشطين',
          controller.activeDrivers.toString(),
          Icons.delivery_dining,
        ),
        _buildStatCard(
          'إجمالي المبيعات',
          '\$${controller.totalSales}',
          Icons.attach_money,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}