import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/home_page.dart';
import 'services/order_service.dart';
import 'services/driver_service.dart';
import 'controllers/home_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // تهيئة الخدمات
  final orderService = OrderService(
    baseUrl: 'http://localhost:3000',
    apiKey: 'your-api-key',
  );
  
  final driverService = DriverService(
    baseUrl: 'http://localhost:3000',
    apiKey: 'your-api-key',
  );

  // تسجيل الكونترولر
  Get.put(HomeController(
    orderService: orderService,
    driverService: driverService,
  ));

  runApp(const DeliveryManagerApp());
}

class DeliveryManagerApp extends StatelessWidget {
  const DeliveryManagerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'نظام إدارة التوصيل',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Tajawal',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      locale: const Locale('ar', 'SA'),
      fallbackLocale: const Locale('en', 'US'),
      defaultTransition: Transition.fade,
      home: const HomePage(),
      // يمكن إضافة المزيد من المسارات هنا
      getPages: [
        GetPage(name: '/', page: () => const HomePage()),
        // إضافة المزيد من المسارات عند الحاجة
      ],
    );
  }
}