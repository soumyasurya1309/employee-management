import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // Global key to show snackbars from anywhere
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> notifyEmployeeAdded(String name) async {
    _showSnackbar(
      '✅ Employee Added',
      '$name has been successfully added.',
      const Color(0xFF34A853),
    );
  }

  Future<void> notifyEmployeeUpdated(String name) async {
    _showSnackbar(
      '✏️ Employee Updated',
      '$name\'s information has been updated.',
      const Color(0xFF1A73E8),
    );
  }

  Future<void> notifyEmployeeDeleted(String name) async {
    _showSnackbar(
      '🗑️ Employee Removed',
      '$name has been removed from the system.',
      const Color(0xFFEA4335),
    );
  }
}