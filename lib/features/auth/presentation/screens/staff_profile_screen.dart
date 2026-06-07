import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/features/auth/domain/entities/user.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';

class StaffProfileScreen extends StatefulWidget {
  const StaffProfileScreen({super.key});

  @override
  State<StaffProfileScreen> createState() => _StaffProfileScreenState();
}

class _StaffProfileScreenState extends State<StaffProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().refreshShopInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<AuthProvider>().currentUser;
    final initials = _initials(user?.name);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 268,
            pinned: true,
            backgroundColor: AppColors.staffPrimary,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(
              l10n.myProfile,
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
                _SectionLabel(l10n.accountDetails),
                const SizedBox(height: 10),
                _InfoCard(rows: [
                  _InfoRow(
                    icon: Icons.store_outlined,
                    label: l10n.shopNameLabel,
                    value: user?.shopName.isNotEmpty == true
                        ? user!.shopName
                        : l10n.notSet,
                    accentColor: AppColors.staffPrimary,
                  ),
                  _InfoRow(
                    icon: Icons.person_outline_rounded,
                    label: l10n.staffName,
                    value: user?.name.isNotEmpty == true
                        ? user!.name
                        : l10n.notSet,
                    accentColor: AppColors.staffPrimary,
                  ),
                  _InfoRow(
                    icon: Icons.description_outlined,
                    label: l10n.shopDescription,
                    value: user?.shopDescription.isNotEmpty == true
                        ? user!.shopDescription
                        : l10n.notSet,
                    accentColor: AppColors.staffPrimary,
                  ),
                ]),
                const SizedBox(height: 24),
                _SectionLabel(l10n.actions),
                const SizedBox(height: 10),
                _ActionCard(tiles: [
                  _ActionTileData(
                    icon: Icons.settings_outlined,
                    label: l10n.settings,
                    subtitle: l10n.manageAppPreferences,
                    color: AppColors.staffPrimary,
                    onTap: () => context.push('/settings'),
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
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SignOutSheet(subtitle: l10n.staffSignOutSubtitle),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<AuthProvider>().logout();
    if (context.mounted) context.go('/login');
  }

  static String _initials(String? name) {
    if (name == null || name.isEmpty) return 'S';
    return name
        .split(' ')
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase())
        .take(2)
        .join();
  }
}

// ── Hero ──────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final User? user;
  final String initials;

  const _HeroSection({required this.user, required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A2E24), AppColors.staffPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
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
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user?.name ?? 'Staff',
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
                      _StaffBadge(),
                    ],
                  ),
                ),
              ],
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

class _StaffBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.badge_outlined, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            l10n.staffRole,
            style: AppTextStyles.labelL.copyWith(color: Colors.white),
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
    final l10n = AppLocalizations.of(context)!;
    final isActive = user?.isActive == true;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _StatCell(
              icon: Icons.circle,
              iconColor: isActive ? AppColors.success : AppColors.danger,
              label: l10n.statusLabel,
              value: isActive ? l10n.active : l10n.inactive,
              valueColor: isActive ? AppColors.success : AppColors.danger,
            ),
            const VerticalDivider(width: 1, thickness: 1),
            _StatCell(
              icon: Icons.work_outline_rounded,
              iconColor: AppColors.staffPrimary,
              label: l10n.roleLabel,
              value: l10n.staffRole,
              valueColor: AppColors.staffPrimary,
            ),
            const VerticalDivider(width: 1, thickness: 1),
            _StatCell(
              icon: Icons.store_outlined,
              iconColor: AppColors.accent,
              label: l10n.shopLabel,
              value: user?.shopId.isNotEmpty == true
                  ? l10n.assigned
                  : l10n.unassigned,
              valueColor: user?.shopId.isNotEmpty == true
                  ? AppColors.success
                  : AppColors.textSecondary,
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
  final Color accentColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
  });
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: row.accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(row.icon, size: 16, color: row.accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.label,
                  style: AppTextStyles.bodyS
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 3),
                Text(
                  row.value,
                  style: AppTextStyles.bodyM
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
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
                  Text(data.subtitle, style: AppTextStyles.bodyS),
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

// ── Sign-out bottom sheet ─────────────────────────────────────────────────────

class _SignOutSheet extends StatelessWidget {
  final String subtitle;
  const _SignOutSheet({required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 12, 24, 24 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.logout_rounded,
                color: AppColors.danger, size: 30),
          ),
          const SizedBox(height: 16),
          Text(l10n.signOutQuestion, style: AppTextStyles.headingL),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.bodyM
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(l10n.cancel,
                      style: AppTextStyles.headingS
                          .copyWith(color: AppColors.textPrimary)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: Text(l10n.signOut,
                      style: AppTextStyles.headingS
                          .copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
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
    final l10n = AppLocalizations.of(context)!;
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
                        l10n.signOut,
                        style: AppTextStyles.bodyM.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.danger,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.signOutDescription,
                        style: AppTextStyles.bodyS,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.danger.withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
