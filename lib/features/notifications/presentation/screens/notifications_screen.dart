import 'package:flutter/material.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> notifications = [
    {
      'id': '1',
      'type': 'Alert',
      'title': 'Low Stock Alert',
      'message': 'Coca Cola 500ml stock is below minimum threshold',
      'timestamp': '2 hours ago',
      'icon': Icons.warning_amber,
      'color': AppColors.warning,
      'isRead': false,
    },
    {
      'id': '2',
      'type': 'Sale',
      'title': 'Large Sale Completed',
      'message': 'Sale of FCFA 22,300 completed successfully',
      'timestamp': '4 hours ago',
      'icon': Icons.trending_up,
      'color': AppColors.success,
      'isRead': false,
    },
    {
      'id': '3',
      'type': 'Payment',
      'title': 'Payment Received',
      'message': 'John Doe paid FCFA 10,000 towards his debt',
      'timestamp': '1 day ago',
      'icon': Icons.check_circle,
      'color': AppColors.success,
      'isRead': true,
    },
    {
      'id': '4',
      'type': 'Alert',
      'title': 'High Risk Debt',
      'message': 'John Doe\'s debt has exceeded FCFA 40,000',
      'timestamp': '2 days ago',
      'icon': Icons.error,
      'color': AppColors.danger,
      'isRead': true,
    },
    {
      'id': '5',
      'type': 'Staff',
      'title': 'Staff Login',
      'message': 'Marie logged in to the system',
      'timestamp': '3 days ago',
      'icon': Icons.person_add,
      'color': AppColors.accent,
      'isRead': true,
    },
    {
      'id': '6',
      'type': 'Insight',
      'title': 'Weekly Insight',
      'message': 'Sales this week are 15% higher than last week',
      'timestamp': '4 days ago',
      'icon': Icons.insights,
      'color': AppColors.accent,
      'isRead': true,
    },
  ];

  List<Map<String, dynamic>> get filteredNotifications {
    if (_selectedFilter == 'All') return notifications;
    if (_selectedFilter == 'Unread') return notifications.where((n) => !n['isRead']).toList();
    return notifications.where((n) => n['type'] == _selectedFilter).toList();
  }

  int get unreadCount => notifications.where((n) => !n['isRead']).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.ownerPrimary,
        elevation: 0,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                setState(() {
                  for (var notification in notifications) {
                    notification['isRead'] = true;
                  }
                });
              },
              child: Text(
                'Mark All Read',
                style: AppTextStyles.bodyM.copyWith(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Unread Badge
          if (unreadCount > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: AppColors.warning.withOpacity(0.1),
              child: Text(
                'You have $unreadCount unread notifications',
                style: AppTextStyles.bodyM.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: ['All', 'Unread', 'Alert', 'Sale', 'Payment', 'Staff', 'Insight']
                  .map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedFilter = filter);
                    },
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
          ),

          // Notifications List
          Expanded(
            child: filteredNotifications.isEmpty
                ? Center(
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
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = filteredNotifications[index];
                      return _buildNotificationCard(notification);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    return GestureDetector(
      onTap: () {
        setState(() {
          notification['isRead'] = true;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: notification['isRead'] ? Colors.white : notification['color'].withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: notification['isRead'] ? Colors.grey[200]! : notification['color'].withOpacity(0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: notification['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  notification['icon'],
                  color: notification['color'],
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification['title'],
                          style: AppTextStyles.bodyM.copyWith(
                            fontWeight: FontWeight.w600,
                            color: notification['isRead'] ? Colors.grey[700] : Colors.black,
                          ),
                        ),
                      ),
                      if (!notification['isRead'])
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: notification['color'],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification['message'],
                    style: AppTextStyles.bodyM.copyWith(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification['timestamp'],
                    style: AppTextStyles.bodyM.copyWith(
                      color: Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Action Menu
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Text('Mark as read'),
                  onTap: () {
                    setState(() {
                      notification['isRead'] = true;
                    });
                  },
                ),
                PopupMenuItem(
                  child: const Text('Delete'),
                  onTap: () {
                    setState(() {
                      notifications.remove(notification);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
