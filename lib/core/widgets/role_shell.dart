import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/notifications/presentation/providers/notification_provider.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';

// ── Owner shell ───────────────────────────────────────────────────────────────

class OwnerShell extends StatefulWidget {
  final Widget child;
  final String location;

  const OwnerShell({required this.child, required this.location, super.key});

  @override
  State<OwnerShell> createState() => _OwnerShellState();
}

class _OwnerShellState extends State<OwnerShell> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _getSelectedIndex(widget.location);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shopId = context.read<AuthProvider>().currentUser?.shopId;
      context
          .read<NotificationProvider>()
          .loadNotifications(isStaff: false, shopId: shopId);
    });
  }

  @override
  void didUpdateWidget(covariant OwnerShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.location != oldWidget.location) {
      setState(() => _selectedIndex = _getSelectedIndex(widget.location));
    }
  }

  int _getSelectedIndex(String location) {
    if (location.startsWith('/owner/notifications')) return 1;
    if (location.startsWith('/owner/profile')) return 2;
    return 0;
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        context.go('/owner/dashboard');
      case 1:
        context.go('/owner/notifications');
      case 2:
        context.go('/owner/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final unread = context.watch<NotificationProvider>().unreadCount;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.ownerPrimary,
        unselectedItemColor: AppColors.textSecondary,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: l10n.dashboard,
          ),
          BottomNavigationBarItem(
            icon: _BadgeIcon(
              icon: Icons.notifications_outlined,
              activeIcon: Icons.notifications,
              count: unread,
              isSelected: _selectedIndex == 1,
            ),
            label: l10n.notifications,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}

// ── Staff shell ───────────────────────────────────────────────────────────────

class StaffShell extends StatefulWidget {
  final Widget child;
  final String location;

  const StaffShell({required this.child, required this.location, super.key});

  @override
  State<StaffShell> createState() => _StaffShellState();
}

class _StaffShellState extends State<StaffShell> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _getSelectedIndex(widget.location);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications(isStaff: true);
    });
  }

  @override
  void didUpdateWidget(covariant StaffShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.location != oldWidget.location) {
      setState(() => _selectedIndex = _getSelectedIndex(widget.location));
    }
  }

  int _getSelectedIndex(String location) {
    if (location.startsWith('/staff/notifications')) return 1;
    if (location.startsWith('/staff/profile')) return 2;
    return 0;
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        context.go('/staff/home');
      case 1:
        context.go('/staff/notifications');
      case 2:
        context.go('/staff/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final unread = context.watch<NotificationProvider>().unreadCount;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.staffPrimary,
        unselectedItemColor: AppColors.textSecondary,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: _BadgeIcon(
              icon: Icons.notifications_outlined,
              activeIcon: Icons.notifications,
              count: unread,
              isSelected: _selectedIndex == 1,
            ),
            label: l10n.notifications,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}

// ── Badge icon widget ─────────────────────────────────────────────────────────

class _BadgeIcon extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final int count;
  final bool isSelected;

  const _BadgeIcon({
    required this.icon,
    required this.activeIcon,
    required this.count,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(isSelected ? activeIcon : icon),
        if (count > 0)
          Positioned(
            right: -8,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
