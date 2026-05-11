import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/widgets/section_header.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppColors.ownerPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DashboardProvider>().loadStats();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(),
            const SizedBox(height: 24),

            // Key Metrics
            _buildKeyMetrics(),
            const SizedBox(height: 24),

            // Sales Overview
            SectionHeader(title: 'Sales Overview', onActionPressed: () {}),
            const SizedBox(height: 12),
            _buildSalesOverview(),
            const SizedBox(height: 24),

            // Alerts Section
            SectionHeader(title: 'Alerts & Notifications', onActionPressed: () {
              context.push('/owner/notifications');
            }),
            const SizedBox(height: 12),
            _buildAlertsSection(),
            const SizedBox(height: 24),

            // Quick Actions
            SectionHeader(title: 'Quick Actions', onActionPressed: () {}),
            const SizedBox(height: 12),
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.ownerPrimary, AppColors.ownerPrimary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, Owner!',
            style: AppTextStyles.headingL.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Here\'s your business overview for today',
            style: AppTextStyles.bodyM.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            icon: Icons.trending_up,
            label: 'Today\'s Sales',
            value: 'FCFA 125,450',
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            icon: Icons.shopping_cart,
            label: 'Transactions',
            value: '24',
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTextStyles.bodyM.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.headingM.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesOverview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'This Week',
                style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '+12.5%',
                  style: AppTextStyles.bodyM.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Simple bar chart representation
          _buildSimpleChart(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: FCFA 850,000',
                style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                'Avg: FCFA 121,429',
                style: AppTextStyles.bodyM.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleChart() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final values = [65, 78, 90, 81, 95, 87, 72];
    final maxValue = values.reduce((a, b) => a > b ? a : b).toDouble();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(days.length, (index) {
        final height = (values[index] / maxValue) * 100;
        return Column(
          children: [
            Container(
              width: 30,
              height: height,
              decoration: BoxDecoration(
                color: AppColors.ownerPrimary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              days[index],
              style: AppTextStyles.bodyM.copyWith(fontSize: 12),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildAlertsSection() {
    return Column(
      children: [
        _buildAlertItem(
          icon: Icons.warning_amber,
          title: 'Low Stock Alert',
          description: '5 products below minimum threshold',
          color: AppColors.warning,
          onTap: () => context.push('/owner/products'),
        ),
        const SizedBox(height: 12),
        _buildAlertItem(
          icon: Icons.account_balance_wallet,
          title: 'Pending Payments',
          description: '3 customers with overdue debts',
          color: AppColors.danger,
          onTap: () => context.push('/owner/debts'),
        ),
        const SizedBox(height: 12),
        _buildAlertItem(
          icon: Icons.trending_up,
          title: 'High Sales Day',
          description: 'Sales 35% above average today',
          color: AppColors.success,
          onTap: () => context.push('/owner/sales'),
        ),
      ],
    );
  }

  Widget _buildAlertItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  Text(
                    description,
                    style: AppTextStyles.bodyM.copyWith(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildActionButton(
          icon: Icons.add_shopping_cart,
          label: 'New Sale',
          color: AppColors.accent,
          onTap: () => context.push('/owner/sales'),
        ),
        _buildActionButton(
          icon: Icons.inventory_2,
          label: 'Add Product',
          color: AppColors.success,
          onTap: () => context.push('/owner/products/add'),
        ),
        _buildActionButton(
          icon: Icons.people,
          label: 'View Debts',
          color: AppColors.warning,
          onTap: () => context.push('/owner/debts'),
        ),
        _buildActionButton(
          icon: Icons.auto_awesome,
          label: 'AI Insights',
          color: AppColors.accent,
          onTap: () => context.push('/owner/chat'),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.bodyM.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
