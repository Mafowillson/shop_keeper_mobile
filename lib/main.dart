import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopkeeper/app.dart';
import 'package:shopkeeper/core/services/fcm_service.dart';
import 'package:shopkeeper/di/injection.dart';

/// Shared plugin instance — also used by FcmService for foreground banners.
final FlutterLocalNotificationsPlugin localNotifications =
    FlutterLocalNotificationsPlugin();

/// Must match the ChannelID the backend sends in every FCM payload.
const AndroidNotificationChannel shopkeeperChannel = AndroidNotificationChannel(
  'shopkeeper_alerts',
  'ShopKeeper Alerts',
  description: 'Sales, stock, debt and staff alerts',
  importance: Importance.high,
  enableVibration: true,
);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('[FCM] background: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialise flutter_local_notifications.
  const initSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  );
  await localNotifications.initialize(initSettings);

  // Create the Android notification channel. Idempotent — safe on every launch.
  await localNotifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(shopkeeperChannel);

  await Hive.initFlutter();
  await Hive.openBox('auth');

  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  configureDependencies();

  await getIt<FcmService>().requestPermission();

  runApp(const ShopKeeperApp());
}
