import 'package:flutter/material.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.ownerPrimary),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}
