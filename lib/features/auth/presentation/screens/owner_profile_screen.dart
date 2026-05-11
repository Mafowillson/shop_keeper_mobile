import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/widgets/app_button.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';

class OwnerProfileScreen extends StatelessWidget {
  const OwnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final initials = user?.name.split(' ').map((part) => part.isNotEmpty ? part[0] : '').join() ?? 'O';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Owner Profile'),
        backgroundColor: AppColors.ownerPrimary,
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
                  colors: [AppColors.ownerPrimary, AppColors.ownerPrimary.withOpacity(0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          initials,
                          style: AppTextStyles.headingL.copyWith(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'Owner',
                              style: AppTextStyles.headingL.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              user?.email ?? 'No email provided',
                              style: AppTextStyles.bodyM.copyWith(color: Colors.white70),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.16),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Owner account',
                                style: AppTextStyles.bodyM.copyWith(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton.outlined(
                          label: 'Edit profile',
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton.accent(
                          label: 'Settings',
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Account details', style: AppTextStyles.headingM),
            const SizedBox(height: 16),
            _ProfileTile(label: 'Shop ID', value: user?.shopId ?? 'N/A'),
            const SizedBox(height: 12),
            _ProfileTile(label: 'Role', value: user?.role.toString().split('.').last ?? 'N/A'),
            const SizedBox(height: 12),
            _ProfileTile(label: 'Status', value: user?.isActive == true ? 'Active' : 'Inactive'),
            const SizedBox(height: 12),
            _ProfileTile(label: 'User ID', value: user?.id ?? 'N/A'),
            const SizedBox(height: 16),
            const _ProfileTile(label: 'Password', value: '••••••••'),
            const SizedBox(height: 24),
            Text('Profile actions', style: AppTextStyles.headingM),
            const SizedBox(height: 16),
            _ActionTile(
              icon: Icons.settings,
              label: 'Settings',
              subtitle: 'Manage account preferences and security',
              color: AppColors.ownerPrimary,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.logout,
              label: 'Log out',
              subtitle: 'Sign out of ShopKeeper',
              color: AppColors.danger,
              onTap: () async {
                await context.read<AuthProvider>().logout();
                if(context.mounted) context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTextStyles.bodyS.copyWith(color: Colors.grey[600])),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}


class _ProfileTile extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileTile({required this.label, required this.value, super.key});

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
