import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/widgets/app_button.dart';

class SaleConfirmScreen extends StatelessWidget {
  const SaleConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'name': 'Coca Cola 500ml', 'qty': 2, 'price': 1500, 'total': 3000},
      {'name': 'Lay\'s Chips 50g', 'qty': 1, 'price': 2000, 'total': 2000},
      {'name': 'Milk 1L', 'qty': 3, 'price': 2500, 'total': 7500},
    ];

    final subtotal = items.fold<double>(0, (sum, item) => sum + (item['total'] as int));
    final tax = (subtotal * 0.05).toStringAsFixed(0);
    final total = (subtotal + double.parse(tax)).toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sale Confirmation'),
        backgroundColor: AppColors.staffPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Success Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.check_circle,
                size: 50,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 16),

            // Success Message
            Text(
              'Payment Successful!',
              style: AppTextStyles.displayM.copyWith(color: AppColors.success),
            ),
            const SizedBox(height: 8),
            Text(
              'Sale #2024001 has been recorded',
              style: AppTextStyles.bodyM.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Receipt
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Receipt Header
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'SHOPKEEPER',
                          style: AppTextStyles.headingL.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Receipt #2024001',
                          style: AppTextStyles.bodyM.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '2024-05-10 14:35:22',
                          style: AppTextStyles.bodyM.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 24),

                  // Items
                  Column(
                    children: items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name']! as String,
                                    style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item['qty']} x FCFA ${item['price']}',
                                    style: AppTextStyles.bodyM.copyWith(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'FCFA ${item['total']}',
                              style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const Divider(height: 24),

                  // Totals
                  _buildReceiptRow('Subtotal', 'FCFA ${subtotal.toStringAsFixed(0)}'),
                  const SizedBox(height: 8),
                  _buildReceiptRow('Tax (5%)', 'FCFA $tax'),
                  const SizedBox(height: 12),
                  _buildReceiptRow(
                    'Total',
                    'FCFA $total',
                    isBold: true,
                    color: AppColors.staffPrimary,
                  ),
                  const SizedBox(height: 12),
                  _buildReceiptRow(
                    'Payment Method',
                    'Cash',
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 8),
                  _buildReceiptRow(
                    'Change',
                    'FCFA 500',
                    color: AppColors.success,
                  ),
                  const Divider(height: 24),

                  // Footer
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Thank you for your purchase!',
                          style: AppTextStyles.bodyM.copyWith(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Staff: Marie Kamga',
                          style: AppTextStyles.bodyM.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.print),
                    label: const Text('Print'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppButton.primary(
              label: 'New Sale',
              onPressed: () => context.go('/staff/home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyM.copyWith(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyM.copyWith(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: color ?? Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
