import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/enums/debt_type.dart';
import 'package:shopkeeper/core/utils/currency_formatter.dart' show formatFCFA;
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DebtProvider>().loadCustomerDetail(widget.customerId);
    });
  }

  void _showPaymentSheet() {
    final l10n = AppLocalizations.of(context)!;
    final paymentCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.payments_outlined,
                        color: AppColors.success, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.recordPayment, style: AppTextStyles.headingM),
                      Text('Enter the amount received',
                          style: AppTextStyles.bodyS),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: paymentCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: AppTextStyles.displayM,
                decoration: InputDecoration(
                  prefixText: 'FCFA  ',
                  prefixStyle: AppTextStyles.headingM
                      .copyWith(color: AppColors.textSecondary),
                  hintText: '0',
                  hintStyle: AppTextStyles.displayM
                      .copyWith(color: AppColors.textHint),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.success, width: 2),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                style: AppTextStyles.bodyM,
                decoration: InputDecoration(
                  hintText: l10n.noteOptional,
                  hintStyle:
                      AppTextStyles.bodyM.copyWith(color: AppColors.textHint),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 20),
              Consumer<DebtProvider>(
                builder: (_, provider, __) => SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: provider.isSaving
                        ? null
                        : () async {
                            final amount = double.tryParse(paymentCtrl.text);
                            if (amount == null || amount <= 0) return;
                            final scaffoldMessenger =
                                ScaffoldMessenger.of(context);
                            final success = await context
                                .read<DebtProvider>()
                                .recordPayment(
                                  widget.customerId,
                                  amount,
                                  noteCtrl.text.trim().isEmpty
                                      ? null
                                      : noteCtrl.text.trim(),
                                );
                            if (!ctx.mounted) return;
                            Navigator.pop(ctx);
                            if (success) {
                              scaffoldMessenger.showSnackBar(SnackBar(
                                content: Text(
                                    '${l10n.paymentRecord} ${formatFCFA(amount)} ${l10n.success.toLowerCase()}'),
                                backgroundColor: AppColors.success,
                              ));
                              if (mounted) {
                                context
                                    .read<DebtProvider>()
                                    .loadCustomerDetail(widget.customerId);
                              }
                            }
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: provider.isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            l10n.recordPayment,
                            style: AppTextStyles.headingS
                                .copyWith(color: Colors.white),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<DebtProvider>(
      builder: (context, provider, _) {
        final customer = provider.selectedCustomer;

        if (provider.isLoading && customer == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (customer == null) {
          return Scaffold(
            appBar: AppBar(backgroundColor: AppColors.ownerPrimary),
            body: Center(
              child: Text(
                provider.errorMessage ?? l10n.noDataFound,
                style: AppTextStyles.bodyM.copyWith(color: AppColors.danger),
              ),
            ),
          );
        }

        final hasDebt = customer.totalDebt > 0;

        return Scaffold(
          backgroundColor: AppColors.background,

          // ── Pinned payment button ─────────────────────────────────────
          bottomNavigationBar: hasDebt
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: FilledButton.icon(
                      onPressed: _showPaymentSheet,
                      icon: const Icon(Icons.payments_outlined),
                      label: Text(l10n.recordPayment,
                          style: AppTextStyles.headingS
                              .copyWith(color: Colors.white)),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.success,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                )
              : null,

          body: CustomScrollView(
            slivers: [
              // ── Customer hero header ──────────────────────────────────
              SliverAppBar(
                pinned: true,
                expandedHeight: 220,
                elevation: 0,
                backgroundColor: AppColors.ownerPrimary,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.ownerPrimaryDark,
                          AppColors.ownerPrimary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 72, 20, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            // Avatar
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  customer.initials,
                                  style: AppTextStyles.headingL
                                      .copyWith(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    customer.name,
                                    style: AppTextStyles.headingL
                                        .copyWith(color: Colors.white),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (customer.phone.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      customer.phone,
                                      style: AppTextStyles.bodyS
                                          .copyWith(color: Colors.white60),
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      RiskBadge(customer.riskCategory),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Since ${DateFormat('MMM y').format(customer.createdAt)}',
                                        style: AppTextStyles.labelS
                                            .copyWith(color: Colors.white60),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Stats row ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          label: l10n.outstandingDebt,
                          value: formatFCFA(customer.totalDebt),
                          color: hasDebt ? AppColors.danger : AppColors.success,
                          icon: hasDebt
                              ? Icons.warning_amber_rounded
                              : Icons.check_circle_outline,
                        ),
                      ),
                      Container(width: 1, height: 48, color: AppColors.border),
                      Expanded(
                        child: _StatTile(
                          label: l10n.debtRecords,
                          value: '${provider.debtHistory.length}',
                          color: AppColors.accent,
                          icon: Icons.receipt_long_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // ── Transaction history ───────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(l10n.transactionHistory,
                      style: AppTextStyles.headingM),
                ),
              ),

              if (provider.isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              else if (provider.debtHistory.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 32),
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.receipt_long_outlined,
                                color: AppColors.accent, size: 28),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.noTransactionsYet,
                            style: AppTextStyles.bodyM
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _DebtRecordTile(
                        record: provider.debtHistory[i],
                        isFirst: i == 0,
                        isLast: i == provider.debtHistory.length - 1,
                        l10n: l10n,
                      ),
                      childCount: provider.debtHistory.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          ),
        );
      },
    );
  }
}

// ── Stat tile ─────────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatTile(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyS,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: AppTextStyles.headingS.copyWith(color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

// ── Debt record tile (timeline style) ────────────────────────────────────────

class _DebtRecordTile extends StatelessWidget {
  final DebtRecord record;
  final bool isFirst;
  final bool isLast;
  final AppLocalizations l10n;
  const _DebtRecordTile(
      {required this.record,
      required this.isFirst,
      required this.isLast,
      required this.l10n});

  @override
  Widget build(BuildContext context) {
    final isCredit = record.type == DebtType.credit;
    final color = isCredit ? AppColors.danger : AppColors.success;
    final sign = isCredit ? '+' : '-';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline track
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 1,
                  height: isFirst ? 16 : 0,
                  color: Colors.transparent,
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Center(
                      child: Container(width: 1, color: AppColors.border),
                    ),
                  ),
              ],
            ),
          ),
          // Card
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                bottom: isLast ? 0 : 8,
                top: isFirst ? 0 : 0,
              ),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
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
                      isCredit
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
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
                          style: AppTextStyles.headingS,
                        ),
                        if (record.note != null && record.note!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(record.note!,
                              style: AppTextStyles.bodyS,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('d MMM y, h:mm a')
                              .format(record.recordedAt.toLocal()),
                          style: AppTextStyles.labelS
                              .copyWith(color: AppColors.textHint),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$sign${formatFCFA(record.amount)}',
                        style: AppTextStyles.headingS.copyWith(color: color),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Bal ${formatFCFA(record.balanceAfter)}',
                        style: AppTextStyles.labelS
                            .copyWith(color: AppColors.textHint),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
