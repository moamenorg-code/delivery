import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared_lib/lib/models/wallet_model.dart';
import '../../../shared_lib/lib/services/wallet_service.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final WalletService _walletService = WalletService();
  final String userId = 'current_user_id'; // يجب الحصول عليه من إدارة الحالة
  double _currentBalance = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    try {
      final balance = await _walletService.getCurrentBalance(userId);
      setState(() {
        _currentBalance = balance;
        _isLoading = false;
      });
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحميل بيانات المحفظة',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _addBalance() async {
    final result = await Get.dialog<double>(
      AlertDialog(
        title: const Text('إضافة رصيد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'المبلغ',
                prefixText: 'ر.س ',
              ),
              onSubmitted: (value) {
                Get.back(result: double.tryParse(value));
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              // هنا يمكن إضافة منطق التحقق من البطاقة
              Get.back(result: 100.0); // مثال
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );

    if (result != null && result > 0) {
      try {
        await _walletService.addBalance(
          userId,
          result,
          'deposit',
          description: 'إيداع مباشر',
        );
        _loadWalletData();
        Get.snackbar(
          'تم',
          'تمت إضافة الرصيد بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'خطأ',
          'فشل في إضافة الرصيد',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المحفظة'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildBalanceCard(),
                  _buildTransactionsList(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addBalance,
        icon: const Icon(Icons.add),
        label: const Text('إضافة رصيد'),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'الرصيد الحالي',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_currentBalance.toStringAsFixed(2)} ر.س',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    return StreamBuilder<List<WalletTransaction>>(
      stream: _walletService.getTransactions(userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('حدث خطأ: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final transactions = snapshot.data!;
        if (transactions.isEmpty) {
          return const Center(
            child: Text('لا توجد معاملات'),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return ListTile(
              leading: Icon(
                transaction.amount > 0
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                color: transaction.amount > 0 ? Colors.green : Colors.red,
              ),
              title: Text(_getTransactionTitle(transaction.type)),
              subtitle: Text(
                _formatDateTime(transaction.timestamp),
              ),
              trailing: Text(
                '${transaction.amount.abs().toStringAsFixed(2)} ر.س',
                style: TextStyle(
                  color: transaction.amount > 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getTransactionTitle(String type) {
    switch (type) {
      case 'deposit':
        return 'إيداع';
      case 'withdrawal':
        return 'سحب';
      case 'order_payment':
        return 'دفع طلب';
      case 'refund':
        return 'استرداد';
      default:
        return type;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
}