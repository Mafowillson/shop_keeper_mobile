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
      debugPrint('[FCM] token uploaded successfully');

      // Re-upload whenever Firebase rotates the token.
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

  /// Registers [onMessage] as the foreground message handler.
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
