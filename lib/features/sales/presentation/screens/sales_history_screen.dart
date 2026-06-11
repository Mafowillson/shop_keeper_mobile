import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/cache/cache_metadata_service.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/offline/hive_boxes.dart';
import 'package:shopkeeper/core/widgets/last_updated_indicator.dart';
import 'package:shopkeeper/core/widgets/offline_banner.dart';
import 'package:shopkeeper/di/injection.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/sales/domain/entities/sale.dart';
import 'package:shopkeeper/features/sales/presentation/providers/sales_provider.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

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

  List<Sale> _applyFilter(List<Sale> all) {
    if (_filter == 'Cash') return all.where((s) => !s.isCredit).toList();
    if (_filter == 'Credit') return all.where((s) => s.isCredit).toList();
    return all;
  }

  String _chipLabel(String key, AppLocalizations l10n) {
    switch (key) {
      case 'Cash':
        return l10n.cash;
      case 'Credit':
        return l10n.credit;
      default:
        return l10n.all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<SalesProvider>(
        builder: (context, provider, _) {
          final all = provider.sales;
          final filtered = _applyFilter(all);
          final outstanding = all
              .where((s) => !s.isPaid)
              .fold(0.0, (sum, s) => sum + s.dueAmount);

          return RefreshIndicator(
            onRefresh: _load,
            color: AppColors.ownerPrimary,
            child: CustomScrollView(
              slivers: [
                // ── App bar + stats + filter chips ──────────────────────
                // Filter chips live in AppBar.bottom — they stay pinned
                // when the header collapses without needing a second
                // SliverPersistentHeader.
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 192,
                  backgroundColor: AppColors.ownerPrimary,
                  foregroundColor: Colors.white,
                  title: Text(
                    l10n.salesHistory,
                    style: AppTextStyles.headingL.copyWith(color: Colors.white),
                  ),
                  actions: [
                    if (provider.isRefreshing)
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          ),
                        ),
                      ),
                  ],
                  // Filter chips — always visible when pinned
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(52),
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Row(
                        children: ['All', 'Cash', 'Credit'].map((key) {
                          final selected = _filter == key;
                          final label = _chipLabel(key, l10n);
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () => setState(() => _filter = key),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 7),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.ownerPrimary
                                      : AppColors.background,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.ownerPrimary
                                        : AppColors.border,
                                  ),
                                ),
                                child: Text(
                                  label,
                                  style: AppTextStyles.labelL.copyWith(
                                    color: selected
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.ownerPrimary,
                            Color(0xFF1B5E20),
                          ],
                        ),
                      ),
                      // 52 (bottom chips) + 18 (gap) = 70 from bottom
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 70),
                      alignment: Alignment.bottomLeft,
                      child: Row(
                        children: [
                          _HeaderStat(
                            value:
                                '${l10n.fcfa} ${provider.totalRevenue.toStringAsFixed(0)}',
                            label: l10n.totalRevenue.toLowerCase(),
                          ),
                          const SizedBox(width: 10),
                          _HeaderStat(
                            value: '${all.length}',
                            label: l10n.transactions.toLowerCase(),
                          ),
                          if (outstanding > 0) ...[
                            const SizedBox(width: 10),
                            _HeaderStat(
                              value:
                                  '${l10n.fcfa} ${outstanding.toStringAsFixed(0)}',
                              label: 'outstanding',
                              accent: AppColors.warning,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Offline + error ─────────────────────────────────────
                const SliverToBoxAdapter(child: OfflineBanner()),
                if (provider.errorMessage != null)
                  SliverToBoxAdapter(
                    child: _ErrorBanner(
                      message: provider.errorMessage!,
                      onRetry: _load,
                    ),
                  ),

                // ── Count row ───────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(
                      provider.isLoading && all.isEmpty
                          ? l10n.loadingEllipsis
                          : '${filtered.length} ${l10n.transactions.toLowerCase()}',
                      style: AppTextStyles.bodyM
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ),

                // ── Loading / empty / list ──────────────────────────────
                if (provider.isLoading && all.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.ownerPrimary),
                    ),
                  )
                else if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(
                      isFiltered: _filter != 'All',
                      l10n: l10n,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _SaleCard(sale: filtered[i], l10n: l10n),
                        childCount: filtered.length,
                      ),
                    ),
                  ),

                // ── Footer ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: LastUpdatedIndicator(
                    boxName: HiveBoxes.sales,
                    metadata: getIt<CacheMetadataService>(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Header stat chip ──────────────────────────────────────────────────────────

class _HeaderStat extends StatelessWidget {
  final String value;
  final String label;
  final Color? accent;

  const _HeaderStat({
    required this.value,
    required this.label,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: accent != null
            ? Border.all(color: accent!.withValues(alpha: 0.5))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyles.headingS.copyWith(color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: AppTextStyles.bodyS.copyWith(
              color: accent ?? Colors.white.withValues(alpha: 0.8),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sale card ─────────────────────────────────────────────────────────────────

class _SaleCard extends StatelessWidget {
  final Sale sale;
  final AppLocalizations l10n;

  const _SaleCard({required this.sale, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final dateFmt = DateFormat('dd MMM yyyy • HH:mm', locale);
    final stripColor = sale.isCredit ? AppColors.warning : AppColors.success;
    final hasDue = sale.isCredit && !sale.isPaid && sale.dueAmount > 0;
    final shortRef = sale.id.length >= 8
        ? sale.id.substring(0, 8).toUpperCase()
        : sale.id.toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left accent strip
              Container(width: 4, color: stripColor),
              // Card content
              Expanded(
                child: InkWell(
                  onTap: () => context.push('/owner/sales/${sale.id}'),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 14, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Top row: ref / date / amount ─────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Receipt icon
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: stripColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.receipt_long_outlined,
                                  color: stripColor, size: 20),
                            ),
                            const SizedBox(width: 10),
                            // Ref + date
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.saleRef(shortRef),
                                    style: AppTextStyles.bodyM
                                        .copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    dateFmt.format(sale.createdAt.toLocal()),
                                    style: AppTextStyles.bodyS.copyWith(
                                        color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Amount + type badge
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${l10n.fcfa} ${sale.totalAmount.toStringAsFixed(0)}',
                                  style: AppTextStyles.headingS.copyWith(
                                    color: AppColors.ownerPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _Badge(
                                  sale.isCredit ? l10n.credit : l10n.cash,
                                  sale.isCredit
                                      ? AppColors.warning
                                      : AppColors.success,
                                ),
                              ],
                            ),
                          ],
                        ),

                        // ── Due row (credit + unpaid only) ────────────
                        if (hasDue) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color:
                                      AppColors.warning.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.schedule,
                                    size: 14, color: AppColors.warning),
                                const SizedBox(width: 6),
                                Text(
                                  'Due ${l10n.fcfa} ${sale.dueAmount.toStringAsFixed(0)}',
                                  style: AppTextStyles.bodyS.copyWith(
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                _Badge(l10n.pending, AppColors.warning),
                              ],
                            ),
                          ),
                        ],

                        // ── Item count ────────────────────────────────
                        const SizedBox(height: 8),
                        Text(
                          l10n.itemCount(sale.items.length),
                          style: AppTextStyles.bodyS
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
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
}

// ── Badge ─────────────────────────────────────────────────────────────────────

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
      child: Text(
        label,
        style: AppTextStyles.bodyS.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}

// ── Error banner ──────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.dangerLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: AppTextStyles.bodyS.copyWith(color: AppColors.danger)),
          ),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.danger,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isFiltered;
  final AppLocalizations l10n;

  const _EmptyState({required this.isFiltered, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: Icon(
                isFiltered
                    ? Icons.filter_list_off
                    : Icons.receipt_long_outlined,
                size: 36,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.noSalesFound,
              style: AppTextStyles.headingM
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (isFiltered) ...[
              const SizedBox(height: 8),
              Text(
                'Try switching to "${l10n.all}" to see every transaction.',
                style: AppTextStyles.bodyM
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
