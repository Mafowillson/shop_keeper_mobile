import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  void _navigateAfterDelay() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ownerPrimary,
      body: GestureDetector(
        onLongPress: () {
          context.read<AuthProvider>().resetAuth();
          context.go('/login');
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.storefront, size: 80, color: Colors.white),
              const SizedBox(height: 24),
              Text(
                'ShopKeeper',
                style: AppTextStyles.displayL.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                'Manage your shop, grow your business',
                style: AppTextStyles.bodyM.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        height: 4,
        color: Colors.transparent,
        child: const LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}
