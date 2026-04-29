import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<String?> initialize({
    void Function(RemoteMessage message)? onForegroundMessage,
    void Function(RemoteMessage message)? onMessageOpenedApp,
  }) async {
    await _requestPermission();

    FirebaseMessaging.onMessage.listen((message) {
      onForegroundMessage?.call(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      onMessageOpenedApp?.call(message);
    });

    final token = await _messaging.getToken();
    return token;
  }

  Future<String?> getToken() => _messaging.getToken();

  void onTokenRefresh(void Function(String token) callback) {
    _messaging.onTokenRefresh.listen(callback);
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static String? notificationTitle(RemoteMessage message) =>
      message.notification?.title ?? message.data['title'] as String?;

  static String? notificationBody(RemoteMessage message) =>
      message.notification?.body ?? message.data['body'] as String?;

  static void showSnackBar(BuildContext context, RemoteMessage message) {
    final title = notificationTitle(message);
    final body = notificationBody(message);
    final text = [if (title != null) title, if (body != null) body].join(': ');
    if (text.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 4)),
    );
  }
}
