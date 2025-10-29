import 'package:cloud_firestore/cloud_firestore.dart';

class SupportTicket {
  final String id;
  final String userId;
  final String type; // complaint, inquiry, technical
  final String status; // open, in_progress, resolved, closed
  final String subject;
  final String description;
  final String priority; // low, medium, high
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? assignedTo;
  final List<TicketMessage> messages;
  final Map<String, dynamic>? metadata;

  SupportTicket({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.subject,
    required this.description,
    required this.priority,
    required this.createdAt,
    this.resolvedAt,
    this.assignedTo,
    this.messages = const [],
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'status': status,
      'subject': subject,
      'description': description,
      'priority': priority,
      'createdAt': Timestamp.fromDate(createdAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'assignedTo': assignedTo,
      'messages': messages.map((m) => m.toMap()).toList(),
      'metadata': metadata,
    };
  }

  factory SupportTicket.fromMap(Map<String, dynamic> map, String id) {
    return SupportTicket(
      id: id,
      userId: map['userId'],
      type: map['type'] ?? '',
      status: map['status'] ?? '',
      subject: map['subject'] ?? '',
      description: map['description'] ?? '',
      priority: map['priority'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      resolvedAt: map['resolvedAt'] != null 
          ? (map['resolvedAt'] as Timestamp).toDate() 
          : null,
      assignedTo: map['assignedTo'],
      messages: List<TicketMessage>.from(
        map['messages']?.map((x) => TicketMessage.fromMap(x)) ?? [],
      ),
      metadata: map['metadata'],
    );
  }
}

class TicketMessage {
  final String senderId;
  final String content;
  final DateTime timestamp;
  final String type; // text, image
  final bool isStaff;
  final Map<String, dynamic>? attachment;

  TicketMessage({
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.type,
    required this.isStaff,
    this.attachment,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type,
      'isStaff': isStaff,
      'attachment': attachment,
    };
  }

  factory TicketMessage.fromMap(Map<String, dynamic> map) {
    return TicketMessage(
      senderId: map['senderId'],
      content: map['content'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      type: map['type'],
      isStaff: map['isStaff'] ?? false,
      attachment: map['attachment'],
    );
  }
}