import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/widgets/app_button.dart';
import 'package:shopkeeper/features/sales/presentation/providers/cart_provider.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isCredit = false;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    final total = context.read<CartProvider>().total;
    _amountController =
        TextEditingController(text: total.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  bool get _canProceed {
    final entered = double.tryParse(_amountController.text) ?? 0;
    if (_isCredit) return true;
    return entered > 0;
  }

  void _proceed(double total) {
    final entered = double.tryParse(_amountController.text) ?? 0;
    final paid = _isCredit ? 0.0 : entered;

    context.read<CartProvider>().setPayment(
          paidAmount: paid,
          isCredit: _isCredit,
        );
    context.push('/staff/sale/confirm');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (_, cart, __) {
        final total = cart.total;
        final entered = double.tryParse(_amountController.text) ?? 0;
        final change = _isCredit ? 0.0 : (entered - total);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('Payment',
                style:
                    AppTextStyles.headingL.copyWith(color: Colors.white)),
            backgroundColor: AppColors.staffPrimary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.staffPrimary, Color(0xFF1A5C48)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sale Total',
                          style: AppTextStyles.bodyM
                              .copyWith(color: Colors.white70)),
                      const SizedBox(height: 6),
                      Text(
                        'FCFA ${total.toStringAsFixed(0)}',
                        style: AppTextStyles.displayM
                            .copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${cart.itemCount} item${cart.itemCount == 1 ? '' : 's'}',
                        style: AppTextStyles.bodyS
                            .copyWith(color: Colors.white60),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Payment type toggle
                Text('Payment type', style: AppTextStyles.headingM),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _TypeChip(
                      label: 'Cash',
                      icon: Icons.money,
                      color: AppColors.success,
                      selected: !_isCredit,
                      onTap: () => setState(() {
                        _isCredit = false;
                        _amountController.text = total.toStringAsFixed(0);
                      }),
                    ),
                    const SizedBox(width: 12),
                    _TypeChip(
                      label: 'Credit',
                      icon: Icons.account_balance_wallet_outlined,
                      color: AppColors.danger,
                      selected: _isCredit,
                      onTap: () => setState(() {
                        _isCredit = true;
                        _amountController.text = '0';
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (!_isCredit) ...[
                  Text('Amount paid', style: AppTextStyles.headingM),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.headingL,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixText: 'FCFA ',
                      prefixStyle: AppTextStyles.headingM
                          .copyWith(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.staffPrimary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Change summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _SummaryRow('Total', total),
                        const Divider(height: 20),
                        _SummaryRow('Paid', entered),
                        const Divider(height: 20),
                        _SummaryRow(
                          'Change',
                          change,
                          color: change >= 0
                              ? AppColors.success
                              : AppColors.danger,
                          bold: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.dangerLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.danger.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: AppColors.danger, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'This sale will be recorded as credit. Full amount is owed by the customer.',
                            style: AppTextStyles.bodyS
                                .copyWith(color: AppColors.danger),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                Row(
                  children: [
                    Expanded(
                      child: AppButton.outlined(
                        label: 'Back',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton.primary(
                        label: 'Confirm',
                        onPressed: _canProceed ? () => _proceed(total) : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : AppColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTextStyles.headingS.copyWith(
                    color: selected ? color : AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color? color;
  final bool bold;

  const _SummaryRow(this.label, this.amount,
      {this.color, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyM.copyWith(
            color: AppColors.textSecondary,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          'FCFA ${amount.toStringAsFixed(0)}',
          style: AppTextStyles.bodyM.copyWith(
            color: color ?? AppColors.textPrimary,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
