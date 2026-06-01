import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopkeeper/app.dart';
import 'package:shopkeeper/core/services/fcm_service.dart';
import 'package:shopkeeper/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await Hive.initFlutter();
  await Hive.openBox('auth');

  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  configureDependencies();

  // Request notification permission (no-op if already granted/denied).
  await getIt<FcmService>().requestPermission();

  runApp(const ShopKeeperApp());
}
