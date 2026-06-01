import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/features/sales/presentation/providers/sales_provider.dart';

class SaleDetailScreen extends StatefulWidget {
  final String saleId;

  const SaleDetailScreen({required this.saleId, super.key});

  @override
  State<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends State<SaleDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        context.read<SalesProvider>().loadSaleDetail(widget.saleId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Sale Detail',
            style: AppTextStyles.headingL.copyWith(color: Colors.white)),
        backgroundColor: AppColors.ownerPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<SalesProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading) {
            return const Center(
                child: CircularProgressIndicator(
                    color: AppColors.ownerPrimary));
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.danger, size: 48),
                  const SizedBox(height: 12),
                  Text(provider.errorMessage!,
                      style: AppTextStyles.bodyM
                          .copyWith(color: AppColors.danger),
                      textAlign: TextAlign.center),
                ],
              ),
            );
          }

          final sale = provider.currentSale;
          if (sale == null) return const SizedBox();

          final fmt = DateFormat('dd MMM yyyy • HH:mm');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.ownerPrimaryDark, AppColors.ownerPrimary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FCFA ${sale.totalAmount.toStringAsFixed(0)}',
                        style: AppTextStyles.displayM
                            .copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        fmt.format(sale.createdAt.toLocal()),
                        style: AppTextStyles.bodyM
                            .copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _Chip(
                            sale.isCredit ? 'Credit' : 'Cash',
                            sale.isCredit
                                ? AppColors.warning
                                : AppColors.success,
                          ),
                          const SizedBox(width: 8),
                          _Chip(
                            sale.isPaid ? 'Paid' : 'Pending',
                            sale.isPaid
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Items
                Text('Items', style: AppTextStyles.headingM),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < sale.items.length; i++) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.accent
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                    Icons.inventory_2_outlined,
                                    size: 18,
                                    color: AppColors.accent),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${sale.items[i].quantity}× ${sale.items[i].unit}',
                                      style: AppTextStyles.bodyM.copyWith(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      'FCFA ${sale.items[i].unitPrice.toStringAsFixed(0)} / unit',
                                      style: AppTextStyles.bodyS,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'FCFA ${sale.items[i].totalPrice.toStringAsFixed(0)}',
                                style: AppTextStyles.bodyM.copyWith(
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        if (i < sale.items.length - 1)
                          const Divider(
                              height: 1, indent: 64, endIndent: 0),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Payment summary
                Text('Payment', style: AppTextStyles.headingM),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _PayRow('Total',
                          'FCFA ${sale.totalAmount.toStringAsFixed(0)}'),
                      const SizedBox(height: 8),
                      _PayRow('Paid',
                          'FCFA ${sale.paidAmount.toStringAsFixed(0)}'),
                      if (sale.dueAmount > 0) ...[
                        const SizedBox(height: 8),
                        _PayRow(
                          'Owed',
                          'FCFA ${sale.dueAmount.toStringAsFixed(0)}',
                          color: AppColors.danger,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(label,
          style: AppTextStyles.labelL
              .copyWith(color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _PayRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _PayRow(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.bodyM
                .copyWith(color: AppColors.textSecondary)),
        Text(value,
            style: AppTextStyles.bodyM.copyWith(
              fontWeight: FontWeight.w700,
              color: color ?? AppColors.textPrimary,
            )),
      ],
    );
  }
}
