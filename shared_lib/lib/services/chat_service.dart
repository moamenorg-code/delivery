import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late IO.Socket _socket;
  String? _currentUserId;

  // تهيئة الاتصال بالسوكت
  void initialize(String userId) {
    _currentUserId = userId;
    _socket = IO.io('YOUR_SOCKET_SERVER_URL', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {'userId': userId}
    });

    _setupSocketListeners();
    _socket.connect();
  }

  // إعداد مستمعي السوكت
  void _setupSocketListeners() {
    _socket.on('connect', (_) {
      print('Connected to chat server');
    });

    _socket.on('message', (data) {
      _handleNewMessage(data);
    });

    _socket.on('typing', (data) {
      // معالجة إشارة الكتابة
    });

    _socket.on('disconnect', (_) {
      print('Disconnected from chat server');
    });
  }

  // إرسال رسالة
  Future<void> sendMessage({
    required String chatId,
    required String receiverId,
    required String content,
    String type = 'text',
  }) async {
    if (_currentUserId == null) throw 'User not initialized';

    final message = {
      'chatId': chatId,
      'senderId': _currentUserId,
      'receiverId': receiverId,
      'content': content,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    };

    // حفظ الرسالة في Firestore
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message);

    // إرسال الرسالة عبر السوكت للتحديث الفوري
    _socket.emit('message', message);
  }

  // معالجة الرسائل الجديدة
  void _handleNewMessage(Map<String, dynamic> data) {
    // تحديث واجهة المستخدم
    // يمكن استخدام GetX أو Provider لإعلام الواجهة
  }

  // الحصول على محادثة
  Stream<QuerySnapshot> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // تحديث حالة القراءة
  Future<void> markAsRead(String chatId, String messageId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'read': true});
  }

  // إرسال إشارة الكتابة
  void sendTypingIndicator(String chatId, bool isTyping) {
    _socket.emit('typing', {
      'chatId': chatId,
      'userId': _currentUserId,
      'isTyping': isTyping,
    });
  }

  // إغلاق الاتصال
  void dispose() {
    _socket.disconnect();
  }
}