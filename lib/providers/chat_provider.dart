import 'dart:io';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/chat_user.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  List<ChatUser> _users = [];
  List<ChatUser> get users => _users;

  String get currentUid => _chatService.currentUid;
  String get groupChatId => ChatService.groupChatId;

  void listenToUsers() {
    _chatService.getAllUsers().listen((users) {
      _users = users;
      notifyListeners();
    });
  }

  String getDmChatId(String otherUid) {
    return _chatService.getDmChatId(currentUid, otherUid);
  }

  Stream<List<ChatMessage>> getMessages(String chatId) {
    return _chatService.getMessages(chatId);
  }

  Future<void> sendTextMessage({
    required String chatId,
    required String text,
    required List<String> participants,
    required bool isGroup,
  }) async {
    if (text.trim().isEmpty) return;
    await _chatService.sendMessage(
      chatId: chatId,
      text: text.trim(),
      participants: participants,
      isGroup: isGroup,
    );
  }

  Future<void> sendImageMessage({
    required String chatId,
    required File image,
    required List<String> participants,
    required bool isGroup,
  }) async {
    final imageUrl = await _chatService.uploadChatImage(image, chatId);
    await _chatService.sendMessage(
      chatId: chatId,
      text: '',
      imageUrl: imageUrl,
      participants: participants,
      isGroup: isGroup,
    );
  }

  Stream getChatMeta(String chatId) {
    return _chatService.getChatMeta(chatId);
  }
}