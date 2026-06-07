import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shopkeeper/core/enums/user_role.dart';
import 'package:shopkeeper/core/network/dio_client.dart';
import 'package:shopkeeper/main.dart'
    show localNotifications, shopkeeperChannel;

class FcmService {
  final Dio _dio;

  FcmService(DioClient dioClient) : _dio = dioClient.client;

  Future<void> requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('[FCM] permission: ${settings.authorizationStatus}');
  }

  /// Uploads the current FCM token to the backend for the authenticated role.
  /// Safe to call on every login and on app restart.
  Future<void> uploadTokenForRole(UserRole role) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) {
        debugPrint('[FCM] token is null — skipping upload');
        return;
      }
      debugPrint('[FCM] uploading token for role: $role');

      final endpoint =
          role == UserRole.owner ? '/owner/fcm-token' : '/staff/fcm-token';

      await _dio.post(endpoint, data: {'token': token});
      debugPrint('[FCM] token uploaded');

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        try {
          await _dio.post(endpoint, data: {'token': newToken});
          debugPrint('[FCM] refreshed token uploaded');
        } catch (e) {
          debugPrint('[FCM] token refresh upload failed: $e');
        }
      });
    } catch (e) {
      debugPrint('[FCM] uploadTokenForRole failed: $e');
    }
  }

  /// Shows a visible banner when a message arrives while the app is open.
  /// Android does not auto-display notification banners in the foreground.
  void showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          shopkeeperChannel.id,
          shopkeeperChannel.name,
          channelDescription: shopkeeperChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  void setupForegroundHandler(void Function(RemoteMessage) onMessage) {
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('[FCM] foreground: ${message.notification?.title}');
      onMessage(message);
    });
  }

  Future<RemoteMessage?> getInitialMessage() =>
      FirebaseMessaging.instance.getInitialMessage();

  Stream<RemoteMessage> get onNotificationTap =>
      FirebaseMessaging.onMessageOpenedApp;
}
