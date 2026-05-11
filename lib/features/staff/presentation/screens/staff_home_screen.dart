import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';

class StaffHomeScreen extends StatelessWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        backgroundColor: AppColors.staffPrimary,
        elevation: 0,
        actions: [
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(),
            const SizedBox(height: 24),

            // Today's Stats
            _buildTodayStats(),
            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: AppTextStyles.headingM,
            ),
            const SizedBox(height: 12),
            _buildQuickActions(context),
            const SizedBox(height: 24),

            // Recent Transactions
            Text(
              'Recent Transactions',
              style: AppTextStyles.headingM,
            ),
            const SizedBox(height: 12),
            _buildRecentTransactions(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.staffPrimary, AppColors.staffPrimary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, Marie!',
            style: AppTextStyles.headingL.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re doing great today. Keep up the good work!',
            style: AppTextStyles.bodyM.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.shopping_cart,
            label: 'Sales Today',
            value: '18',
            color: AppColors.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.trending_up,
            label: 'Revenue',
            value: 'FCFA 125K',
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
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
          onTap: () => context.push('/staff/sale/new'),
        ),
        _buildActionButton(
          icon: Icons.list,
          label: 'Price List',
          color: AppColors.staffPrimary,
          onTap: () => context.push('/staff/prices'),
        ),
        _buildActionButton(
          icon: Icons.history,
          label: 'View History',
          color: AppColors.success,
          onTap: () {},
        ),
        _buildActionButton(
          icon: Icons.info,
          label: 'Help',
          color: AppColors.warning,
          onTap: () {},
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

  Widget _buildRecentTransactions() {
    final transactions = [
      {
        'id': '1',
        'time': '2:45 PM',
        'items': 3,
        'amount': 8500,
        'customer': 'Walk-in'
      },
      {
        'id': '2',
        'time': '1:30 PM',
        'items': 2,
        'amount': 5200,
        'customer': 'Walk-in'
      },
      {
        'id': '3',
        'time': '11:15 AM',
        'items': 4,
        'amount': 12300,
        'customer': 'John Doe'
      },
    ];

    return Column(
      children: transactions.map((transaction) {
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
                    transaction['customer']! as String,
                    style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${transaction['items']} items • ${transaction['time']}',
                    style: AppTextStyles.bodyM.copyWith(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Text(
                'FCFA ${transaction['amount']}',
                style: AppTextStyles.bodyM.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.staffPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
