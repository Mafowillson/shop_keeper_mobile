import 'package:flutter/material.dart';
import 'package:shopkeeper/app.dart';
import 'package:shopkeeper/di/injection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const ShopKeeperApp());
}
