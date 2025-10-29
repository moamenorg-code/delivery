import 'package:get/get.dart';
import '../models/restaurant_model.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantController extends GetxController {
  static RestaurantController get to => Get.find();
  
  final _restaurants = <RestaurantModel>[].obs;
  final _filteredRestaurants = <RestaurantModel>[].obs;
  final _selectedCategory = 'الكل'.obs;
  final _isLoading = false.obs;
  final _hasMore = true.obs;
  final _searchQuery = ''.obs;
  
  List<RestaurantModel> get restaurants => _restaurants;
  List<RestaurantModel> get filteredRestaurants => _filteredRestaurants;
  String get selectedCategory => _selectedCategory.value;
  bool get isLoading => _isLoading.value;
  bool get hasMore => _hasMore.value;
  String get searchQuery => _searchQuery.value;

  final _firestore = FirebaseFirestore.instance;
  DocumentSnapshot? _lastDocument;
  static const int _limit = 10;

  @override
  void onInit() {
    super.onInit();
    loadRestaurants();
  }

  void setCategory(String category) {
    _selectedCategory.value = category;
    filterRestaurants();
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
    filterRestaurants();
  }

  Future<void> loadRestaurants() async {
    if (_isLoading.value || !_hasMore.value) return;

    _isLoading.value = true;
    try {
      var query = _firestore.collection('restaurants')
          .orderBy('rating', descending: true)
          .limit(_limit);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot = await query.get();
      
      if (snapshot.docs.isEmpty) {
        _hasMore.value = false;
        return;
      }

      final restaurants = snapshot.docs
          .map((doc) => RestaurantModel.fromMap(doc.data(), doc.id))
          .toList();

      _restaurants.addAll(restaurants);
      _lastDocument = snapshot.docs.last;
      
      filterRestaurants();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل المطاعم',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void filterRestaurants() {
    if (_selectedCategory.value == 'الكل' && _searchQuery.value.isEmpty) {
      _filteredRestaurants.value = _restaurants;
      return;
    }

    final query = _searchQuery.value.toLowerCase();
    _filteredRestaurants.value = _restaurants.where((restaurant) {
      final matchesCategory = _selectedCategory.value == 'الكل' ||
          restaurant.categories.contains(_selectedCategory.value);
      final matchesSearch = restaurant.name.toLowerCase().contains(query) ||
          restaurant.description.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void refreshRestaurants() {
    _restaurants.clear();
    _filteredRestaurants.clear();
    _lastDocument = null;
    _hasMore.value = true;
    loadRestaurants();
  }
}