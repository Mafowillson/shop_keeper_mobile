import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/features/ai/fraud_alerts/domain/entities/fraud_alert.dart';
import 'package:shopkeeper/features/ai/fraud_alerts/presentation/providers/fraud_alert_provider.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';

class FraudAlertsScreen extends StatefulWidget {
  const FraudAlertsScreen({super.key});

  @override
  State<FraudAlertsScreen> createState() => _FraudAlertsScreenState();
}

class _FraudAlertsScreenState extends State<FraudAlertsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showOpenOnly = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final openOnly = _tabController.index == 0;
        if (openOnly != _showOpenOnly) {
          setState(() => _showOpenOnly = openOnly);
          _load(openOnly: openOnly);
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load({bool openOnly = true}) {
    final shopId = context.read<AuthProvider>().currentUser?.shopId ?? '';
    return context.read<FraudAlertProvider>().load(shopId, openOnly: openOnly);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FraudAlertProvider>(
      builder: (context, provider, _) {
        final openCount = provider.openCount;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.ownerPrimary,
            foregroundColor: Colors.white,
            title: Row(
              children: [
                Text(
                  'Fraud Alerts',
                  style: AppTextStyles.headingM
                      .copyWith(color: Colors.white),
                ),
                if (openCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$openCount',
                      style: AppTextStyles.labelM
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ],
            ),
            elevation: 0,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: AppTextStyles.labelL,
              tabs: const [
                Tab(text: 'Open'),
                Tab(text: 'All'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _AlertList(
                provider: provider,
                onRefresh: () => _load(openOnly: true),
                onAcknowledge: (id) => _acknowledge(context, provider, id),
                showAcknowledged: false,
              ),
              _AlertList(
                provider: provider,
                onRefresh: () => _load(openOnly: false),
                onAcknowledge: (id) => _acknowledge(context, provider, id),
                showAcknowledged: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _acknowledge(
    BuildContext context,
    FraudAlertProvider provider,
    String id,
  ) async {
    try {
      await provider.acknowledge(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alert acknowledged'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to acknowledge alert'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }
}

class _AlertList extends StatelessWidget {
  final FraudAlertProvider provider;
  final Future<void> Function() onRefresh;
  final Future<void> Function(String id) onAcknowledge;
  final bool showAcknowledged;

  const _AlertList({
    required this.provider,
    required this.onRefresh,
    required this.onAcknowledge,
    required this.showAcknowledged,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.ownerPrimary),
      );
    }

    if (provider.error != null) {
      return _ErrorState(message: provider.error!, onRetry: onRefresh);
    }

    final alerts = showAcknowledged
        ? provider.alerts
        : provider.alerts.where((a) => a.isOpen).toList();

    if (alerts.isEmpty) {
      return RefreshIndicator(
        color: AppColors.ownerPrimary,
        onRefresh: onRefresh,
        child: ListView(
          children: [
            SizedBox(
              height: 400,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Icon(Icons.verified_user_rounded,
                              color: AppColors.success, size: 36),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('No Alerts', style: AppTextStyles.headingM),
                      const SizedBox(height: 8),
                      Text(
                        showAcknowledged
                            ? 'No fraud alerts have been recorded yet.'
                            : 'No open fraud alerts. Your shop looks clean!',
                        style: AppTextStyles.bodyM
                            .copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
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

    return RefreshIndicator(
      color: AppColors.ownerPrimary,
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return _AlertCard(
            alert: alert,
            onAcknowledge: () => onAcknowledge(alert.id),
          );
        },
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final FraudAlert alert;
  final VoidCallback onAcknowledge;

  const _AlertCard({required this.alert, required this.onAcknowledge});

  Color get _chipColor {
    switch (alert.triggerType) {
      case 'large_sale':
        return AppColors.danger;
      case 'off_hours':
        return AppColors.warning;
      case 'rapid_credit':
        return const Color(0xFF7B1FA2); // purple
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chipColor = _chipColor;
    final shortSaleId = alert.saleId.length > 8
        ? '${alert.saleId.substring(0, 8)}...'
        : alert.saleId;
    final timeAgo = _timeAgo(alert.createdAt);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: alert.isOpen
              ? chipColor.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trigger chip + status
            Row(
              children: [
                Icon(alert.triggerIcon, size: 18, color: chipColor),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: chipColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: chipColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    alert.triggerLabel,
                    style: AppTextStyles.labelL.copyWith(color: chipColor),
                  ),
                ),
                const Spacer(),
                if (!alert.isOpen)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Acknowledged',
                      style: AppTextStyles.labelM
                          .copyWith(color: AppColors.success),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            // Details
            Text(
              alert.details,
              style:
                  AppTextStyles.bodyM.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            // Sale ID + time
            Row(
              children: [
                Text(
                  'Sale: $shortSaleId',
                  style: AppTextStyles.bodyS
                      .copyWith(color: AppColors.textHint),
                ),
                const SizedBox(width: 12),
                Text(
                  timeAgo,
                  style: AppTextStyles.bodyS
                      .copyWith(color: AppColors.textHint),
                ),
              ],
            ),
            if (alert.isOpen) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: chipColor.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    foregroundColor: chipColor,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: onAcknowledge,
                  icon: const Icon(Icons.check_circle_outline_rounded,
                      size: 16),
                  label: Text('Acknowledge',
                      style: AppTextStyles.labelL.copyWith(color: chipColor)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.dangerLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.error_outline_rounded,
                    color: AppColors.danger, size: 28),
              ),
            ),
            const SizedBox(height: 16),
            Text('Something went wrong', style: AppTextStyles.headingM),
            const SizedBox(height: 6),
            Text(
              message,
              style:
                  AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.ownerPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text('Try Again', style: AppTextStyles.labelL),
            ),
          ],
        ),
      ),
    );
  }
}
