import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared_lib/lib/models/restaurant_model.dart';
import '../../../shared_lib/lib/widgets/common_widgets.dart';

class RestaurantDetailsPage extends StatefulWidget {
  final RestaurantModel restaurant;

  const RestaurantDetailsPage({
    Key? key,
    required this.restaurant,
  }) : super(key: key);

  @override
  State<RestaurantDetailsPage> createState() => _RestaurantDetailsPageState();
}

class _RestaurantDetailsPageState extends State<RestaurantDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_isCollapsed) {
      setState(() => _isCollapsed = true);
    } else if (_scrollController.offset <= 200 && _isCollapsed) {
      setState(() => _isCollapsed = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: _isCollapsed
                    ? Text(widget.restaurant.name)
                    : const SizedBox(),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      widget.restaurant.coverImage,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    if (!_isCollapsed)
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.restaurant.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  widget.restaurant.rating.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Icon(
                                  Icons.access_time,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${widget.restaurant.avgDeliveryTime} دقيقة',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'الوجبات'),
                    Tab(text: 'التقييمات'),
                    Tab(text: 'المعلومات'),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _MenuTab(restaurant: widget.restaurant),
            _ReviewsTab(restaurant: widget.restaurant),
            _InfoTab(restaurant: widget.restaurant),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: CustomButton(
          text: 'عرض السلة',
          onPressed: () {
            // التنقل إلى صفحة السلة
            Get.toNamed('/cart');
          },
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class _MenuTab extends StatelessWidget {
  final RestaurantModel restaurant;

  const _MenuTab({
    Key? key,
    required this.restaurant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: تحميل قائمة المنتجات من Firestore
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 10, // عدد تجريبي
      itemBuilder: (context, index) {
        return ProductCard(
          name: 'وجبة $index',
          image: 'https://example.com/product$index.jpg',
          description: 'وصف الوجبة هنا',
          price: 49.99,
          onAddToCart: () {
            // إضافة المنتج للسلة
            Get.snackbar(
              'تم',
              'تمت إضافة المنتج للسلة',
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          },
        );
      },
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  final RestaurantModel restaurant;

  const _ReviewsTab({
    Key? key,
    required this.restaurant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: تحميل التقييمات من Firestore
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10, // عدد تجريبي
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      child: Text('U${index + 1}'),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مستخدم ${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              Icons.star,
                              size: 16,
                              color: i < 4 ? Colors.amber : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'تقييم رائع للمطعم! الطعام لذيذ والخدمة ممتازة.',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoTab extends StatelessWidget {
  final RestaurantModel restaurant;

  const _InfoTab({
    Key? key,
    required this.restaurant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'معلومات المطعم',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                _InfoItem(
                  icon: Icons.access_time,
                  title: 'ساعات العمل',
                  subtitle:
                      '${widget.restaurant.workingHours['start']} - ${widget.restaurant.workingHours['end']}',
                ),
                _InfoItem(
                  icon: Icons.delivery_dining,
                  title: 'رسوم التوصيل',
                  subtitle: '${widget.restaurant.deliveryFee} ريال',
                ),
                _InfoItem(
                  icon: Icons.shopping_cart,
                  title: 'الحد الأدنى للطلب',
                  subtitle: '${widget.restaurant.minOrderAmount} ريال',
                ),
                _InfoItem(
                  icon: Icons.location_on,
                  title: 'العنوان',
                  subtitle: 'عنوان المطعم هنا',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}