import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/chat_message.dart';
import '../models/chat_user.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String groupChatId = 'group_chat';

  String get currentUid => _auth.currentUser?.uid ?? '';

  /// Generates a deterministic chat ID for 1-on-1 chats
  String getDmChatId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return 'dm_${ids[0]}_${ids[1]}';
  }

  /// Get all users for chat list (excluding current user)
  Stream<List<ChatUser>> getAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.id != currentUid)
          .map((doc) => ChatUser.fromFirestore(doc.id, doc.data()))
          .toList();
    });
  }

  /// Get current user's name
  Future<String> getCurrentUserName() async {
    final doc = await _firestore.collection('users').doc(currentUid).get();
    final data = doc.data();
    if (data == null) return 'User';
    final name = data['name'];
    if (name != null && name.toString().isNotEmpty) return name;
    return data['email'] ?? 'User';
  }

  /// Stream of messages for a chat (group or DM)
  Stream<List<ChatMessage>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList());
  }

  /// Ensure chat document exists with participants
  Future<void> _ensureChatDoc(String chatId, List<String> participants, bool isGroup) async {
    final chatRef = _firestore.collection('chats').doc(chatId);
    final doc = await chatRef.get();
    if (!doc.exists) {
      await chatRef.set({
        'type': isGroup ? 'group' : 'dm',
        'participants': participants,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Send a text/image message
  Future<void> sendMessage({
    required String chatId,
    required String text,
    String? imageUrl,
    required List<String> participants,
    required bool isGroup,
  }) async {
    final senderName = await getCurrentUserName();

    await _ensureChatDoc(chatId, participants, isGroup);

    final message = ChatMessage(
      id: '',
      senderId: currentUid,
      senderName: senderName,
      text: text,
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
    );

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toFirestore());

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': imageUrl != null && text.isEmpty ? '📷 Photo' : text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  /// Upload image to Firebase Storage and return download URL
  Future<String> uploadChatImage(File imageFile, String chatId) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('chat_images/$chatId/$fileName');
    final uploadTask = await ref.putFile(imageFile);
    return await uploadTask.ref.getDownloadURL();
  }

  /// Get last message + time for a DM chat (for chat list previews)
  Stream<DocumentSnapshot> getChatMeta(String chatId) {
    return _firestore.collection('chats').doc(chatId).snapshots();
  }
}