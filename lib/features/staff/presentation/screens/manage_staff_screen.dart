import 'package:flutter/material.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/di/injection.dart';
import 'package:shopkeeper/features/staff/data/datasources/staff_remote_datasource.dart';
import 'package:shopkeeper/features/staff/data/models/staff_model.dart';
import 'package:shopkeeper/core/network/dio_client.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';

class ManageStaffScreen extends StatefulWidget {
  const ManageStaffScreen({super.key});

  @override
  State<ManageStaffScreen> createState() => _ManageStaffScreenState();
}

class _ManageStaffScreenState extends State<ManageStaffScreen> {
  late final StaffRemoteDataSource _ds;
  List<StaffModel> _staff = [];
  bool _loading = true;
  String? _error;
  final Set<String> _toggling = {};

  @override
  void initState() {
    super.initState();
    _ds = StaffRemoteDataSource(getIt<DioClient>());
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _ds.listStaff();
      if (mounted) {
        setState(() {
          _staff = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  Future<void> _toggle(StaffModel staff) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ToggleSheet(staff: staff),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _toggling.add(staff.id));
    try {
      final updated = await _ds.toggleActive(staff.id,
          isActive: !staff.isActive);
      if (mounted) {
        setState(() {
          final idx = _staff.indexWhere((s) => s.id == staff.id);
          if (idx != -1) _staff[idx] = updated;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(e.toString().replaceFirst('Exception: ', '')),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _toggling.remove(staff.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _Header(l10n: l10n),
          if (_loading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                    color: AppColors.ownerPrimary),
              ),
            )
          else if (_error != null)
            SliverFillRemaining(
                child: _ErrorView(
                    message: _error!, onRetry: _load, l10n: l10n))
          else if (_staff.isEmpty)
            SliverFillRemaining(child: _EmptyView(l10n: l10n))
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final s = _staff[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _StaffCard(
                        staff: s,
                        isToggling: _toggling.contains(s.id),
                        onToggle: () => _toggle(s),
                        l10n: l10n,
                      ),
                    );
                  },
                  childCount: _staff.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AppLocalizations l10n;
  const _Header({required this.l10n});

  @override
  Widget build(BuildContext context) => SliverAppBar(
        pinned: true,
        expandedHeight: 210,
        elevation: 0,
        backgroundColor: AppColors.ownerPrimary,
        foregroundColor: Colors.white,
        flexibleSpace: FlexibleSpaceBar(
          collapseMode: CollapseMode.pin,
          background: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.ownerPrimaryDark,
                  AppColors.ownerPrimary
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -30,
                  top: -30,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.group_outlined,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.manageStaff,
                        style: AppTextStyles.headingL
                            .copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        l10n.activateOrDeactivateTeam,
                        style: AppTextStyles.bodyS
                            .copyWith(color: Colors.white60),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _StaffCard extends StatelessWidget {
  final StaffModel staff;
  final bool isToggling;
  final VoidCallback onToggle;
  final AppLocalizations l10n;

  const _StaffCard({
    required this.staff,
    required this.isToggling,
    required this.onToggle,
    required this.l10n,
  });

  String get _initials {
    final parts =
        staff.name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final active = staff.isActive;
    final statusColor = active ? AppColors.success : AppColors.danger;

    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.ownerPrimary.withValues(alpha: 0.12)
                    : AppColors.danger.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _initials,
                  style: AppTextStyles.headingS.copyWith(
                    color: active
                        ? AppColors.ownerPrimary
                        : AppColors.danger,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          staff.name,
                          style: AppTextStyles.labelL
                              .copyWith(color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          active ? l10n.active : l10n.inactive,
                          style: AppTextStyles.labelS.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(staff.email,
                      style: AppTextStyles.bodyS
                          .copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(staff.phoneNumber,
                      style: AppTextStyles.bodyS
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            isToggling
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.ownerPrimary,
                    ),
                  )
                : GestureDetector(
                    onTap: onToggle,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.danger.withValues(alpha: 0.08)
                            : AppColors.success.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        active
                            ? Icons.person_off_outlined
                            : Icons.person_outlined,
                        size: 18,
                        color:
                            active ? AppColors.danger : AppColors.success,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _ToggleSheet extends StatelessWidget {
  final StaffModel staff;
  const _ToggleSheet({required this.staff});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final deactivating = staff.isActive;
    final actionColor = deactivating ? AppColors.danger : AppColors.success;
    final actionLabel = deactivating ? l10n.deactivate : l10n.activate;
    final actionIcon =
        deactivating ? Icons.person_off_outlined : Icons.person_outlined;

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
          const SizedBox(height: 24),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: actionColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(actionIcon, color: actionColor, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            '$actionLabel ${staff.name.split(' ').first}?',
            style: AppTextStyles.headingM,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            deactivating
                ? 'This staff member will no longer be able to log in or process sales.'
                : 'This staff member will regain access to the app and can process sales.',
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
                  onPressed: () => Navigator.pop(context, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: actionColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(actionLabel,
                      style:
                          AppTextStyles.labelL.copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final AppLocalizations l10n;
  const _EmptyView({required this.l10n});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.ownerPrimary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.group_outlined,
                  size: 34, color: AppColors.ownerPrimary),
            ),
            const SizedBox(height: 16),
            Text(l10n.noStaffYet,
                style: AppTextStyles.headingS
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Text(l10n.addStaffFromProfile,
                style: AppTextStyles.bodyM
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final AppLocalizations l10n;
  const _ErrorView(
      {required this.message,
      required this.onRetry,
      required this.l10n});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.danger),
              const SizedBox(height: 12),
              Text(l10n.couldNotLoadStaff,
                  style: AppTextStyles.headingS
                      .copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              Text(message,
                  style: AppTextStyles.bodyS
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(l10n.retry),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.ownerPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
}
