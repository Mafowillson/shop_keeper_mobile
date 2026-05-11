import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/widgets/app_button.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';

class StaffProfileScreen extends StatelessWidget {
  const StaffProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final initials = user?.name.split(' ').map((part) => part.isNotEmpty ? part[0] : '').join() ?? 'S';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Staff Profile'),
        backgroundColor: AppColors.staffPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.staffPrimary, AppColors.staffPrimary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      initials,
                      style: AppTextStyles.headingL.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    user?.name ?? 'Staff',
                    style: AppTextStyles.headingL.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'No email provided',
                    style: AppTextStyles.bodyM.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Staff account',
                      style: AppTextStyles.bodyM.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Profile details', style: AppTextStyles.headingM),
            const SizedBox(height: 16),
            _ProfileTile(label: 'Shop ID', value: user?.shopId ?? 'N/A'),
            const SizedBox(height: 12),
            _ProfileTile(label: 'Role', value: user?.role.toString().split('.').last ?? 'N/A'),
            const SizedBox(height: 12),
            _ProfileTile(label: 'Status', value: user?.isActive == true ? 'Active' : 'Inactive'),
            const SizedBox(height: 12),
            _ProfileTile(label: 'User ID', value: user?.id ?? 'N/A'),
            const SizedBox(height: 24),
            Text('Security', style: AppTextStyles.headingM),
            const SizedBox(height: 16),
            const _ProfileTile(label: 'Password', value: '••••••••'),
            const SizedBox(height: 24),
            AppButton.outlined(
              label: 'Sign Out',
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyM.copyWith(color: Colors.grey[600]),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
