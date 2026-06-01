import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shopkeeper/core/enums/user_role.dart';
import 'package:shopkeeper/core/network/dio_client.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] background message: ${message.messageId}');
}

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

  /// Uploads the FCM token to the correct backend endpoint for [role].
  /// Call this after the user has authenticated (JWT must be in the header).
  Future<void> uploadTokenForRole(UserRole role) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      debugPrint('[FCM] token: $token');

      final endpoint = role == UserRole.owner
          ? '/owner/fcm-token'
          : '/staff/fcm-token';

      await _dio.post(endpoint, data: {'token': token});

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

  /// Listens for foreground messages and calls [onMessage] with the raw
  /// [RemoteMessage] so callers can inspect the type and refresh the right data.
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
