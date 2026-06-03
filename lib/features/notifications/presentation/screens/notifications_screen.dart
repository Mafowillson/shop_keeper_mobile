import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/enums/notification_type.dart';
import 'package:shopkeeper/core/enums/user_role.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/notifications/domain/entities/app_notification.dart';
import 'package:shopkeeper/features/notifications/presentation/providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All';

  bool get _isOwner =>
      context.read<AuthProvider>().currentUser?.role == UserRole.owner;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isOwner) {
        context.read<NotificationProvider>().loadNotifications();
      }
    });
  }

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
    if (!_isOwner) return const _StaffNotificationsScreen();

    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        final items = _filtered(provider.notifications);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: RefreshIndicator(
            onRefresh: provider.loadNotifications,
            color: AppColors.ownerPrimary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _NotificationsHeader(
                  unreadCount: provider.unreadCount,
                  onMarkAllRead:
                      provider.unreadCount > 0 ? provider.markAllAsRead : null,
                ),
                if (provider.isLoading && provider.notifications.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.ownerPrimary),
                    ),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: _FilterBar(
                      selected: _selectedFilter,
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
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => _NotificationTile(
                            notification: items[i],
                            icon: _iconFor(items[i].type),
                            color: _colorFor(items[i].type),
                            onTap: items[i].isRead
                                ? null
                                : () => provider.markAsRead(items[i].id),
                          ),
                          childCount: items.length,
                        ),
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

// ── Header ─────────────────────────────────────────────────────────────────────

class _NotificationsHeader extends StatelessWidget {
  final int unreadCount;
  final VoidCallback? onMarkAllRead;
  const _NotificationsHeader(
      {required this.unreadCount, required this.onMarkAllRead});

  @override
  Widget build(BuildContext context) => SliverAppBar(
        pinned: true,
        expandedHeight: 110,
        elevation: 0,
        backgroundColor: AppColors.ownerPrimary,
        actions: [
          if (onMarkAllRead != null)
            TextButton(
              onPressed: onMarkAllRead,
              child: Text(
                'Mark all read',
                style: AppTextStyles.labelL.copyWith(color: Colors.white),
              ),
            ),
          const SizedBox(width: 8),
        ],
        flexibleSpace: FlexibleSpaceBar(
          collapseMode: CollapseMode.pin,
          background: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.ownerPrimaryDark, AppColors.ownerPrimary],
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
                      'Notifications',
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
                  unreadCount == 0 ? 'All caught up' : '$unreadCount unread',
                  style: AppTextStyles.bodyS.copyWith(color: Colors.white60),
                ),
              ],
            ),
          ),
        ),
      );
}

// ── Filter bar ─────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _FilterBar({required this.selected, required this.onSelect});

  static const _filters = [
    'All',
    'Unread',
    'Stock',
    'Sale',
    'Payment',
    'Staff'
  ];

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: _filters.map((f) {
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
                      color: isActive
                          ? AppColors.ownerPrimary
                          : AppColors.background,
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

// ── Notification tile ──────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _NotificationTile({
    required this.notification,
    required this.icon,
    required this.color,
    required this.onTap,
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
                        'Tap to dismiss',
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

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
                'No notifications',
                style: AppTextStyles.headingS
                    .copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                "You're all caught up.",
                style: AppTextStyles.bodyS,
              ),
            ],
          ),
        ),
      );
}

// ── Error banner ───────────────────────────────────────────────────────────────

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

// ── Staff notifications screen ─────────────────────────────────────────────────
// Staff receive push-only alerts (product added/updated/deleted). There is no
// server-side inbox for staff — notifications arrive via FCM and are handled
// by the OS notification tray.

class _StaffNotificationsScreen extends StatelessWidget {
  const _StaffNotificationsScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          backgroundColor: AppColors.staffPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.staffPrimary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_active_outlined,
                      color: AppColors.staffPrimary, size: 40),
                ),
                const SizedBox(height: 20),
                Text(
                  'Push notifications enabled',
                  style: AppTextStyles.headingM,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'You receive alerts directly on your device when the owner updates products — prices, new items, or removals.',
                  style: AppTextStyles.bodyM
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Column(
                    children: [
                      _AlertTypeRow(
                        icon: Icons.add_box_outlined,
                        color: AppColors.accent,
                        label: 'New product added',
                      ),
                      Divider(height: 20, color: AppColors.border),
                      _AlertTypeRow(
                        icon: Icons.edit_outlined,
                        color: AppColors.warning,
                        label: 'Product price updated',
                      ),
                      Divider(height: 20, color: AppColors.border),
                      _AlertTypeRow(
                        icon: Icons.delete_outline,
                        color: AppColors.danger,
                        label: 'Product removed',
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

class _AlertTypeRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _AlertTypeRow({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      );
}
