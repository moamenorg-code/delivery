import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared_lib/lib/models/reward_model.dart';
import '../../../shared_lib/lib/services/reward_service.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({Key? key}) : super(key: key);

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  final RewardService _rewardService = RewardService();
  final String userId = 'current_user_id'; // يجب الحصول عليه من إدارة الحالة
  int _currentPoints = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRewardsData();
  }

  Future<void> _loadRewardsData() async {
    try {
      final points = await _rewardService.getCurrentPoints(userId);
      setState(() {
        _currentPoints = points;
        _isLoading = false;
      });
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحميل بيانات المكافآت',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المكافآت'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildPointsCard(),
                  _buildActivePrograms(),
                  _buildPointsHistory(),
                ],
              ),
            ),
    );
  }

  Widget _buildPointsCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'نقاطك الحالية',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentPoints.toString(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // عرض خيارات استبدال النقاط
                _showRedeemOptions();
              },
              child: const Text('استبدال النقاط'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivePrograms() {
    return StreamBuilder<List<RewardProgram>>(
      stream: _rewardService.getActivePrograms(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final programs = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'البرامج النشطة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: programs.length,
              itemBuilder: (context, index) {
                final program = programs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(program.name),
                    subtitle: Text(program.description),
                    trailing: TextButton(
                      onPressed: () {
                        // عرض تفاصيل البرنامج
                        _showProgramDetails(program);
                      },
                      child: const Text('التفاصيل'),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildPointsHistory() {
    return StreamBuilder<List<RewardPoint>>(
      stream: _rewardService.getPointsHistory(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final points = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'سجل النقاط',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: points.length,
              itemBuilder: (context, index) {
                final point = points[index];
                return ListTile(
                  leading: Icon(
                    point.type == 'earned'
                        ? Icons.add_circle
                        : Icons.remove_circle,
                    color: point.type == 'earned' ? Colors.green : Colors.red,
                  ),
                  title: Text(_getSourceTitle(point.source)),
                  subtitle: Text(_formatDateTime(point.timestamp)),
                  trailing: Text(
                    '${point.type == 'earned' ? '+' : '-'}${point.points}',
                    style: TextStyle(
                      color: point.type == 'earned' ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showRedeemOptions() {
    Get.dialog(
      AlertDialog(
        title: const Text('استبدال النقاط'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.local_offer),
              title: const Text('خصم 10 ريال'),
              subtitle: const Text('100 نقطة'),
              enabled: _currentPoints >= 100,
              onTap: () => _redeemPoints(100, 'discount_10'),
            ),
            ListTile(
              leading: const Icon(Icons.delivery_dining),
              title: const Text('توصيل مجاني'),
              subtitle: const Text('200 نقطة'),
              enabled: _currentPoints >= 200,
              onTap: () => _redeemPoints(200, 'free_delivery'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showProgramDetails(RewardProgram program) {
    Get.dialog(
      AlertDialog(
        title: Text(program.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(program.description),
            const SizedBox(height: 16),
            const Text(
              'كيفية كسب النقاط:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...program.earnRules.entries.map(
              (e) => ListTile(
                title: Text(_getSourceTitle(e.key)),
                trailing: Text('${e.value} نقطة'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Future<void> _redeemPoints(int points, String source) async {
    try {
      await _rewardService.redeemPoints(
        userId,
        points,
        source,
        description: 'استبدال نقاط مقابل ${_getSourceTitle(source)}',
      );
      Get.back();
      Get.snackbar(
        'تم',
        'تم استبدال النقاط بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      _loadRewardsData();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في استبدال النقاط',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  String _getSourceTitle(String source) {
    switch (source) {
      case 'order':
        return 'طلب';
      case 'referral':
        return 'دعوة صديق';
      case 'discount_10':
        return 'خصم 10 ريال';
      case 'free_delivery':
        return 'توصيل مجاني';
      default:
        return source;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}