import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/utils/currency_formatter.dart' show formatFCFA;
import 'package:shopkeeper/core/widgets/section_header.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:shopkeeper/features/dashboard/presentation/providers/dashboard_provider.dart';

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
      context.read<DashboardProvider>().loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ownerName = context.select<AuthProvider, String>(
      (p) => p.currentUser?.name ?? 'Owner',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppColors.ownerPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DashboardProvider>().loadStats(),
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.stats == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = provider.stats;

          return RefreshIndicator(
            onRefresh: provider.loadStats,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (provider.errorMessage != null)
                    _ErrorBanner(provider.errorMessage!),

                  _WelcomeCard(name: ownerName),
                  const SizedBox(height: 24),

                  _KeyMetrics(stats: stats),
                  const SizedBox(height: 24),

                  SectionHeader(
                    title: 'Sales — Last 7 Days',
                    onActionPressed: () => context.push('/owner/sales'),
                  ),
                  const SizedBox(height: 12),
                  _WeeklyChart(weekly: stats?.weeklyRevenue ?? List.filled(7, 0)),
                  const SizedBox(height: 24),

                  SectionHeader(
                    title: 'Alerts',
                    onActionPressed: () => context.push('/owner/notifications'),
                  ),
                  const SizedBox(height: 12),
                  _AlertsSection(stats: stats),
                  const SizedBox(height: 24),

                  SectionHeader(title: 'Recent Activity', onActionPressed: () {}),
                  const SizedBox(height: 12),
                  _ActivityFeedSection(feed: stats?.activityFeed ?? []),
                  const SizedBox(height: 24),

                  SectionHeader(title: 'Quick Actions', onActionPressed: () {}),
                  const SizedBox(height: 12),
                  _QuickActions(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner(this.message);

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(message,
            style: AppTextStyles.bodyM.copyWith(color: AppColors.danger)),
      );
}

class _WelcomeCard extends StatelessWidget {
  final String name;
  const _WelcomeCard({required this.name});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.ownerPrimary,
              AppColors.ownerPrimary.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back, $name!',
                style: AppTextStyles.headingL.copyWith(color: Colors.white)),
            const SizedBox(height: 8),
            Text("Here's your business overview for today",
                style: AppTextStyles.bodyM.copyWith(color: Colors.white70)),
          ],
        ),
      );
}

class _KeyMetrics extends StatelessWidget {
  final DashboardStats? stats;
  const _KeyMetrics({required this.stats});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: _MetricCard(
              icon: Icons.trending_up,
              label: "Today's Sales",
              value: formatFCFA(stats?.todaySales ?? 0),
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MetricCard(
              icon: Icons.shopping_cart,
              label: 'Transactions',
              value: '${stats?.transactionCount ?? 0}',
              color: AppColors.accent,
            ),
          ),
        ],
      );
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _MetricCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(label,
                style: AppTextStyles.bodyM.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(value,
                style: AppTextStyles.headingM.copyWith(color: color)),
          ],
        ),
      );
}

class _WeeklyChart extends StatelessWidget {
  final List<double> weekly;
  const _WeeklyChart({required this.weekly});

  @override
  Widget build(BuildContext context) {
    final days = _dayLabels();
    final maxVal = weekly.fold(0.0, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('This week',
                  style:
                      AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600)),
              Text(
                'Total: ${formatFCFA(weekly.fold(0.0, (a, b) => a + b))}',
                style: AppTextStyles.bodyM.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final height =
                  maxVal > 0 ? (weekly[i] / maxVal) * 80 : 4.0;
              return Column(
                children: [
                  Container(
                    width: 28,
                    height: height.clamp(4.0, 80.0),
                    decoration: BoxDecoration(
                      color: AppColors.ownerPrimary,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(days[i],
                      style:
                          AppTextStyles.bodyM.copyWith(fontSize: 11)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  List<String> _dayLabels() {
    // Index 0 = 6 days ago, index 6 = today (matches backend WeeklyRevenue).
    final today = DateTime.now();
    return List.generate(
        7, (i) => DateFormat('E').format(today.subtract(Duration(days: 6 - i))));
  }
}

class _AlertsSection extends StatelessWidget {
  final DashboardStats? stats;
  const _AlertsSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    final lowStock = stats?.lowStockCount ?? 0;
    final debts = stats?.totalDebts ?? 0;

    return Column(
      children: [
        _AlertItem(
          icon: Icons.warning_amber,
          title: 'Low Stock',
          description: lowStock == 0
              ? 'All products are well stocked'
              : '$lowStock product${lowStock == 1 ? '' : 's'} below threshold',
          color: lowStock > 0 ? AppColors.warning : AppColors.success,
          onTap: () => context.push('/owner/products'),
        ),
        const SizedBox(height: 12),
        _AlertItem(
          icon: Icons.account_balance_wallet,
          title: 'Outstanding Debts',
          description: debts == 0
              ? 'No outstanding debts'
              : '${formatFCFA(debts)} total owed',
          color: debts > 0 ? AppColors.danger : AppColors.success,
          onTap: () => context.push('/owner/debts'),
        ),
      ],
    );
  }
}

class _AlertItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;
  const _AlertItem(
      {required this.icon,
      required this.title,
      required this.description,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTextStyles.bodyM.copyWith(
                            fontWeight: FontWeight.w600, color: color)),
                    Text(description,
                        style: AppTextStyles.bodyM
                            .copyWith(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      );
}

class _ActivityFeedSection extends StatelessWidget {
  final List<ActivityFeed> feed;
  const _ActivityFeedSection({required this.feed});

  @override
  Widget build(BuildContext context) {
    if (feed.isEmpty) {
      return Center(
        child: Text('No activity yet',
            style: AppTextStyles.bodyM.copyWith(color: Colors.grey[500])),
      );
    }
    return Column(
      children: feed
          .map((item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.receipt_long,
                          color: AppColors.accent, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title,
                              style: AppTextStyles.bodyM
                                  .copyWith(fontWeight: FontWeight.w600)),
                          Text(item.subtitle,
                              style: AppTextStyles.bodyM.copyWith(
                                  color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ),
                    Text(
                      _timeAgo(item.timestamp),
                      style: AppTextStyles.bodyM
                          .copyWith(color: Colors.grey[400], fontSize: 11),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: [
          _ActionButton(
            icon: Icons.inventory_2,
            label: 'Add Product',
            color: AppColors.success,
            onTap: () => context.push('/owner/products/add'),
          ),
          _ActionButton(
            icon: Icons.bar_chart,
            label: 'View Sales',
            color: AppColors.accent,
            onTap: () => context.push('/owner/sales'),
          ),
          _ActionButton(
            icon: Icons.people,
            label: 'View Debts',
            color: AppColors.warning,
            onTap: () => context.push('/owner/debts'),
          ),
          _ActionButton(
            icon: Icons.auto_awesome,
            label: 'AI Insights',
            color: AppColors.accent,
            onTap: () => context.push('/owner/chat'),
          ),
        ],
      );
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(label,
                  style: AppTextStyles.bodyM
                      .copyWith(color: color, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}
