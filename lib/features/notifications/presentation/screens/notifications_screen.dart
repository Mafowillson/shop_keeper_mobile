import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/enums/notification_type.dart';
import 'package:shopkeeper/features/notifications/domain/entities/app_notification.dart';
import 'package:shopkeeper/features/notifications/presentation/providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  List<AppNotification> _filtered(List<AppNotification> all) {
    if (_selectedFilter == 'All') return all;
    if (_selectedFilter == 'Unread') return all.where((n) => !n.isRead).toList();
    final type = _filterToType(_selectedFilter);
    if (type == null) return all;
    return all.where((n) => n.type == type).toList();
  }

  NotificationType? _filterToType(String filter) {
    switch (filter) {
      case 'Stock':   return NotificationType.lowStock;
      case 'Sale':    return NotificationType.largeSale;
      case 'Payment': return NotificationType.debtPayment;
      case 'Staff':   return NotificationType.staffLogin;
      default:        return null;
    }
  }

  IconData _iconFor(NotificationType type) {
    switch (type) {
      case NotificationType.lowStock:      return Icons.warning_amber;
      case NotificationType.largeSale:     return Icons.trending_up;
      case NotificationType.debtPayment:   return Icons.check_circle;
      case NotificationType.staffLogin:    return Icons.person;
      case NotificationType.weeklyInsight: return Icons.insights;
      case NotificationType.anomaly:       return Icons.error;
      case NotificationType.productAdded:  return Icons.add_box;
      case NotificationType.productUpdated: return Icons.edit;
      case NotificationType.productDeleted: return Icons.delete;
    }
  }

  Color _colorFor(NotificationType type) {
    switch (type) {
      case NotificationType.lowStock:      return AppColors.warning;
      case NotificationType.largeSale:     return AppColors.success;
      case NotificationType.debtPayment:   return AppColors.success;
      case NotificationType.staffLogin:    return AppColors.accent;
      case NotificationType.weeklyInsight: return AppColors.accent;
      case NotificationType.anomaly:       return AppColors.danger;
      case NotificationType.productAdded:  return AppColors.accent;
      case NotificationType.productUpdated: return AppColors.warning;
      case NotificationType.productDeleted: return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        final items = _filtered(provider.notifications);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Notifications'),
            backgroundColor: AppColors.ownerPrimary,
            elevation: 0,
            actions: [
              if (provider.unreadCount > 0)
                TextButton(
                  onPressed: provider.markAllAsRead,
                  child: Text(
                    'Mark All Read',
                    style: AppTextStyles.bodyM.copyWith(color: Colors.white),
                  ),
                ),
            ],
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    if (provider.errorMessage != null)
                      _ErrorBanner(provider.errorMessage!),
                    if (provider.unreadCount > 0)
                      _UnreadBanner(provider.unreadCount),
                    _FilterRow(
                      selected: _selectedFilter,
                      onSelect: (f) => setState(() => _selectedFilter = f),
                    ),
                    Expanded(
                      child: items.isEmpty
                          ? _EmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: items.length,
                              itemBuilder: (context, index) => _NotificationCard(
                                notification: items[index],
                                icon: _iconFor(items[index].type),
                                color: _colorFor(items[index].type),
                                onTap: () => provider.markAsRead(items[index].id),
                              ),
                            ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _UnreadBanner extends StatelessWidget {
  final int count;
  const _UnreadBanner(this.count);

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: AppColors.warning.withValues(alpha:0.1),
        child: Text(
          'You have $count unread notification${count == 1 ? '' : 's'}',
          style: AppTextStyles.bodyM.copyWith(
            color: AppColors.warning,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner(this.message);

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: AppColors.danger.withValues(alpha:0.1),
        child: Text(
          message,
          style: AppTextStyles.bodyM.copyWith(color: AppColors.danger),
        ),
      );
}

class _FilterRow extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _FilterRow({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: ['All', 'Unread', 'Stock', 'Sale', 'Payment', 'Staff']
              .map((filter) {
            final isSelected = selected == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (_) => onSelect(filter),
                backgroundColor: Colors.grey[200],
                selectedColor: AppColors.ownerPrimary,
                labelStyle: AppTextStyles.bodyM.copyWith(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontSize: 12,
                ),
              ),
            );
          }).toList(),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No notifications',
              style: AppTextStyles.bodyM.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      );
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;
    return GestureDetector(
      onTap: isRead ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : color.withValues(alpha:0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isRead ? Colors.grey[200]! : color.withValues(alpha:0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTextStyles.bodyM.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isRead ? Colors.grey[700] : Colors.black,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: AppTextStyles.bodyM
                        .copyWith(color: Colors.grey[600], fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(notification.createdAt),
                    style: AppTextStyles.bodyM
                        .copyWith(color: Colors.grey[500], fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
