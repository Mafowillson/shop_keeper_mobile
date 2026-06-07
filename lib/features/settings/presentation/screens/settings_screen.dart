import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/enums/user_role.dart';
import 'package:shopkeeper/core/utils/currency_formatter.dart' show formatFCFA;
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/settings/presentation/providers/settings_provider.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool get _isOwner =>
      context.read<AuthProvider>().currentUser?.role == UserRole.owner;

  Color get _primary =>
      _isOwner ? AppColors.ownerPrimary : AppColors.staffPrimary;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<SettingsProvider>();
      await provider.init();
      if (_isOwner && mounted) {
        await provider.loadNotificationPrefs();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<SettingsProvider>(
        builder: (context, provider, _) => CustomScrollView(
          slivers: [
            _SettingsHeader(primary: _primary, l10n: l10n),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (provider.prefsError != null)
                    _ErrorBanner(
                      message: provider.prefsError!,
                      onDismiss: provider.clearError,
                    ),

                  // ── Owner: notification preferences ──────────────────
                  if (_isOwner) ...[
                    _SectionLabel(
                      icon: Icons.notifications_outlined,
                      title: l10n.alertPreferences,
                      subtitle: l10n.chooseAlerts,
                      trailing: provider.isSavingPrefs
                          ? const _SavingIndicator()
                          : null,
                    ),
                    const SizedBox(height: 10),
                    provider.isLoadingPrefs
                        ? const _LoadingCard()
                        : _NotificationPrefsCard(
                            provider: provider,
                            primary: _primary,
                            l10n: l10n,
                          ),
                    const SizedBox(height: 24),
                  ],

                  // ── Language (auto-detected) ──────────────────────────
                  _SectionLabel(
                    icon: Icons.language_outlined,
                    title: l10n.languageSetting,
                    subtitle: l10n.appDisplayLanguage,
                  ),
                  const SizedBox(height: 10),
                  _AutoLanguageCard(l10n: l10n),
                  const SizedBox(height: 24),

                  // ── Staff: push notification info ────────────────────
                  if (!_isOwner) ...[
                    _SectionLabel(
                      icon: Icons.notifications_active_outlined,
                      title: l10n.pushNotifications,
                      subtitle: l10n.pushNotifDescription,
                    ),
                    const SizedBox(height: 10),
                    _StaffNotifInfoCard(l10n: l10n),
                    const SizedBox(height: 24),
                  ],

                  // ── About ────────────────────────────────────────────
                  _SectionLabel(
                    icon: Icons.info_outline_rounded,
                    title: l10n.about,
                    subtitle: 'App information and support',
                  ),
                  const SizedBox(height: 10),
                  _AboutCard(primary: _primary, l10n: l10n),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _SettingsHeader extends StatelessWidget {
  final Color primary;
  final AppLocalizations l10n;
  const _SettingsHeader({required this.primary, required this.l10n});

  @override
  Widget build(BuildContext context) => SliverAppBar(
        pinned: true,
        expandedHeight: 110,
        elevation: 0,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        flexibleSpace: FlexibleSpaceBar(
          collapseMode: CollapseMode.pin,
          background: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary.withValues(alpha: 0.85), primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 48, 56, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            l10n.settings,
                            style: AppTextStyles.headingL
                                .copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.customizeExperience,
                            style: AppTextStyles.bodyS
                                .copyWith(color: Colors.white60),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

// ── Section label ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SectionLabel({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.ownerPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 17, color: AppColors.ownerPrimary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.headingS),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyS
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      );
}

// ── Error banner ───────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;
  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
            GestureDetector(
              onTap: onDismiss,
              child: const Icon(Icons.close, color: AppColors.danger, size: 16),
            ),
          ],
        ),
      );
}

// ── Loading / saving ───────────────────────────────────────────────────────────

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) => Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.ownerPrimary),
        ),
      );
}

class _SavingIndicator extends StatelessWidget {
  const _SavingIndicator();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: AppColors.ownerPrimary,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          l10n.savingEllipsis,
          style: AppTextStyles.labelS.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

// ── Notification preferences card (owner) ─────────────────────────────────────

class _NotificationPrefsCard extends StatelessWidget {
  final SettingsProvider provider;
  final Color primary;
  final AppLocalizations l10n;
  const _NotificationPrefsCard(
      {required this.provider, required this.primary, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final p = provider.notifPrefs;
    return _SettingsCard(
      children: [
        _ToggleTile(
          icon: Icons.inventory_2_outlined,
          iconColor: AppColors.warning,
          label: l10n.lowStockAlerts,
          subtitle: l10n.notifyWhenLowStock,
          value: p.lowStock,
          primary: primary,
          onChanged: (_) => provider.toggleLowStock(),
        ),
        const _Divider(),
        _ToggleTile(
          icon: Icons.trending_up_rounded,
          iconColor: AppColors.success,
          label: l10n.largeSaleAlerts,
          subtitle: l10n.notifyHighValue,
          value: p.largeSale,
          primary: primary,
          onChanged: (_) => provider.toggleLargeSale(),
        ),
        const _Divider(),
        _ToggleTile(
          icon: Icons.payments_outlined,
          iconColor: AppColors.accent,
          label: l10n.debtPaymentAlerts,
          subtitle: l10n.notifyCustomerPays,
          value: p.debtPayment,
          primary: primary,
          onChanged: (_) => provider.toggleDebtPayment(),
        ),
        const _Divider(),
        _ToggleTile(
          icon: Icons.badge_outlined,
          iconColor: AppColors.ownerPrimary,
          label: l10n.staffLoginAlerts,
          subtitle: l10n.notifyStaffSignIn,
          value: p.staffLogin,
          primary: primary,
          onChanged: (_) => provider.toggleStaffLogin(),
        ),
        if (p.largeSale) ...[
          const _Divider(),
          _NavTile(
            icon: Icons.bar_chart_rounded,
            iconColor: AppColors.success,
            label: l10n.largeSaleThresholdLabel,
            subtitle: l10n.salesAboveThisAmount,
            value: formatFCFA(p.largeSaleThreshold),
            onTap: () => _editThreshold(context, provider, l10n),
          ),
        ],
      ],
    );
  }

  Future<void> _editThreshold(BuildContext context, SettingsProvider provider,
      AppLocalizations l10n) async {
    final result = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ThresholdSheet(
        currentValue: provider.notifPrefs.largeSaleThreshold,
        l10n: l10n,
      ),
    );
    if (result != null) {
      await provider.setLargeSaleThreshold(result);
    }
  }
}

// ── Auto language card ─────────────────────────────────────────────────────────

class _AutoLanguageCard extends StatelessWidget {
  final AppLocalizations l10n;
  const _AutoLanguageCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final locale =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final langName = locale == 'fr' ? 'Français' : 'English';

    return _SettingsCard(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.ownerPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.translate_rounded,
                    size: 18, color: AppColors.ownerPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(langName,
                        style: AppTextStyles.labelL
                            .copyWith(color: AppColors.textPrimary)),
                    Text(
                      l10n.languageAutoDetected,
                      style: AppTextStyles.bodyS,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.phone_android_outlined,
                  size: 18, color: AppColors.textSecondary),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Staff notification info card ───────────────────────────────────────────────

class _StaffNotifInfoCard extends StatelessWidget {
  final AppLocalizations l10n;
  const _StaffNotifInfoCard({required this.l10n});

  @override
  Widget build(BuildContext context) => _SettingsCard(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.staffPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.notifications_active_outlined,
                      color: AppColors.staffPrimary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.pushNotifications,
                          style: AppTextStyles.labelL
                              .copyWith(color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(l10n.pushNotifDescription,
                          style: AppTextStyles.bodyS),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const _Divider(),
          _InfoRow(
              icon: Icons.add_box_outlined,
              color: AppColors.accent,
              label: l10n.newProductsAdded),
          const _Divider(),
          _InfoRow(
              icon: Icons.edit_outlined,
              color: AppColors.warning,
              label: l10n.priceStockUpdates),
          const _Divider(),
          _InfoRow(
              icon: Icons.delete_outline,
              color: AppColors.danger,
              label: l10n.productsRemoved),
        ],
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _InfoRow(
      {required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 15, color: color),
            ),
            const SizedBox(width: 12),
            Text(label,
                style: AppTextStyles.labelL
                    .copyWith(color: AppColors.textSecondary)),
            const Spacer(),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      );
}

// ── About card ─────────────────────────────────────────────────────────────────

class _AboutCard extends StatelessWidget {
  final Color primary;
  final AppLocalizations l10n;
  const _AboutCard({required this.primary, required this.l10n});

  @override
  Widget build(BuildContext context) => _SettingsCard(
        children: [
          _ValueTile(
            icon: Icons.tag_rounded,
            iconColor: primary,
            label: l10n.version,
            value: '1.0.0',
          ),
          const _Divider(),
          _NavTile(
            icon: Icons.headset_mic_outlined,
            iconColor: primary,
            label: l10n.contactSupport,
            subtitle: l10n.getHelpOrReport,
            onTap: () => context.push('/settings/support'),
          ),
          const _Divider(),
          _NavTile(
            icon: Icons.privacy_tip_outlined,
            iconColor: primary,
            label: l10n.privacyPolicy,
            subtitle: l10n.howWeHandleData,
            onTap: () => context.push('/settings/privacy'),
          ),
          const _Divider(),
          _NavTile(
            icon: Icons.gavel_outlined,
            iconColor: primary,
            label: l10n.termsOfService,
            subtitle: l10n.usageTerms,
            onTap: () => context.push('/settings/terms'),
          ),
        ],
      );
}

// ── Shared building-block widgets ──────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
      );
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, indent: 58, color: AppColors.border);
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final bool value;
  final Color primary;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.primary,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 17, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTextStyles.labelL
                          .copyWith(color: AppColors.textPrimary)),
                  Text(subtitle, style: AppTextStyles.bodyS),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: primary,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: AppColors.border,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      );
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final String? value;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.subtitle,
    this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 17, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: AppTextStyles.labelL
                            .copyWith(color: AppColors.textPrimary)),
                    if (subtitle != null)
                      Text(subtitle!, style: AppTextStyles.bodyS),
                  ],
                ),
              ),
              if (value != null) ...[
                Text(
                  value!,
                  style: AppTextStyles.labelL.copyWith(
                      color: AppColors.ownerPrimary,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 4),
              ],
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: Colors.grey[350]),
            ],
          ),
        ),
      );
}

class _ValueTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _ValueTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 17, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: AppTextStyles.labelL
                      .copyWith(color: AppColors.textPrimary)),
            ),
            Text(
              value,
              style:
                  AppTextStyles.labelL.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
}

// ── Large-sale threshold bottom sheet ─────────────────────────────────────────

class _ThresholdSheet extends StatefulWidget {
  final double currentValue;
  final AppLocalizations l10n;
  const _ThresholdSheet({required this.currentValue, required this.l10n});

  @override
  State<_ThresholdSheet> createState() => _ThresholdSheetState();
}

class _ThresholdSheetState extends State<_ThresholdSheet> {
  late final TextEditingController _controller;

  static const _presets = [25000.0, 50000.0, 100000.0, 200000.0, 500000.0];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentValue.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isValid {
    final v = double.tryParse(_controller.text.replaceAll(',', '').trim());
    return v != null && v > 0;
  }

  void _selectPreset(double value) {
    _controller.text = value.toStringAsFixed(0);
    setState(() {});
  }

  void _save() {
    final v = double.tryParse(_controller.text.replaceAll(',', '').trim());
    if (v != null && v > 0) Navigator.pop(context, v);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final kb = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + kb),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
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
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.trending_up_rounded,
                    color: AppColors.success, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.largeSaleThresholdTitle,
                        style: AppTextStyles.headingS),
                    Text(
                      l10n.youWillBeAlerted,
                      style: AppTextStyles.bodyS
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28, color: AppColors.border),
          Text(l10n.currentThreshold,
              style: AppTextStyles.labelL
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(
            formatFCFA(widget.currentValue),
            style:
                AppTextStyles.headingL.copyWith(color: AppColors.ownerPrimary),
          ),
          const SizedBox(height: 20),
          Text(l10n.quickSelect,
              style: AppTextStyles.labelL
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presets.map((p) {
              final selected = _controller.text.trim() == p.toStringAsFixed(0);
              return GestureDetector(
                onTap: () => _selectPreset(p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.ownerPrimary
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color:
                          selected ? AppColors.ownerPrimary : AppColors.border,
                    ),
                  ),
                  child: Text(
                    formatFCFA(p),
                    style: AppTextStyles.labelL.copyWith(
                      color: selected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text(l10n.customAmount,
              style: AppTextStyles.labelL
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            style: AppTextStyles.bodyM.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: '50000',
              suffixText: l10n.fcfa,
              suffixStyle:
                  AppTextStyles.labelL.copyWith(color: AppColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.ownerPrimary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Text(
                    l10n.cancel,
                    style: AppTextStyles.labelL
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _isValid ? _save : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.ownerPrimary,
                    disabledBackgroundColor:
                        AppColors.ownerPrimary.withValues(alpha: 0.35),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    l10n.save,
                    style: AppTextStyles.labelL.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
