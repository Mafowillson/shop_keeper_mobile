import 'package:flutter/material.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/enums/sync_state.dart';

class SyncStatusBadge extends StatelessWidget {
  final SyncState state;

  const SyncStatusBadge(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    switch (state) {
      case SyncState.synced:
        color = AppColors.success;
        icon = Icons.check_circle;
        label = 'Synced';
        break;
      case SyncState.pending:
        color = AppColors.warning;
        icon = Icons.sync;
        label = 'Syncing...';
        break;
      case SyncState.error:
        color = AppColors.danger;
        icon = Icons.error;
        label = 'Sync Error';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
