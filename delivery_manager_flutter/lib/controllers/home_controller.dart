import 'package:get/get.dart';
import '../models/order_model.dart';
import '../models/driver_model.dart';
import '../services/order_service.dart';
import '../services/driver_service.dart';

class HomeController extends GetxController {
  final OrderService _orderService;
  final DriverService _driverService;

  HomeController({
    required OrderService orderService,
    required DriverService driverService,
  })  : _orderService = orderService,
        _driverService = driverService;

  // المتغيرات التفاعلية
  final _selectedIndex = 0.obs;
  final _activeOrders = <OrderModel>[].obs;
  final _activeDrivers = <DriverModel>[].obs;
  final _todayOrders = 0.obs;
  final _totalSales = 0.0.obs;

  // الخصائص
  int get selectedIndex => _selectedIndex.value;
  List<OrderModel> get activeOrders => _activeOrders;
  List<DriverModel> get activeDrivers => _activeDrivers;
  int get todayOrders => _todayOrders.value;
  double get totalSales => _totalSales.value;

  @override
  void onInit() {
    super.onInit();
    refreshData();
    // بدء الاستماع للتحديثات المباشرة
    _startRealtimeUpdates();
  }

  // تحديث البيانات
  Future<void> refreshData() async {
    try {
      // تحديث الطلبات النشطة
      final orders = await _orderService.getActiveOrders();
      _activeOrders.assignAll(orders);

      // تحديث المندوبين النشطين
      final drivers = await _driverService.getActiveDrivers();
      _activeDrivers.assignAll(drivers);

      // تحديث الإحصائيات
      await _updateStats();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحديث البيانات',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // تغيير التبويب المحدد
  void changeIndex(int index) {
    _selectedIndex.value = index;
  }

  // عرض تفاصيل الطلب
  void viewOrderDetails(OrderModel order) {
    Get.toNamed('/order-details', arguments: order);
  }

  // تحديث الإحصائيات
  Future<void> _updateStats() async {
    try {
      final stats = await _orderService.getTodayStats();
      _todayOrders.value = stats.totalOrders;
      _totalSales.value = stats.totalSales;
    } catch (e) {
      print('Error updating stats: $e');
    }
  }

  // بدء الاستماع للتحديثات المباشرة
  void _startRealtimeUpdates() {
    // الاستماع لتحديثات الطلبات
    _orderService.listenToActiveOrders().listen(
      (orders) {
        _activeOrders.assignAll(orders);
        _updateStats();
      },
      onError: (error) {
        print('Error in orders stream: $error');
      },
    );

    // الاستماع لتحديثات المندوبين
    _driverService.listenToActiveDrivers().listen(
      (drivers) {
        _activeDrivers.assignAll(drivers);
      },
      onError: (error) {
        print('Error in drivers stream: $error');
      },
    );
  }

  @override
  void onClose() {
    // إيقاف الاستماع للتحديثات عند إغلاق الكونترولر
    super.onClose();
  }
}