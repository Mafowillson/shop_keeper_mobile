import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';

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
  }

  @override
  void didUpdateWidget(covariant OwnerShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.location != oldWidget.location) {
      setState(() {
        _selectedIndex = _getSelectedIndex(widget.location);
      });
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
        break;
      case 1:
        context.go('/owner/notifications');
        break;
      case 2:
        context.go('/owner/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.ownerPrimary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

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
  }

  @override
  void didUpdateWidget(covariant StaffShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.location != oldWidget.location) {
      setState(() {
        _selectedIndex = _getSelectedIndex(widget.location);
      });
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
        break;
      case 1:
        context.go('/staff/notifications');
        break;
      case 2:
        context.go('/staff/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.staffPrimary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
