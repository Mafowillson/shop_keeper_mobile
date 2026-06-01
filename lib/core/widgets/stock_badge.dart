import 'package:flutter/material.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';

class StockBadge extends StatelessWidget {
  final int stockQty;
  final int lowStockThreshold;

  const StockBadge({
    required this.stockQty,
    required this.lowStockThreshold,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    if (stockQty == 0) {
      color = AppColors.danger;
      label = 'Out of Stock';
    } else if (stockQty < lowStockThreshold) {
      color = AppColors.warning;
      label = 'Low Stock';
    } else {
      color = AppColors.success;
      label = 'In Stock';
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
