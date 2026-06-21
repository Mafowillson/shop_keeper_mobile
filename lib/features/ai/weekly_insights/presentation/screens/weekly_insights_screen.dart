import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/features/ai/weekly_insights/domain/entities/weekly_insight.dart';
import 'package:shopkeeper/features/ai/weekly_insights/presentation/providers/weekly_insight_provider.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';

class WeeklyInsightsScreen extends StatefulWidget {
  const WeeklyInsightsScreen({super.key});

  @override
  State<WeeklyInsightsScreen> createState() => _WeeklyInsightsScreenState();
}

class _WeeklyInsightsScreenState extends State<WeeklyInsightsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shopId = context.read<AuthProvider>().currentUser?.shopId ?? '';
      context.read<WeeklyInsightProvider>().load(shopId);
    });
  }

  Future<void> _refresh() {
    final shopId = context.read<AuthProvider>().currentUser?.shopId ?? '';
    return context.read<WeeklyInsightProvider>().load(shopId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.ownerPrimary,
        foregroundColor: Colors.white,
        title: Text(
          'Weekly Insights',
          style: AppTextStyles.headingM.copyWith(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: Consumer<WeeklyInsightProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.ownerPrimary),
            );
          }

          if (provider.error != null) {
            return _ErrorState(
              message: provider.error!,
              onRetry: _refresh,
            );
          }

          if (provider.insights.isEmpty) {
            return RefreshIndicator(
              color: AppColors.ownerPrimary,
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 200),
                  _EmptyState(),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.ownerPrimary,
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.insights.length,
              itemBuilder: (context, index) =>
                  _InsightCard(insight: provider.insights[index]),
            ),
          );
        },
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final WeeklyInsight insight;

  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accentLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.insights_rounded,
                        color: AppColors.accent, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight.weekLabel,
                        style: AppTextStyles.headingS,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(insight.weekStart),
                        style: AppTextStyles.labelM
                            .copyWith(color: AppColors.textHint),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 12),
            // Content — preserve whitespace for readable formatting
            Text(
              insight.content,
              style: AppTextStyles.bodyM.copyWith(
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 12),
            // Generated at
            Text(
              'Generated ${_timeAgo(insight.generatedAt)}',
              style: AppTextStyles.labelS.copyWith(color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'yesterday';
    return '${diff.inDays}d ago';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(Icons.insights_rounded,
                    color: AppColors.accent, size: 36),
              ),
            ),
            const SizedBox(height: 16),
            Text('No Insights Yet', style: AppTextStyles.headingM),
            const SizedBox(height: 8),
            Text(
              'No insights yet. Your first report will be generated next Monday.',
              style:
                  AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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
