import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/widgets/app_button.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'Cash';
  late TextEditingController _amountController;
  late TextEditingController _referenceController;

  final double saleTotal = 12500;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: saleTotal.toStringAsFixed(0));
    _referenceController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amountEntered = double.tryParse(_amountController.text) ?? 0;
    final change = amountEntered - saleTotal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: AppColors.staffPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sale Summary
            _buildSaleSummary(),
            const SizedBox(height: 24),

            // Payment Method Selection
            Text(
              'Payment Method',
              style: AppTextStyles.headingM,
            ),
            const SizedBox(height: 12),
            _buildPaymentMethods(),
            const SizedBox(height: 24),

            // Amount Section
            Text(
              'Amount',
              style: AppTextStyles.headingM,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter amount',
                prefixText: 'FCFA ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Reference Number (for card/mobile money)
            if (_selectedPaymentMethod != 'Cash')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reference Number',
                    style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _referenceController,
                    decoration: InputDecoration(
                      hintText: 'Enter transaction reference',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),

            // Payment Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Sale Total', 'FCFA ${saleTotal.toStringAsFixed(0)}'),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Amount Paid', 'FCFA ${amountEntered.toStringAsFixed(0)}'),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    'Change',
                    'FCFA ${change.toStringAsFixed(0)}',
                    color: change >= 0 ? AppColors.success : AppColors.danger,
                    isBold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton.primary(
                    label: 'Complete Payment',
                    onPressed: () => amountEntered >= saleTotal
                        ? () => context.push('/staff/sale/confirm')
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.staffPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.staffPrimary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sale Summary',
            style: AppTextStyles.bodyM.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'FCFA ${saleTotal.toStringAsFixed(0)}',
            style: AppTextStyles.displayM.copyWith(color: AppColors.staffPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            '3 items • 5 minutes ago',
            style: AppTextStyles.bodyM.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    final methods = [
      {'name': 'Cash', 'icon': Icons.money, 'color': AppColors.success},
      {'name': 'Card', 'icon': Icons.credit_card, 'color': AppColors.accent},
      {'name': 'Mobile Money', 'icon': Icons.phone_android, 'color': AppColors.warning},
      {'name': 'Credit', 'icon': Icons.account_balance_wallet, 'color': AppColors.danger},
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: methods.map((method) {
        final isSelected = _selectedPaymentMethod == method['name'];
        return GestureDetector(
          onTap: () => setState(() => _selectedPaymentMethod = method['name'] as String),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? (method['color'] as Color).withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? (method['color'] as Color)
                    : Colors.grey[200]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  method['icon'] as IconData,
                  size: 32,
                  color: method['color'] as Color,
                ),
                const SizedBox(height: 8),
                Text(
                  method['name'] as String,
                  style: AppTextStyles.bodyM.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? (method['color'] as Color) : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? color,
    bool isBold = false,
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
