import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/enums/debt_type.dart';
import 'package:shopkeeper/core/utils/currency_formatter.dart' show formatFCFA;
import 'package:shopkeeper/core/widgets/app_button.dart';
import 'package:shopkeeper/core/widgets/risk_badge.dart';
import 'package:shopkeeper/features/debts/domain/entities/debt_record.dart';
import 'package:shopkeeper/features/debts/presentation/providers/debt_provider.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';

class CustomerDetailScreen extends StatefulWidget {
  final String customerId;

  const CustomerDetailScreen({required this.customerId, super.key});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final _paymentController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DebtProvider>().loadCustomerDetail(widget.customerId);
    });
  }

  @override
  void dispose() {
    _paymentController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _recordPayment() async {
    final l10n = AppLocalizations.of(context)!;
    final amount = double.tryParse(_paymentController.text);
    if (amount == null || amount <= 0) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final success = await context.read<DebtProvider>().recordPayment(
          widget.customerId,
          amount,
          _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        );

    if (!mounted) return;
    if (success) {
      _paymentController.clear();
      _noteController.clear();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
              '${l10n.paymentRecord} ${formatFCFA(amount)} ${l10n.success.toLowerCase()}'),
          backgroundColor: AppColors.success,
        ),
      );
      context.read<DebtProvider>().loadCustomerDetail(widget.customerId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<DebtProvider>(
      builder: (context, provider, _) {
        final customer = provider.selectedCustomer;

        return Scaffold(
          appBar: AppBar(
            title: Text(customer?.name ?? l10n.customers),
            backgroundColor: AppColors.ownerPrimary,
            elevation: 0,
          ),
          body: provider.isLoading && customer == null
              ? const Center(child: CircularProgressIndicator())
              : customer == null
                  ? Center(
                      child: Text(
                        provider.errorMessage ?? l10n.noDataFound,
                        style: AppTextStyles.bodyM
                            .copyWith(color: AppColors.danger),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.ownerPrimary
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.ownerPrimary
                                      .withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  child: Center(
                                    child: Text(customer.initials,
                                        style: AppTextStyles.headingL
                                            .copyWith(color: Colors.white)),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(customer.name,
                                          style: AppTextStyles.headingL),
                                      if (customer.phone.isNotEmpty)
                                        Text(customer.phone,
                                            style: AppTextStyles.bodyM.copyWith(
                                                color: Colors.grey[600])),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          RiskBadge(customer.riskCategory),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Since ${DateFormat('MMM y').format(customer.createdAt)}',
                                            style: AppTextStyles.bodyM.copyWith(
                                                color: Colors.grey[600],
                                                fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  label: l10n.outstandingDebt,
                                  value: formatFCFA(customer.totalDebt),
                                  color: customer.totalDebt > 0
                                      ? AppColors.danger
                                      : AppColors.success,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  label: l10n.debtRecords,
                                  value: '${provider.debtHistory.length}',
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          if (customer.totalDebt > 0) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.success.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: AppColors.success
                                        .withValues(alpha: 0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.recordPayment,
                                      style: AppTextStyles.headingM),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _paymentController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: l10n.amount,
                                      prefixText: '${l10n.fcfa} ',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 12),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: _noteController,
                                    decoration: InputDecoration(
                                      hintText: l10n.noteOptional,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 12),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  AppButton.primary(
                                    label: provider.isSaving
                                        ? l10n.recordingEllipsis
                                        : l10n.recordPayment,
                                    onPressed: provider.isSaving
                                        ? null
                                        : _recordPayment,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                          Text(l10n.transactionHistory,
                              style: AppTextStyles.headingM),
                          const SizedBox(height: 12),
                          if (provider.debtHistory.isEmpty)
                            Center(
                              child: Text(l10n.noTransactionsYet,
                                  style: AppTextStyles.bodyM
                                      .copyWith(color: Colors.grey[500])),
                            )
                          else
                            ...provider.debtHistory.map(
                                (r) => _DebtRecordTile(record: r, l10n: l10n)),
                        ],
                      ),
                    ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTextStyles.bodyM
                    .copyWith(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 6),
            Text(value, style: AppTextStyles.headingS.copyWith(color: color)),
          ],
        ),
      );
}

class _DebtRecordTile extends StatelessWidget {
  final DebtRecord record;
  final AppLocalizations l10n;
  const _DebtRecordTile({required this.record, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final isCredit = record.type == DebtType.credit;
    final color = isCredit ? AppColors.danger : AppColors.success;
    final sign = isCredit ? '+' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isCredit ? Icons.arrow_upward : Icons.arrow_downward,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCredit ? l10n.creditRecord : l10n.paymentRecord,
                  style:
                      AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
                ),
                if (record.note != null && record.note!.isNotEmpty)
                  Text(record.note!,
                      style: AppTextStyles.bodyM
                          .copyWith(color: Colors.grey[600], fontSize: 12)),
                Text(
                  DateFormat('d MMM y, h:mm a')
                      .format(record.recordedAt.toLocal()),
                  style: AppTextStyles.bodyM
                      .copyWith(color: Colors.grey[400], fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign${formatFCFA(record.amount)}',
                style: AppTextStyles.bodyM
                    .copyWith(fontWeight: FontWeight.w700, color: color),
              ),
              Text(
                '${l10n.balance} ${formatFCFA(record.balanceAfter)}',
                style: AppTextStyles.bodyM
                    .copyWith(color: Colors.grey[500], fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
