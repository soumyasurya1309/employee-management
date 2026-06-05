import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((message) {
      // ignore: avoid_print
      print('FCM message: ${message.notification?.title}');
    });

    final token = await _fcm.getToken();
    // ignore: avoid_print
    print('FCM Token: $token');
  }

  Future<void> notifyEmployeeAdded(String name) async {
    // ignore: avoid_print
    print('Employee added: $name');
  }

  Future<void> notifyEmployeeUpdated(String name) async {
    // ignore: avoid_print
    print('Employee updated: $name');
  }

  Future<void> notifyEmployeeDeleted(String name) async {
    // ignore: avoid_print
    print('Employee deleted: $name');
  }
}