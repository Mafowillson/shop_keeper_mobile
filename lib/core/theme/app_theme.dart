import 'package:flutter/material.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';

class AppTheme {
  static ThemeData ownerTheme() {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.ownerPrimary,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.ownerPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.ownerPrimary,
        unselectedItemColor: AppColors.textSecondary,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textPrimary,
      ),
    );
  }

  static ThemeData staffTheme() {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.staffPrimary,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.staffPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.staffPrimary,
        unselectedItemColor: AppColors.textSecondary,
      ),
    );
  }
}
