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

  @override
  Widget build(BuildContext context) {
    final staffName = context.select<AuthProvider, String>(
      (p) => p.currentUser?.name ?? 'Staff',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        backgroundColor: AppColors.staffPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<StaffDashboardProvider>().loadStats(),
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => context.push('/staff/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => context.push('/staff/profile'),
          ),
        ],
      ),
      body: Consumer<StaffDashboardProvider>(
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

                  _WelcomeCard(name: staffName),
                  const SizedBox(height: 24),

                  _TodayStats(stats: stats),
                  const SizedBox(height: 24),

                  Text('Quick Actions', style: AppTextStyles.headingM),
                  const SizedBox(height: 12),
                  _QuickActions(),
                  const SizedBox(height: 24),

                  Text('Recent Transactions', style: AppTextStyles.headingM),
                  const SizedBox(height: 12),
                  _RecentTransactions(sales: stats?.recentSales ?? []),
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
              AppColors.staffPrimary,
              AppColors.staffPrimary.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, $name!',
                style: AppTextStyles.headingL.copyWith(color: Colors.white)),
            const SizedBox(height: 8),
            Text("Here's your activity for today",
                style: AppTextStyles.bodyM.copyWith(color: Colors.white70)),
          ],
        ),
      );
}

class _TodayStats extends StatelessWidget {
  final StaffDashboardStats? stats;
  const _TodayStats({required this.stats});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.shopping_cart,
              label: 'Sales Today',
              value: '${stats?.mySalesToday ?? 0}',
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.trending_up,
              label: 'Revenue',
              value: formatFCFA(stats?.myRevenueToday ?? 0),
              color: AppColors.success,
            ),
          ),
        ],
      );
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard(
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
            icon: Icons.add_shopping_cart,
            label: 'New Sale',
            color: AppColors.accent,
            onTap: () => context.push('/staff/sale/new'),
          ),
          _ActionButton(
            icon: Icons.list,
            label: 'Price List',
            color: AppColors.staffPrimary,
            onTap: () => context.push('/staff/prices'),
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

class _RecentTransactions extends StatelessWidget {
  final List<RecentSaleItem> sales;
  const _RecentTransactions({required this.sales});

  @override
  Widget build(BuildContext context) {
    if (sales.isEmpty) {
      return Center(
        child: Text('No transactions yet today',
            style: AppTextStyles.bodyM.copyWith(color: Colors.grey[500])),
      );
    }
    return Column(
      children: sales.map((sale) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sale.customerId != null ? 'Customer sale' : 'Walk-in',
                    style: AppTextStyles.bodyM
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${sale.itemCount} item${sale.itemCount == 1 ? '' : 's'} • ${DateFormat('h:mm a').format(sale.createdAt.toLocal())}',
                    style: AppTextStyles.bodyM
                        .copyWith(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              Text(
                formatFCFA(sale.totalAmount),
                style: AppTextStyles.bodyM.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.staffPrimary),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
