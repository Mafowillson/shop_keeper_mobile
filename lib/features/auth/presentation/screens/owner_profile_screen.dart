import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/features/auth/domain/entities/user.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';

class OwnerProfileScreen extends StatelessWidget {
  const OwnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final initials = _initials(user?.name);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 268,
            pinned: true,
            backgroundColor: AppColors.ownerPrimary,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'My Profile',
              style: AppTextStyles.headingM.copyWith(color: Colors.white),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: _HeroSection(user: user, initials: initials),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatsStrip(user: user),
                const SizedBox(height: 24),
                const _SectionLabel('Account details'),
                const SizedBox(height: 10),
                _InfoCard(rows: [
                  _InfoRow(
                    icon: Icons.store_outlined,
                    label: 'Shop ID',
                    value: _truncate(user?.shopId),
                  ),
                  _InfoRow(
                    icon: Icons.fingerprint,
                    label: 'User ID',
                    value: _truncate(user?.id),
                  ),
                  const _InfoRow(
                    icon: Icons.lock_outline_rounded,
                    label: 'Password',
                    value: '••••••••',
                  ),
                ]),
                const SizedBox(height: 24),
                const _SectionLabel('Quick actions'),
                const SizedBox(height: 10),
                _ActionCard(tiles: [
                  _ActionTileData(
                    icon: Icons.person_add_alt_1_outlined,
                    label: 'Add Staff Member',
                    subtitle: 'Create login credentials for new staff',
                    color: AppColors.ownerPrimary,
                    onTap: () => context.push('/owner/staff/create'),
                  ),
                  _ActionTileData(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    subtitle: 'Manage preferences and security',
                    color: AppColors.ownerPrimary,
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: 16),
                _LogoutButton(
                  onTap: () => _confirmLogout(context),
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign out?', style: AppTextStyles.headingM),
        content: Text(
          'You will need to log back in to access your account.',
          style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<AuthProvider>().logout();
    if (context.mounted) context.go('/login');
  }

  static String _initials(String? name) {
    if (name == null || name.isEmpty) return 'O';
    return name
        .split(' ')
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase())
        .take(2)
        .join();
  }

  static String _truncate(String? value) {
    if (value == null || value.isEmpty) return 'N/A';
    if (value.length <= 16) return value;
    return '${value.substring(0, 8)}…${value.substring(value.length - 4)}';
  }
}

// ── Hero ─────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final User? user;
  final String initials;

  const _HeroSection({required this.user, required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.ownerPrimaryDark, AppColors.ownerPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          const Positioned(
            right: -40,
            top: -30,
            child: _Circle(size: 200, opacity: 0.06),
          ),
          const Positioned(
            right: 40,
            bottom: 50,
            child: _Circle(size: 110, opacity: 0.07),
          ),
          const Positioned(
            left: -20,
            bottom: -20,
            child: _Circle(size: 130, opacity: 0.05),
          ),
          // Profile content
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Avatar
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.18),
                            border: Border.all(color: Colors.white, width: 2.5),
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: AppTextStyles.headingL.copyWith(
                                color: Colors.white,
                                fontSize: 26,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? 'Owner',
                                style: AppTextStyles.headingL.copyWith(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                user?.email ?? '',
                                style: AppTextStyles.bodyM.copyWith(
                                  color: Colors.white.withValues(alpha: 0.75),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              _RoleBadge(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;
  final double opacity;

  const _Circle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.55),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_outlined, size: 13, color: AppColors.accent),
          const SizedBox(width: 5),
          Text(
            'Owner',
            style: AppTextStyles.labelL.copyWith(color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}

// ── Stats strip ───────────────────────────────────────────────────────────────

class _StatsStrip extends StatelessWidget {
  final User? user;

  const _StatsStrip({required this.user});

  @override
  Widget build(BuildContext context) {
    final isActive = user?.isActive == true;
    final isVerified = user?.emailVerified == true;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _StatCell(
              icon: Icons.circle,
              iconColor: isActive ? AppColors.success : AppColors.danger,
              label: 'Status',
              value: isActive ? 'Active' : 'Inactive',
              valueColor: isActive ? AppColors.success : AppColors.danger,
            ),
            const VerticalDivider(width: 1, thickness: 1),
            _StatCell(
              icon: Icons.mark_email_read_outlined,
              iconColor: isVerified ? AppColors.success : AppColors.warning,
              label: 'Email',
              value: isVerified ? 'Verified' : 'Pending',
              valueColor: isVerified ? AppColors.success : AppColors.warning,
            ),
            const VerticalDivider(width: 1, thickness: 1),
            const _StatCell(
              icon: Icons.admin_panel_settings_outlined,
              iconColor: AppColors.ownerPrimary,
              label: 'Role',
              value: 'Owner',
              valueColor: AppColors.ownerPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color valueColor;

  const _StatCell({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.headingS.copyWith(color: valueColor),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.labelM.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(text, style: AppTextStyles.headingM),
    );
  }
}

// ── Info card ─────────────────────────────────────────────────────────────────

class _InfoRow {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});
}

class _InfoCard extends StatelessWidget {
  final List<_InfoRow> rows;

  const _InfoCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            for (int i = 0; i < rows.length; i++) ...[
              _InfoTile(row: rows[i]),
              if (i < rows.length - 1)
                const Divider(height: 1, indent: 56, endIndent: 0),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final _InfoRow row;

  const _InfoTile({required this.row});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.ownerPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(row.icon, size: 16, color: AppColors.ownerPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              row.label,
              style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Text(
            row.value,
            style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ── Action card ───────────────────────────────────────────────────────────────

class _ActionTileData {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTileData({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}

class _ActionCard extends StatelessWidget {
  final List<_ActionTileData> tiles;

  const _ActionCard({required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            for (int i = 0; i < tiles.length; i++) ...[
              _ActionTile(data: tiles[i]),
              if (i < tiles.length - 1)
                const Divider(height: 1, indent: 68, endIndent: 0),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final _ActionTileData data;

  const _ActionTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(data.icon, color: data.color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.label,
                    style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.subtitle,
                    style: AppTextStyles.bodyS,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[350], size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Logout button ─────────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: AppColors.dangerLight,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.danger,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sign Out',
                        style: AppTextStyles.bodyM.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.danger,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Sign out of your ShopKeeper account',
                        style: AppTextStyles.bodyS,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.danger.withValues(alpha: 0.5), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
