import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared_lib/lib/models/support_model.dart';
import '../../../shared_lib/lib/services/support_service.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({Key? key}) : super(key: key);

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final SupportService _supportService = SupportService();
  final String userId = 'current_user_id'; // يجب الحصول عليه من إدارة الحالة

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الدعم الفني'),
      ),
      body: StreamBuilder<List<SupportTicket>>(
        stream: _supportService.getUserTickets(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('حدث خطأ: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tickets = snapshot.data!;
          if (tickets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('لا توجد تذاكر دعم'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _createNewTicket,
                    child: const Text('إنشاء تذكرة جديدة'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return _buildTicketCard(ticket);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewTicket,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTicketCard(SupportTicket ticket) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: _getStatusIcon(ticket.status),
        title: Text(ticket.subject),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getTicketType(ticket.type)),
            Text(
              _formatDateTime(ticket.createdAt),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(_getStatusText(ticket.status)),
          backgroundColor: _getStatusColor(ticket.status).withOpacity(0.1),
          labelStyle: TextStyle(
            color: _getStatusColor(ticket.status),
          ),
        ),
        onTap: () => _openTicketDetails(ticket),
      ),
    );
  }

  void _createNewTicket() {
    final formKey = GlobalKey<FormState>();
    String type = 'complaint';
    String priority = 'medium';
    final subjectController = TextEditingController();
    final descriptionController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('تذكرة دعم جديدة'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(
                    labelText: 'نوع المشكلة',
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'complaint',
                      child: Text(_getTicketType('complaint')),
                    ),
                    DropdownMenuItem(
                      value: 'inquiry',
                      child: Text(_getTicketType('inquiry')),
                    ),
                    DropdownMenuItem(
                      value: 'technical',
                      child: Text(_getTicketType('technical')),
                    ),
                  ],
                  onChanged: (value) => type = value!,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: priority,
                  decoration: const InputDecoration(
                    labelText: 'الأولوية',
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'low',
                      child: Text(_getPriorityText('low')),
                    ),
                    DropdownMenuItem(
                      value: 'medium',
                      child: Text(_getPriorityText('medium')),
                    ),
                    DropdownMenuItem(
                      value: 'high',
                      child: Text(_getPriorityText('high')),
                    ),
                  ],
                  onChanged: (value) => priority = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: subjectController,
                  decoration: const InputDecoration(
                    labelText: 'الموضوع',
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'الرجاء إدخال الموضوع';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'الوصف',
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'الرجاء إدخال الوصف';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                try {
                  await _supportService.createTicket(
                    userId: userId,
                    type: type,
                    subject: subjectController.text,
                    description: descriptionController.text,
                    priority: priority,
                  );
                  Get.back();
                  Get.snackbar(
                    'تم',
                    'تم إنشاء التذكرة بنجاح',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                } catch (e) {
                  Get.snackbar(
                    'خطأ',
                    'فشل في إنشاء التذكرة',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              }
            },
            child: const Text('إنشاء'),
          ),
        ],
      ),
    );
  }

  void _openTicketDetails(SupportTicket ticket) {
    Get.to(() => _SupportTicketDetailsPage(ticket: ticket));
  }

  Icon _getStatusIcon(String status) {
    switch (status) {
      case 'open':
        return const Icon(Icons.fiber_new, color: Colors.blue);
      case 'in_progress':
        return const Icon(Icons.pending, color: Colors.orange);
      case 'resolved':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'closed':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.help);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getTicketType(String type) {
    switch (type) {
      case 'complaint':
        return 'شكوى';
      case 'inquiry':
        return 'استفسار';
      case 'technical':
        return 'مشكلة تقنية';
      default:
        return type;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'open':
        return 'مفتوح';
      case 'in_progress':
        return 'قيد المعالجة';
      case 'resolved':
        return 'تم الحل';
      case 'closed':
        return 'مغلق';
      default:
        return status;
    }
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case 'low':
        return 'منخفضة';
      case 'medium':
        return 'متوسطة';
      case 'high':
        return 'عالية';
      default:
        return priority;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

class _SupportTicketDetailsPage extends StatelessWidget {
  final SupportTicket ticket;
  final TextEditingController _messageController = TextEditingController();
  final SupportService _supportService = SupportService();

  _SupportTicketDetailsPage({
    Key? key,
    required this.ticket,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تذكرة #${ticket.id}'),
      ),
      body: Column(
        children: [
          _buildTicketInfo(),
          Expanded(child: _buildMessagesList()),
          if (ticket.status != 'closed') _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildTicketInfo() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ticket.subject,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ticket.description,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return StreamBuilder<SupportTicket>(
      stream: _supportService.getTicket(ticket.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data!.messages;
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return _MessageBubble(message: message);
          },
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'اكتب رسالتك هنا...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    try {
      await _supportService.addMessage(
        ticketId: ticket.id,
        senderId: 'current_user_id',
        content: _messageController.text,
        type: 'text',
        isStaff: false,
      );
      _messageController.clear();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في إرسال الرسالة',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

class _MessageBubble extends StatelessWidget {
  final TicketMessage message;

  const _MessageBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isStaff
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 8,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isStaff
              ? Colors.grey[200]
              : Colors.blue[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDateTime(message.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute}';
  }
}