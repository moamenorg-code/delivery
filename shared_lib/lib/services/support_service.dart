import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/support_model.dart';

class SupportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // إنشاء تذكرة دعم جديدة
  Future<SupportTicket> createTicket({
    required String userId,
    required String type,
    required String subject,
    required String description,
    required String priority,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final ticketRef = _firestore.collection('support_tickets').doc();
      
      final ticket = SupportTicket(
        id: ticketRef.id,
        userId: userId,
        type: type,
        status: 'open',
        subject: subject,
        description: description,
        priority: priority,
        createdAt: DateTime.now(),
        metadata: metadata,
      );

      await ticketRef.set(ticket.toMap());
      return ticket;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // إضافة رسالة لتذكرة
  Future<void> addMessage({
    required String ticketId,
    required String senderId,
    required String content,
    required String type,
    required bool isStaff,
    Map<String, dynamic>? attachment,
  }) async {
    try {
      final message = TicketMessage(
        senderId: senderId,
        content: content,
        timestamp: DateTime.now(),
        type: type,
        isStaff: isStaff,
        attachment: attachment,
      );

      await _firestore.collection('support_tickets').doc(ticketId).update({
        'messages': FieldValue.arrayUnion([message.toMap()]),
        'lastUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  // تحديث حالة تذكرة
  Future<void> updateTicketStatus({
    required String ticketId,
    required String status,
    String? assignedTo,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
        'lastUpdate': FieldValue.serverTimestamp(),
      };

      if (status == 'resolved') {
        updates['resolvedAt'] = FieldValue.serverTimestamp();
      }

      if (assignedTo != null) {
        updates['assignedTo'] = assignedTo;
      }

      await _firestore
          .collection('support_tickets')
          .doc(ticketId)
          .update(updates);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // الحصول على تذاكر المستخدم
  Stream<List<SupportTicket>> getUserTickets(String userId) {
    return _firestore
        .collection('support_tickets')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => SupportTicket.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // الحصول على تذكرة محددة
  Stream<SupportTicket> getTicket(String ticketId) {
    return _firestore
        .collection('support_tickets')
        .doc(ticketId)
        .snapshots()
        .map((doc) => SupportTicket.fromMap(doc.data()!, doc.id));
  }

  // الحصول على التذاكر المفتوحة (للموظفين)
  Stream<List<SupportTicket>> getOpenTickets() {
    return _firestore
        .collection('support_tickets')
        .where('status', whereIn: ['open', 'in_progress'])
        .orderBy('priority', descending: true)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => SupportTicket.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // الحصول على التذاكر المسندة لموظف
  Stream<List<SupportTicket>> getAssignedTickets(String staffId) {
    return _firestore
        .collection('support_tickets')
        .where('assignedTo', isEqualTo: staffId)
        .where('status', isNotEqualTo: 'closed')
        .orderBy('status')
        .orderBy('priority', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => SupportTicket.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // إغلاق تذكرة
  Future<void> closeTicket(String ticketId, {String? resolution}) async {
    try {
      await _firestore.collection('support_tickets').doc(ticketId).update({
        'status': 'closed',
        'resolvedAt': FieldValue.serverTimestamp(),
        'resolution': resolution,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  // إعادة فتح تذكرة
  Future<void> reopenTicket(String ticketId) async {
    try {
      await _firestore.collection('support_tickets').doc(ticketId).update({
        'status': 'open',
        'resolvedAt': null,
        'resolution': null,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  // الحصول على إحصائيات الدعم
  Future<Map<String, dynamic>> getSupportStats() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      final tickets = await _firestore
          .collection('support_tickets')
          .where('createdAt', isGreaterThan: startOfDay)
          .get();

      int totalTickets = tickets.docs.length;
      int openTickets = 0;
      int resolvedTickets = 0;
      Map<String, int> ticketsByType = {};
      Map<String, int> ticketsByPriority = {};

      for (var doc in tickets.docs) {
        final data = doc.data();
        final status = data['status'];
        final type = data['type'];
        final priority = data['priority'];

        if (status == 'open' || status == 'in_progress') {
          openTickets++;
        } else if (status == 'resolved') {
          resolvedTickets++;
        }

        ticketsByType[type] = (ticketsByType[type] ?? 0) + 1;
        ticketsByPriority[priority] = (ticketsByPriority[priority] ?? 0) + 1;
      }

      return {
        'totalTickets': totalTickets,
        'openTickets': openTickets,
        'resolvedTickets': resolvedTickets,
        'ticketsByType': ticketsByType,
        'ticketsByPriority': ticketsByPriority,
      };
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic e) {
    if (e is FirebaseException) {
      switch (e.code) {
        case 'not-found':
          return 'التذكرة غير موجودة';
        case 'permission-denied':
          return 'ليس لديك صلاحية لهذا الإجراء';
        default:
          return 'حدث خطأ ما';
      }
    }
    return e.toString();
  }
}