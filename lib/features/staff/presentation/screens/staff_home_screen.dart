import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/utils/currency_formatter.dart' show formatFCFA;
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/staff/domain/entities/staff_dashboard_stats.dart';
import 'package:shopkeeper/features/staff/presentation/providers/staff_dashboard_provider.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';

class StaffHomeScreen extends StatefulWidget {
  const StaffHomeScreen({super.key});

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffDashboardProvider>().loadStats();
    });
  }

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 17) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.select<AuthProvider, dynamic>((p) => p.currentUser);
    final firstName = (user?.name as String? ?? 'Staff').split(' ').first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<StaffDashboardProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: provider.loadStats,
            color: AppColors.staffPrimary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _HeroHeader(
                    greeting: _greeting(l10n),
                    firstName: firstName,
                    onNotifications: () =>
                        context.push('/staff/notifications'),
                    onProfile: () => context.push('/staff/profile'),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (provider.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        _ErrorBanner(provider.errorMessage!),
                      ],
                      const SizedBox(height: 20),
                      _StatRow(
                          stats: provider.stats,
                          isLoading: provider.isLoading,
                          l10n: l10n),
                      const SizedBox(height: 24),
                      _NewSaleCTA(
                          onTap: () => context.push('/staff/sale/new'),
                          l10n: l10n),
                      const SizedBox(height: 16),
                      _PriceListTile(
                          onTap: () => context.push('/staff/prices'),
                          l10n: l10n),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.todayTransactions,
                              style: AppTextStyles.headingM),
                          if ((provider.stats?.recentSales.isNotEmpty ??
                              false))
                            Text(
                              '${provider.stats!.mySalesToday} total',
                              style: AppTextStyles.bodyS.copyWith(
                                  color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (provider.isLoading && provider.stats == null)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.staffPrimary)),
                        )
                      else
                        _TransactionList(
                            sales: provider.stats?.recentSales ?? [],
                            l10n: l10n),
                    ]),
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

class _HeroHeader extends StatelessWidget {
  final String greeting;
  final String firstName;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;

  const _HeroHeader({
    required this.greeting,
    required this.firstName,
    required this.onNotifications,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, d MMMM').format(DateTime.now());

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.staffPrimary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 12, 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$greeting,',
                        style: AppTextStyles.bodyM
                            .copyWith(color: Colors.white60)),
                    const SizedBox(height: 2),
                    Text(firstName,
                        style: AppTextStyles.displayM
                            .copyWith(color: Colors.white)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 12, color: Colors.white54),
                        const SizedBox(width: 4),
                        Text(today,
                            style: AppTextStyles.labelL
                                .copyWith(color: Colors.white54)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  _HeaderBtn(
                      icon: Icons.notifications_outlined,
                      onTap: onNotifications),
                  const SizedBox(height: 4),
                  _HeaderBtn(
                      icon: Icons.account_circle_outlined,
                      onTap: onProfile),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      );
}

class _StatRow extends StatelessWidget {
  final StaffDashboardStats? stats;
  final bool isLoading;
  final AppLocalizations l10n;
  const _StatRow(
      {required this.stats,
      required this.isLoading,
      required this.l10n});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.receipt_long_outlined,
              label: l10n.salesToday,
              value: isLoading ? '—' : '${stats?.mySalesToday ?? 0}',
              accent: AppColors.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.payments_outlined,
              label: l10n.revenue,
              value: isLoading
                  ? '—'
                  : formatFCFA(stats?.myRevenueToday ?? 0),
              accent: AppColors.staffPrimary,
            ),
          ),
        ],
      );
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTextStyles.labelM
                          .copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: AppTextStyles.headingS
                        .copyWith(color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _NewSaleCTA extends StatelessWidget {
  final VoidCallback onTap;
  final AppLocalizations l10n;
  const _NewSaleCTA({required this.onTap, required this.l10n});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.staffPrimary, Color(0xFF1A5C48)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.staffPrimary.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.add_shopping_cart,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.newSale,
                        style: AppTextStyles.headingM
                            .copyWith(color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(l10n.startRecordingSale,
                        style: AppTextStyles.bodyS
                            .copyWith(color: Colors.white60)),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward,
                    color: Colors.white, size: 18),
              ),
            ],
          ),
        ),
      );
}

class _PriceListTile extends StatelessWidget {
  final VoidCallback onTap;
  final AppLocalizations l10n;
  const _PriceListTile({required this.onTap, required this.l10n});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.format_list_bulleted,
                    color: AppColors.accent, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.priceList,
                        style: AppTextStyles.headingS),
                    Text(l10n.viewAllProducts,
                        style: AppTextStyles.bodyS),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 22),
            ],
          ),
        ),
      );
}

class _TransactionList extends StatelessWidget {
  final List<RecentSaleItem> sales;
  final AppLocalizations l10n;
  const _TransactionList({required this.sales, required this.l10n});

  @override
  Widget build(BuildContext context) {
    if (sales.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 44, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Text(l10n.noSalesYet,
                style: AppTextStyles.bodyM
                    .copyWith(color: Colors.grey[500])),
            const SizedBox(height: 4),
            Text(l10n.transactionsWillAppear,
                style: AppTextStyles.bodyS),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < sales.length; i++) ...[
            _TransactionTile(sale: sales[i], index: i, l10n: l10n),
            if (i < sales.length - 1)
              const Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: AppColors.border),
          ],
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final RecentSaleItem sale;
  final int index;
  final AppLocalizations l10n;
  const _TransactionTile(
      {required this.sale, required this.index, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final isCredit = sale.customerId != null;
    final time = DateFormat('h:mm a').format(sale.createdAt.toLocal());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.staffPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '#${index + 1}',
                style: AppTextStyles.labelM.copyWith(
                    color: AppColors.staffPrimary,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isCredit ? l10n.creditSale : l10n.cashSale,
                      style: AppTextStyles.bodyM
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (isCredit) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.dangerLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(l10n.credit,
                            style: AppTextStyles.labelS.copyWith(
                                color: AppColors.danger,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${sale.itemCount} item${sale.itemCount == 1 ? '' : 's'}  ·  $time',
                  style: AppTextStyles.bodyS,
                ),
              ],
            ),
          ),
          Text(
            formatFCFA(sale.totalAmount),
            style: AppTextStyles.headingS.copyWith(
                color:
                    isCredit ? AppColors.danger : AppColors.staffPrimary),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner(this.message);

  @override
  Widget build(BuildContext context) => Container(
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
              child: Text(message,
                  style: AppTextStyles.bodyS
                      .copyWith(color: AppColors.danger)),
            ),
          ],
        ),
      );
}
