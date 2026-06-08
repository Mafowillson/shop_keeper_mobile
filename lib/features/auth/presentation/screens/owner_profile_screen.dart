import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/widgets/app_button.dart';
import 'package:shopkeeper/core/widgets/app_text_field.dart';
import 'package:shopkeeper/core/widgets/snack_bar_helper.dart';
import 'package:shopkeeper/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:shopkeeper/features/notifications/presentation/providers/notification_provider.dart';
import 'package:shopkeeper/features/products/presentation/providers/product_provider.dart';
import 'package:shopkeeper/features/auth/domain/entities/shop_summary.dart';
import 'package:shopkeeper/features/auth/domain/entities/user.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';

class OwnerProfileScreen extends StatefulWidget {
  const OwnerProfileScreen({super.key});

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      auth.refreshShopInfo();
      auth.fetchAllShops();
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
            backgroundColor: AppColors.ownerPrimary,
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
                _ShopsSection(
                  onSwitch: (shop) => _switchShop(context, shop),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(l10n.accountDetails,
                            style: AppTextStyles.headingM),
                      ),
                      GestureDetector(
                        onTap: () => _showEditShopSheet(context, user),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color:
                                AppColors.ownerPrimary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.edit_outlined,
                                  size: 13, color: AppColors.ownerPrimary),
                              const SizedBox(width: 4),
                              Text(l10n.edit,
                                  style: AppTextStyles.labelL
                                      .copyWith(color: AppColors.ownerPrimary)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _InfoCard(rows: [
                  _InfoRow(
                    icon: Icons.store_outlined,
                    label: l10n.shopNameLabel,
                    value: user?.shopName.isNotEmpty == true
                        ? user!.shopName
                        : l10n.notSet,
                  ),
                  _InfoRow(
                    icon: Icons.person_outline_rounded,
                    label: l10n.ownerName,
                    value: user?.name.isNotEmpty == true
                        ? user!.name
                        : l10n.notSet,
                  ),
                  _InfoRow(
                    icon: Icons.description_outlined,
                    label: l10n.shopDescription,
                    value: user?.shopDescription.isNotEmpty == true
                        ? user!.shopDescription
                        : l10n.notSet,
                  ),
                ]),
                const SizedBox(height: 24),
                _SectionLabel(l10n.quickActions),
                const SizedBox(height: 10),
                _ActionCard(tiles: [
                  _ActionTileData(
                    icon: Icons.add_business_outlined,
                    label: l10n.createNewShop,
                    subtitle: l10n.createNewShopSubtitle,
                    color: AppColors.ownerPrimary,
                    onTap: () => _showCreateShopSheet(context),
                  ),
                  _ActionTileData(
                    icon: Icons.person_add_alt_1_outlined,
                    label: l10n.addStaffMember,
                    subtitle: l10n.createLoginCredentialsForNewStaff,
                    color: AppColors.ownerPrimary,
                    onTap: () => context.push('/owner/staff/create'),
                  ),
                  _ActionTileData(
                    icon: Icons.group_outlined,
                    label: l10n.manageStaff,
                    subtitle: l10n.activateOrDeactivateTeam,
                    color: AppColors.accent,
                    onTap: () => context.push('/owner/staff/manage'),
                  ),
                  _ActionTileData(
                    icon: Icons.settings_outlined,
                    label: l10n.settings,
                    subtitle: l10n.managePreferencesAndSecurity,
                    color: AppColors.ownerPrimary,
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

  Future<void> _switchShop(BuildContext context, ShopSummary shop) async {
    // Capture providers + overlay before any async gap.
    final auth = context.read<AuthProvider>();
    final dashboard = context.read<DashboardProvider>();
    final products = context.read<ProductProvider>();
    final notifications = context.read<NotificationProvider>();
    final l10n = AppLocalizations.of(context)!;
    final overlayState = Overlay.of(context, rootOverlay: true);

    final entry = OverlayEntry(
      builder: (_) =>
          _ShopSwitchOverlay(label: l10n.switchingToShop(shop.name)),
    );
    overlayState.insert(entry);

    try {
      await auth.switchShop(shop);
      await Future.wait([
        dashboard.invalidateCache(shopId: shop.id),
        products.invalidateCache(),
        notifications.invalidateCache(),
      ]);
      // Reload notifications in the background for the new shop so the
      // badge count updates immediately without blocking the transition.
      unawaited(notifications.loadNotifications(shopId: shop.id));
      if (context.mounted) context.go('/owner/dashboard');
    } finally {
      entry.remove();
    }
  }

  Future<void> _showEditShopSheet(BuildContext context, User? user) async {
    final refreshed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditShopSheet(
        initialName: user?.shopName ?? '',
        initialDescription: user?.shopDescription ?? '',
      ),
    );
    if (refreshed == true && context.mounted) {
      final l10n = AppLocalizations.of(context)!;
      SnackBarHelper.showSuccess(context, l10n.shopUpdatedSuccessfully);
    }
  }

  Future<void> _showCreateShopSheet(BuildContext context) async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateShopSheet(),
    );
    if (created == true && context.mounted) {
      final l10n = AppLocalizations.of(context)!;
      SnackBarHelper.showSuccess(context, l10n.shopRegisteredSuccessfully);
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SignOutSheet(subtitle: l10n.ownerSignOutSubtitle),
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
    final l10n = AppLocalizations.of(context)!;
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
          const Icon(Icons.verified_outlined,
              size: 13, color: AppColors.accent),
          const SizedBox(width: 5),
          Text(
            l10n.ownerRole,
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
    final l10n = AppLocalizations.of(context)!;
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
              label: l10n.statusLabel,
              value: isActive ? l10n.active : l10n.inactive,
              valueColor: isActive ? AppColors.success : AppColors.danger,
            ),
            const VerticalDivider(width: 1, thickness: 1),
            _StatCell(
              icon: Icons.mark_email_read_outlined,
              iconColor: isVerified ? AppColors.success : AppColors.warning,
              label: l10n.email,
              value: isVerified ? l10n.verified : l10n.pending,
              valueColor: isVerified ? AppColors.success : AppColors.warning,
            ),
            const VerticalDivider(width: 1, thickness: 1),
            _StatCell(
              icon: Icons.admin_panel_settings_outlined,
              iconColor: AppColors.ownerPrimary,
              label: l10n.roleLabel,
              value: l10n.ownerRole,
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
            style:
                AppTextStyles.labelM.copyWith(color: AppColors.textSecondary),
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

  const _InfoRow(
      {required this.icon, required this.label, required this.value});
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
              color: AppColors.ownerPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(row.icon, size: 16, color: AppColors.ownerPrimary),
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
                  style:
                      AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
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
                    style: AppTextStyles.bodyM
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.subtitle,
                    style: AppTextStyles.bodyS,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey[350], size: 20),
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
            style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
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
                      style:
                          AppTextStyles.headingS.copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Shop-switch loading overlay ───────────────────────────────────────────────

class _ShopSwitchOverlay extends StatelessWidget {
  final String label;

  const _ShopSwitchOverlay({required this.label});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 48),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: AppColors.ownerPrimary,
                strokeWidth: 3,
              ),
              const SizedBox(height: 24),
              Text(
                label,
                style: AppTextStyles.headingS,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Your shops section ────────────────────────────────────────────────────────

class _ShopsSection extends StatelessWidget {
  final void Function(ShopSummary shop) onSwitch;

  const _ShopsSection({required this.onSwitch});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    final shops = auth.shops;
    final activeShopId = auth.currentUser?.shopId ?? '';

    if (shops.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(l10n.yourShops, style: AppTextStyles.headingM),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                for (int i = 0; i < shops.length; i++) ...[
                  _ShopRow(
                    shop: shops[i],
                    isActive: shops[i].id == activeShopId,
                    onSwitch: onSwitch,
                  ),
                  if (i < shops.length - 1)
                    const Divider(height: 1, indent: 56, endIndent: 0),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ShopRow extends StatelessWidget {
  final ShopSummary shop;
  final bool isActive;
  final void Function(ShopSummary) onSwitch;

  const _ShopRow({
    required this.shop,
    required this.isActive,
    required this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.ownerPrimary.withValues(alpha: 0.10)
                  : AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.storefront_outlined,
              size: 18,
              color:
                  isActive ? AppColors.ownerPrimary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shop.name,
                  style: AppTextStyles.bodyM.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? AppColors.ownerPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                if (shop.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    shop.description,
                    style: AppTextStyles.bodyS
                        .copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                l10n.active,
                style: AppTextStyles.labelL.copyWith(color: AppColors.success),
              ),
            )
          else
            GestureDetector(
              onTap: () => onSwitch(shop),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.ownerPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.switchShop,
                  style: AppTextStyles.labelL
                      .copyWith(color: AppColors.ownerPrimary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Edit shop bottom sheet ────────────────────────────────────────────────────

class _EditShopSheet extends StatefulWidget {
  final String initialName;
  final String initialDescription;

  const _EditShopSheet({
    required this.initialName,
    required this.initialDescription,
  });

  @override
  State<_EditShopSheet> createState() => _EditShopSheetState();
}

class _EditShopSheetState extends State<_EditShopSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descController = TextEditingController(text: widget.initialDescription);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.updateShop(
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      Navigator.pop(context, true);
    } else {
      final l10n = AppLocalizations.of(context)!;
      SnackBarHelper.showError(
          context, auth.errorMessage ?? l10n.somethingWentWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
            24, 12, 24, 24 + MediaQuery.of(context).padding.bottom),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(l10n.editShop, style: AppTextStyles.headingL),
              const SizedBox(height: 4),
              Text(
                l10n.editShopSubtitle,
                style: AppTextStyles.bodyS
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: l10n.shopName,
                hintText: l10n.hintExShopName,
                controller: _nameController,
                prefixIcon: const Icon(Icons.storefront_outlined, size: 20),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.shopDescription,
                hintText: l10n.hintExShopDescription,
                controller: _descController,
                prefixIcon: const Icon(Icons.description_outlined, size: 20),
                maxLines: 3,
              ),
              const SizedBox(height: 28),
              Consumer<AuthProvider>(
                builder: (_, auth, __) => AppButton.primary(
                  label: l10n.save,
                  isLoading: auth.isLoading,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Create shop bottom sheet ──────────────────────────────────────────────────

class _CreateShopSheet extends StatefulWidget {
  const _CreateShopSheet();

  @override
  State<_CreateShopSheet> createState() => _CreateShopSheetState();
}

class _CreateShopSheetState extends State<_CreateShopSheet> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    await auth.registerShop(_nameController.text.trim());
    if (!mounted) return;
    if (auth.errorMessage != null) {
      SnackBarHelper.showError(context, auth.errorMessage!);
    } else {
      // Set description after shop creation if provided
      if (_descController.text.trim().isNotEmpty) {
        await auth.updateShop(
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
        );
      }
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
            24, 12, 24, 24 + MediaQuery.of(context).padding.bottom),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.ownerPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add_business_outlined,
                        color: AppColors.ownerPrimary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.createNewShop, style: AppTextStyles.headingL),
                        Text(
                          l10n.createNewShopSubtitle,
                          style: AppTextStyles.bodyS
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: l10n.shopName,
                hintText: l10n.hintExShopName,
                controller: _nameController,
                prefixIcon: const Icon(Icons.storefront_outlined, size: 20),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.shopDescription,
                hintText: l10n.hintExShopDescription,
                controller: _descController,
                prefixIcon: const Icon(Icons.description_outlined, size: 20),
                maxLines: 3,
              ),
              const SizedBox(height: 28),
              Consumer<AuthProvider>(
                builder: (_, auth, __) => AppButton.primary(
                  label: l10n.createNewShop,
                  isLoading: auth.isLoading,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
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
                Icon(Icons.chevron_right_rounded,
                    color: AppColors.danger.withValues(alpha: 0.5), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
