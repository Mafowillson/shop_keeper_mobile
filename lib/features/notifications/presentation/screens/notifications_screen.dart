import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/cache/cache_metadata_service.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/enums/notification_type.dart';
import 'package:shopkeeper/core/offline/hive_boxes.dart';
import 'package:shopkeeper/core/widgets/last_updated_indicator.dart';
import 'package:shopkeeper/core/widgets/offline_banner.dart';
import 'package:shopkeeper/di/injection.dart';
import 'package:shopkeeper/core/enums/user_role.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/notifications/domain/entities/app_notification.dart';
import 'package:shopkeeper/features/notifications/presentation/providers/notification_provider.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All';

  bool get _isOwner =>
      context.read<AuthProvider>().currentUser?.role == UserRole.owner;

  bool get _isStaff => !_isOwner;

  String? get _shopId =>
      _isOwner ? context.read<AuthProvider>().currentUser?.shopId : null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<NotificationProvider>()
          .loadNotifications(isStaff: _isStaff, shopId: _shopId);
    });
  }

  List<String> get _filters => _isOwner
      ? const ['All', 'Unread', 'Stock', 'Sale', 'Payment', 'Staff']
      : const ['All', 'Unread', 'Added', 'Updated', 'Deleted'];

  List<AppNotification> _filtered(List<AppNotification> all) {
    if (_selectedFilter == 'All') return all;
    if (_selectedFilter == 'Unread') {
      return all.where((n) => !n.isRead).toList();
    }
    final type = _filterToType(_selectedFilter);
    return type == null ? all : all.where((n) => n.type == type).toList();
  }

  NotificationType? _filterToType(String filter) {
    switch (filter) {
      case 'Stock':
        return NotificationType.lowStock;
      case 'Sale':
        return NotificationType.largeSale;
      case 'Payment':
        return NotificationType.debtPayment;
      case 'Staff':
        return NotificationType.staffLogin;
      case 'Added':
        return NotificationType.productAdded;
      case 'Updated':
        return NotificationType.productUpdated;
      case 'Deleted':
        return NotificationType.productDeleted;
      default:
        return null;
    }
  }

  static IconData _iconFor(NotificationType type) {
    switch (type) {
      case NotificationType.lowStock:
        return Icons.inventory_2_outlined;
      case NotificationType.largeSale:
        return Icons.trending_up_rounded;
      case NotificationType.debtPayment:
        return Icons.check_circle_outline;
      case NotificationType.staffLogin:
        return Icons.person_outline;
      case NotificationType.weeklyInsight:
        return Icons.insights_outlined;
      case NotificationType.anomaly:
        return Icons.warning_amber_outlined;
      case NotificationType.productAdded:
        return Icons.add_box_outlined;
      case NotificationType.productUpdated:
        return Icons.edit_outlined;
      case NotificationType.productDeleted:
        return Icons.delete_outline;
    }
  }

  static Color _colorFor(NotificationType type) {
    switch (type) {
      case NotificationType.lowStock:
        return AppColors.warning;
      case NotificationType.largeSale:
        return AppColors.success;
      case NotificationType.debtPayment:
        return AppColors.success;
      case NotificationType.staffLogin:
        return AppColors.accent;
      case NotificationType.weeklyInsight:
        return AppColors.accent;
      case NotificationType.anomaly:
        return AppColors.danger;
      case NotificationType.productAdded:
        return AppColors.accent;
      case NotificationType.productUpdated:
        return AppColors.warning;
      case NotificationType.productDeleted:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primaryColor =
        _isOwner ? AppColors.ownerPrimary : AppColors.staffPrimary;

    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        final items = _filtered(provider.notifications);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: RefreshIndicator(
            onRefresh: () =>
                provider.loadNotifications(isStaff: _isStaff, shopId: _shopId),
            color: primaryColor,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: OfflineBanner()),
                _NotificationsHeader(
                  unreadCount: provider.unreadCount,
                  primaryColor: primaryColor,
                  onMarkAllRead:
                      provider.unreadCount > 0 ? provider.markAllAsRead : null,
                  l10n: l10n,
                ),
                if (provider.isLoading && provider.notifications.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    ),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: _FilterBar(
                      selected: _selectedFilter,
                      filters: _filters,
                      primaryColor: primaryColor,
                      onSelect: (f) => setState(() => _selectedFilter = f),
                    ),
                  ),
                  if (provider.errorMessage != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: _ErrorBanner(provider.errorMessage!),
                      ),
                    ),
                  if (items.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(l10n: l10n),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => _NotificationTile(
                            notification: items[i],
                            icon: _iconFor(items[i].type),
                            color: _colorFor(items[i].type),
                            l10n: l10n,
                            onTap: items[i].isRead
                                ? null
                                : () => provider.markAsRead(items[i].id),
                          ),
                          childCount: items.length,
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: LastUpdatedIndicator(
                      boxName: HiveBoxes.notifications,
                      metadata: getIt<CacheMetadataService>(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NotificationsHeader extends StatelessWidget {
  final int unreadCount;
  final Color primaryColor;
  final VoidCallback? onMarkAllRead;
  final AppLocalizations l10n;
  const _NotificationsHeader(
      {required this.unreadCount,
      required this.primaryColor,
      required this.onMarkAllRead,
      required this.l10n});

  @override
  Widget build(BuildContext context) => SliverAppBar(
        pinned: true,
        expandedHeight: 110,
        elevation: 0,
        backgroundColor: primaryColor,
        actions: [
          if (onMarkAllRead != null)
            TextButton(
              onPressed: onMarkAllRead,
              child: Text(
                l10n.markAllRead,
                style: AppTextStyles.labelL.copyWith(color: Colors.white),
              ),
            ),
          const SizedBox(width: 8),
        ],
        flexibleSpace: FlexibleSpaceBar(
          collapseMode: CollapseMode.pin,
          background: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor.withValues(alpha: 0.85), primaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 72, 56, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text(
                      l10n.notifications,
                      style:
                          AppTextStyles.headingL.copyWith(color: Colors.white),
                    ),
                    if (unreadCount > 0) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$unreadCount',
                          style: AppTextStyles.labelM
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  unreadCount == 0
                      ? l10n.allCaughtUp
                      : l10n.unreadCount(unreadCount),
                  style: AppTextStyles.bodyS.copyWith(color: Colors.white60),
                ),
              ],
            ),
          ),
        ),
      );
}

class _FilterBar extends StatelessWidget {
  final String selected;
  final List<String> filters;
  final Color primaryColor;
  final ValueChanged<String> onSelect;
  const _FilterBar({
    required this.selected,
    required this.filters,
    required this.primaryColor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: filters.map((f) {
              final isActive = f == selected;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onSelect(f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isActive ? primaryColor : AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      f,
                      style: AppTextStyles.labelL.copyWith(
                        color:
                            isActive ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final AppLocalizations l10n;

  const _NotificationTile({
    required this.notification,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: isRead ? Colors.transparent : color,
              width: 3,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isRead ? 0.06 : 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color.withValues(alpha: isRead ? 0.45 : 1.0),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTextStyles.headingS.copyWith(
                              color: isRead
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                              fontWeight:
                                  isRead ? FontWeight.w500 : FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _timeAgo(notification.createdAt),
                          style: AppTextStyles.labelS
                              .copyWith(color: AppColors.textHint),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: AppTextStyles.bodyS.copyWith(
                        color: isRead
                            ? AppColors.textHint
                            : AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!isRead) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.tapToDismiss,
                        style: AppTextStyles.labelS.copyWith(color: color),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  const _EmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.ownerPrimary.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.ownerPrimary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noNotifications,
                style: AppTextStyles.headingS
                    .copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(l10n.allCaughtUpPeriod, style: AppTextStyles.bodyS),
            ],
          ),
        ),
      );
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner(this.message);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
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
              child: Text(
                message,
                style: AppTextStyles.bodyS.copyWith(color: AppColors.danger),
              ),
            ),
          ],
        ),
      );
}
