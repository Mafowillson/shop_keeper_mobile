import 'package:flutter/material.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;

  const EmptyState({
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.headingM),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: AppTextStyles.bodyS,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
