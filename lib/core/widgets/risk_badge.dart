import 'package:flutter/material.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/enums/risk_category.dart';

class RiskBadge extends StatelessWidget {
  final RiskCategory category;

  const RiskBadge(this.category, {super.key});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (category) {
      case RiskCategory.newCustomer:
        color = AppColors.success;
        label = 'New';
        break;
      case RiskCategory.low:
        color = AppColors.success;
        label = 'Low Risk';
        break;
      case RiskCategory.medium:
        color = AppColors.warning;
        label = 'Medium Risk';
        break;
      case RiskCategory.high:
        color = AppColors.danger;
        label = 'High Risk';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
