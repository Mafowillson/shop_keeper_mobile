import 'package:flutter/material.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const SectionHeader({
    required this.title,
    this.actionText,
    this.onActionPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.headingL),
        if (actionText != null)
          TextButton(
            onPressed: onActionPressed,
            child: Text(actionText!),
          ),
      ],
    );
  }
}
