import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopkeeper/app.dart';
import 'package:shopkeeper/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('auth');

  // Register SharedPreferences before the injectable init so it can be
  // injected into OnboardingProvider (which persists the onboarding flag).
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  configureDependencies();
  runApp(const ShopKeeperApp());
}
