import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'token_storage_service.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  // Keep token refresh subscription reference for cleanup
  StreamSubscription<String>? _tokenRefreshSub;

  // Android notification channel
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Used for important notifications.',
    importance: Importance.high,
  );

  // Call in main() after Firebase.initializeApp
  Future<void> initialize() async {
    // Local notifications init
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    await _local.initialize(initSettings);

    // Create Android channel
    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    // Request permissions
    await requestPermissions();

    // Get and log token
    final token = await _messaging.getToken();
    debugPrint('🔑 FCM Token: $token');
    if (token != null && token.isNotEmpty) {
      await TokenStorageService.saveFcmToken(token);
    }

    // Listen for token refresh and persist
    _tokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      debugPrint('🔁 FCM Token refreshed: $newToken');
      await TokenStorageService.saveFcmToken(newToken);
    });

    // Background handler is set in top-level (wired in main)

    // Foreground messages
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // iOS: show notifications when app in foreground
    if (Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> requestPermissions() async {
    // Android 13+ will show runtime prompt; iOS always prompts
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    debugPrint('🔔 Notification permission: ${settings.authorizationStatus}');
  }

  void _onForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final android = notification?.android;
    final title =
        notification?.title ?? message.data['title'] ?? 'Notification';
    final body = notification?.body ?? message.data['body'] ?? '';

    // Show local notification in foreground
    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: android?.smallIcon ?? '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.data.toString(),
    );
  }

  //  dispose function
  Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;
    debugPrint('🧹 NotificationService disposed');
  }

}

// Top-level background handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Keep minimal work here. You can log or pre-process.
  debugPrint('📨 BG message: ${message.messageId}');
}


