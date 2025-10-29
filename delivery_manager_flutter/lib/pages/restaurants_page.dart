import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared_lib/lib/models/restaurant_model.dart';
import '../../../shared_lib/lib/widgets/common_widgets.dart';

class RestaurantsPage extends StatefulWidget {
  const RestaurantsPage({Key? key}) : super(key: key);

  @override
  State<RestaurantsPage> createState() => _RestaurantsPageState();
}

class _RestaurantsPageState extends State<RestaurantsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'الكل';
  List<RestaurantModel> _restaurants = [];
  bool _isLoading = false;
  
  final List<String> _categories = [
    'الكل',
    'مطاعم شرقية',
    'بيتزا',
    'برجر',
    'دجاج',
    'مشويات',
    'بحري',
    'حلويات',
  ];

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    setState(() => _isLoading = true);
    try {
      // TODO: تحميل المطاعم من Firestore
      // هذه بيانات تجريبية
      await Future.delayed(const Duration(seconds: 1));
      _restaurants = [
        RestaurantModel(
          id: '1',
          name: 'مطعم الشرق',
          description: 'أشهى المأكولات الشرقية',
          coverImage: 'https://example.com/image1.jpg',
          logoImage: 'https://example.com/logo1.jpg',
          categories: ['مطاعم شرقية'],
          location: {'lat': 30.0444, 'lng': 31.2357},
          workingHours: {
            'start': '10:00',
            'end': '22:00',
          },
          minOrderAmount: 50,
          deliveryFee: 10,
          avgDeliveryTime: 45,
        ),
        // يمكن إضافة المزيد من المطاعم هنا
      ];
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحميل المطاعم',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<RestaurantModel> get _filteredRestaurants {
    return _restaurants.where((restaurant) {
      final matchesSearch = restaurant.name
          .toLowerCase()
          .contains(_searchController.text.toLowerCase());
      final matchesCategory = _selectedCategory == 'الكل' ||
          restaurant.categories.contains(_selectedCategory);
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المطاعم'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomTextField(
              label: 'ابحث عن مطعم',
              controller: _searchController,
              prefixIcon: const Icon(Icons.search),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = category);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRestaurants.isEmpty
                    ? const Center(
                        child: Text('لا توجد مطاعم متاحة'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredRestaurants.length,
                        itemBuilder: (context, index) {
                          final restaurant = _filteredRestaurants[index];
                          return RestaurantCard(
                            name: restaurant.name,
                            image: restaurant.coverImage,
                            rating: restaurant.rating,
                            cuisine: restaurant.categories.first,
                            deliveryTime:
                                '${restaurant.avgDeliveryTime} دقيقة',
                            onTap: () {
                              // التنقل إلى صفحة تفاصيل المطعم
                              Get.toNamed(
                                '/restaurant/${restaurant.id}',
                                arguments: restaurant,
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}