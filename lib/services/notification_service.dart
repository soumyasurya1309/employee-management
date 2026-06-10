import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final AuthService _authService = AuthService();

  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static const String _backendUrl = 'https://emp-backend-754m.onrender.com';

  Future<void> initialize() async {
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((message) {
      final title = message.notification?.title ?? 'Notification';
      final body = message.notification?.body ?? '';
      _showSnackbar(title, body, Colors.blue);
    });

    _fcm.onTokenRefresh.listen((token) async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await _authService.saveFcmToken(uid);
      }
    });

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _authService.saveFcmToken(uid);
    }

    final token = await _fcm.getToken();
    // ignore: avoid_print
    print('FCM Token: $token');
  }

  void _showSnackbar(String title, String body, Color color) {
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  if (body.isNotEmpty)
                    Text(body,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _sendPushToAllDevices({
    required String title,
    required String body,
  }) async {
    try {
      await http.post(
        Uri.parse('$_backendUrl/send-notification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': title, 'body': body}),
      );
    } catch (e) {
      // ignore: avoid_print
      print('Push notification error: $e');
    }
  }

  Future<void> notifyEmployeeAdded(String name) async {
    _showSnackbar(
      '✅ Employee Added',
      '$name has been successfully added.',
      const Color(0xFF34A853),
    );
    await _sendPushToAllDevices(
      title: '✅ Employee Added',
      body: '$name has been successfully added to the system.',
    );
  }

  Future<void> notifyEmployeeUpdated(String name) async {
    _showSnackbar(
      '✏️ Employee Updated',
      '$name\'s information has been updated.',
      const Color(0xFF1A73E8),
    );
    await _sendPushToAllDevices(
      title: '✏️ Employee Updated',
      body: '$name\'s information has been updated.',
    );
  }

  Future<void> notifyEmployeeDeleted(String name) async {
    _showSnackbar(
      '🗑️ Employee Removed',
      '$name has been removed from the system.',
      const Color(0xFFEA4335),
    );
    await _sendPushToAllDevices(
      title: '🗑️ Employee Removed',
      body: '$name has been removed from the system.',
    );
  }
}