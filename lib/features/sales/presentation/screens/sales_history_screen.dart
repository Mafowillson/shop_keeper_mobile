import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/sales/domain/entities/sale.dart';
import 'package:shopkeeper/features/sales/presentation/providers/sales_provider.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  String get _shopId => context.read<AuthProvider>().currentUser?.shopId ?? '';

  Future<void> _load() => context.read<SalesProvider>().loadSales(_shopId);

  List<Sale> _filtered(List<Sale> all) {
    if (_filter == 'Cash') return all.where((s) => !s.isCredit).toList();
    if (_filter == 'Credit') return all.where((s) => s.isCredit).toList();
    return all;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.salesHistory,
            style: AppTextStyles.headingL.copyWith(color: Colors.white)),
        backgroundColor: AppColors.ownerPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<SalesProvider>(
        builder: (_, provider, __) {
          final all = provider.sales;
          final filtered = _filtered(all);

          return Column(
            children: [
              // ── Summary strip ────────────────────────────────────────
              Container(
                color: AppColors.ownerPrimary,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    _SummaryCard(
                      label: l10n.totalRevenue,
                      value:
                          '${l10n.fcfa} ${provider.totalRevenue.toStringAsFixed(0)}',
                      icon: Icons.trending_up,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    _SummaryCard(
                      label: l10n.transactions,
                      value: '${all.length}',
                      icon: Icons.receipt_long_outlined,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),

              // ── Filter chips ─────────────────────────────────────────
              Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: ['All', 'Cash', 'Credit'].map((f) {
                    final sel = _filter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(f),
                        selected: sel,
                        onSelected: (_) => setState(() => _filter = f),
                        selectedColor: AppColors.ownerPrimary,
                        labelStyle: AppTextStyles.bodyM.copyWith(
                          color: sel ? Colors.white : AppColors.textPrimary,
                          fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                        ),
                        backgroundColor: AppColors.background,
                        side: BorderSide(
                          color:
                              sel ? AppColors.ownerPrimary : AppColors.border,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // ── Count bar ─────────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      provider.isLoading
                          ? l10n.loadingEllipsis
                          : '${filtered.length} ${l10n.transactions.toLowerCase()}',
                      style: AppTextStyles.bodyM
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    if (provider.isLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.ownerPrimary),
                      ),
                  ],
                ),
              ),

              // ── Error ────────────────────────────────────────────────
              if (provider.errorMessage != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.dangerLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.danger.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.danger, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(provider.errorMessage!,
                              style: AppTextStyles.bodyS
                                  .copyWith(color: AppColors.danger))),
                      IconButton(
                        icon: const Icon(Icons.refresh,
                            color: AppColors.danger, size: 18),
                        onPressed: _load,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

              // ── List ─────────────────────────────────────────────────
              Expanded(
                child: provider.isLoading && all.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.ownerPrimary))
                    : filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long,
                                    size: 64, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                Text(l10n.noSalesFound,
                                    style: AppTextStyles.bodyM.copyWith(
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            color: AppColors.ownerPrimary,
                            onRefresh: _load,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                              itemCount: filtered.length,
                              itemBuilder: (_, i) =>
                                  _SaleCard(sale: filtered[i], l10n: l10n),
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: AppTextStyles.headingS.copyWith(color: color),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(label,
                      style: AppTextStyles.labelM
                          .copyWith(color: color.withValues(alpha: 0.75))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaleCard extends StatelessWidget {
  final Sale sale;
  final AppLocalizations l10n;

  const _SaleCard({required this.sale, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy • HH:mm');
    final typeColor = sale.isCredit ? AppColors.warning : AppColors.success;
    final typeLabel = sale.isCredit ? l10n.credit : l10n.cash;
    final statusColor = sale.isPaid ? AppColors.success : AppColors.warning;
    final statusLabel = sale.isPaid ? l10n.paid : l10n.pending;

    return GestureDetector(
      onTap: () => context.push('/owner/sales/${sale.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sale #${sale.id.substring(0, 8).toUpperCase()}',
                        style: AppTextStyles.bodyM
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(fmt.format(sale.createdAt.toLocal()),
                          style: AppTextStyles.bodyS),
                    ],
                  ),
                ),
                _Badge(typeLabel, typeColor),
                const SizedBox(width: 6),
                _Badge(statusLabel, statusColor),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${l10n.fcfa} ${sale.totalAmount.toStringAsFixed(0)}',
                  style: AppTextStyles.headingM
                      .copyWith(color: AppColors.ownerPrimary),
                ),
                Text(
                  '${sale.items.length} item${sale.items.length == 1 ? '' : 's'}',
                  style: AppTextStyles.bodyS,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(label,
          style: AppTextStyles.labelM
              .copyWith(color: color, fontWeight: FontWeight.w600)),
    );
  }
}
