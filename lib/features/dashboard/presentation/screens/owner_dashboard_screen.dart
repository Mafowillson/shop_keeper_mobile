import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/constants/app_strings.dart';
import 'package:shopkeeper/core/utils/currency_formatter.dart' show formatFCFA;
import 'package:shopkeeper/core/widgets/offline_banner.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:shopkeeper/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shopId = context.read<AuthProvider>().currentUser?.shopId ?? '';
      context.read<DashboardProvider>().loadStats(shopId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ownerName = context.select<AuthProvider, String>(
      (p) => p.currentUser?.name ?? l10n.ownerRole,
    );
    final shopId = context.read<AuthProvider>().currentUser?.shopId ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: () => provider.loadStats(shopId),
            color: AppColors.ownerPrimary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: OfflineBanner()),
                _DashboardHeader(
                  ownerName: ownerName,
                  onRefresh: () => provider.loadStats(shopId),
                  l10n: l10n,
                ),
                if (provider.isLoading && provider.stats == null)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.ownerPrimary),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        if (provider.errorMessage != null) ...[
                          _ErrorBanner(provider.errorMessage!),
                          const SizedBox(height: 16),
                        ],
                        _MetricsRow(stats: provider.stats, l10n: l10n),
                        const SizedBox(height: 12),
                        _AlertsRow(
                          stats: provider.stats,
                          onStockTap: () => context.push('/owner/products'),
                          onDebtTap: () => context.push('/owner/debts'),
                          l10n: l10n,
                        ),
                        const SizedBox(height: 24),
                        _SectionLabel(l10n.revenueLastSevenDays),
                        const SizedBox(height: 10),
                        _WeeklyChartCard(
                          weekly: provider.stats?.weeklyRevenue ??
                              List.filled(7, 0.0),
                          l10n: l10n,
                        ),
                        const SizedBox(height: 24),
                        _SectionLabel(l10n.quickActions),
                        const SizedBox(height: 10),
                        _QuickActionsGrid(l10n: l10n),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _SectionLabel(l10n.recentActivity),
                            TextButton(
                              onPressed: () => context.push('/owner/sales'),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                foregroundColor: AppColors.ownerPrimary,
                                textStyle: AppTextStyles.labelM.copyWith(
                                  color: AppColors.ownerPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: const Text(AppStrings.seeAll),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _ActivityList(
                          feed: provider.stats?.activityFeed ?? [],
                          l10n: l10n,
                        ),
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

class _DashboardHeader extends StatelessWidget {
  final String ownerName;
  final VoidCallback onRefresh;
  final AppLocalizations l10n;
  const _DashboardHeader(
      {required this.ownerName, required this.onRefresh, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final firstName = ownerName.split(' ').first;
    final locale = Localizations.localeOf(context).languageCode;
    final dateStr = DateFormat('EEEE, d MMMM', locale).format(DateTime.now());

    return SliverAppBar(
      expandedHeight: 130,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.ownerPrimary,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: onRefresh,
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.ownerPrimaryDark, AppColors.ownerPrimary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 72, 56, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                l10n.helloName(firstName),
                style: AppTextStyles.headingL.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 2),
              Text(
                dateStr,
                style: AppTextStyles.bodyS.copyWith(color: Colors.white60),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTextStyles.headingS.copyWith(color: AppColors.textSecondary),
      );
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner(this.message);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
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
          ],
        ),
      );
}

class _MetricsRow extends StatelessWidget {
  final DashboardStats? stats;
  final AppLocalizations l10n;
  const _MetricsRow({required this.stats, required this.l10n});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            flex: 3,
            child: _MetricTile(
              label: l10n.todaysRevenue,
              value: formatFCFA(stats?.todaySales ?? 0),
              icon: Icons.payments_outlined,
              color: AppColors.ownerPrimary,
              large: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: _MetricTile(
              label: l10n.transactions,
              value: '${stats?.transactionCount ?? 0}',
              icon: Icons.receipt_long_outlined,
              color: AppColors.accent,
              large: false,
            ),
          ),
        ],
      );
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool large;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.large,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: large
                  ? AppTextStyles.displayS
                      .copyWith(color: AppColors.textPrimary)
                  : AppTextStyles.headingL
                      .copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style:
                  AppTextStyles.labelM.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
}

class _AlertsRow extends StatelessWidget {
  final DashboardStats? stats;
  final VoidCallback onStockTap;
  final VoidCallback onDebtTap;
  final AppLocalizations l10n;
  const _AlertsRow(
      {required this.stats,
      required this.onStockTap,
      required this.onDebtTap,
      required this.l10n});

  @override
  Widget build(BuildContext context) {
    final lowStock = stats?.lowStockCount ?? 0;
    final debts = stats?.totalDebts ?? 0.0;

    return Row(
      children: [
        Expanded(
          child: _AlertChip(
            icon: Icons.inventory_2_outlined,
            label: lowStock == 0
                ? l10n.stockOk
                : '$lowStock ${l10n.lowStockAlert}',
            color: lowStock > 0 ? AppColors.warning : AppColors.success,
            onTap: onStockTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _AlertChip(
            icon: Icons.account_balance_wallet_outlined,
            label:
                debts == 0 ? l10n.noDebts : '${formatFCFA(debts)} ${l10n.owed}',
            color: debts > 0 ? AppColors.danger : AppColors.success,
            onTap: onDebtTap,
          ),
        ),
      ],
    );
  }
}

class _AlertChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _AlertChip(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.labelL.copyWith(color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.chevron_right, color: color, size: 16),
            ],
          ),
        ),
      );
}

class _WeeklyChartCard extends StatelessWidget {
  final List<double> weekly;
  final AppLocalizations l10n;
  const _WeeklyChartCard({required this.weekly, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final days = _dayLabels(locale);
    final maxVal = weekly.fold(0.0, (a, b) => a > b ? a : b);
    final total = weekly.fold(0.0, (a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.weeklyTotal,
                style: AppTextStyles.headingS
                    .copyWith(color: AppColors.textSecondary),
              ),
              Text(
                formatFCFA(total),
                style: AppTextStyles.headingS
                    .copyWith(color: AppColors.ownerPrimary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final barH = maxVal > 0 ? (weekly[i] / maxVal) * 94 : 0.0;
                final isToday = i == 6;
                return Container(
                  width: 26,
                  height: barH.clamp(4.0, 94.0),
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppColors.ownerPrimary
                        : AppColors.ownerPrimary.withValues(alpha: 0.22),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(5)),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (i) {
              final isToday = i == 6;
              return SizedBox(
                width: 26,
                child: Text(
                  days[i],
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelS.copyWith(
                    color:
                        isToday ? AppColors.ownerPrimary : AppColors.textHint,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  List<String> _dayLabels(String locale) {
    final today = DateTime.now();
    return List.generate(
        7,
        (i) => DateFormat('E', locale)
            .format(today.subtract(Duration(days: 6 - i))));
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final AppLocalizations l10n;
  const _QuickActionsGrid({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _Action(
        icon: Icons.point_of_sale_outlined,
        label: l10n.newSale,
        color: AppColors.accent,
        route: '/owner/sale/new',
      ),
      _Action(
        icon: Icons.add_box_outlined,
        label: l10n.addProduct,
        color: AppColors.success,
        route: '/owner/products/add',
      ),
      _Action(
        icon: Icons.bar_chart_rounded,
        label: l10n.viewSales,
        color: AppColors.ownerPrimary,
        route: '/owner/sales',
      ),
      _Action(
        icon: Icons.price_check_outlined,
        label: l10n.priceList,
        color: AppColors.accent,
        route: '/owner/prices',
      ),
      _Action(
        icon: Icons.people_outline,
        label: l10n.debts,
        color: AppColors.danger,
        route: '/owner/debts',
      ),
      _Action(
        icon: Icons.auto_awesome_outlined,
        label: l10n.aiInsights,
        color: AppColors.textSecondary,
        route: '/owner/chat',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.4,
      ),
      itemCount: actions.length,
      itemBuilder: (context, i) => _ActionTile(action: actions[i]),
    );
  }
}

class _Action {
  final IconData icon;
  final String label;
  final Color color;
  final String route;
  const _Action({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });
}

class _ActionTile extends StatelessWidget {
  final _Action action;
  const _ActionTile({required this.action});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => context.push(action.route),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: action.color.withValues(alpha: 0.07),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(action.icon, color: action.color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  action.label,
                  style: AppTextStyles.headingS
                      .copyWith(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      );
}

class _ActivityList extends StatelessWidget {
  final List<ActivityFeed> feed;
  final AppLocalizations l10n;
  const _ActivityList({required this.feed, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final previewFeed = feed.length > 5 ? feed.sublist(0, 5) : feed;

    if (previewFeed.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(l10n.noRecentActivity, style: AppTextStyles.bodyS),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(previewFeed.length, (i) {
          final item = previewFeed[i];
          final isLast = i == previewFeed.length - 1;
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.receipt_long,
                          color: AppColors.accent, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: AppTextStyles.labelL.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(item.subtitle, style: AppTextStyles.bodyS),
                        ],
                      ),
                    ),
                    Text(
                      _timeAgo(item.timestamp),
                      style: AppTextStyles.labelS
                          .copyWith(color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(height: 1, indent: 64, color: AppColors.border),
            ],
          );
        }),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return l10n.timeAgoMinutes(diff.inMinutes);
    if (diff.inHours < 24) return l10n.timeAgoHours(diff.inHours);
    return l10n.timeAgoDays(diff.inDays);
  }
}
