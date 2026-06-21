import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/features/ai/price_recommendations/domain/entities/price_recommendation.dart';
import 'package:shopkeeper/features/ai/price_recommendations/presentation/providers/price_recommendation_provider.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';

class PriceRecommendationsScreen extends StatefulWidget {
  const PriceRecommendationsScreen({super.key});

  @override
  State<PriceRecommendationsScreen> createState() =>
      _PriceRecommendationsScreenState();
}

class _PriceRecommendationsScreenState
    extends State<PriceRecommendationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shopId = context.read<AuthProvider>().currentUser?.shopId ?? '';
      context.read<PriceRecommendationProvider>().load(shopId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.ownerPrimary,
        foregroundColor: Colors.white,
        title: Text('Price Recommendations', style: AppTextStyles.headingM.copyWith(color: Colors.white)),
        elevation: 0,
      ),
      body: Consumer<PriceRecommendationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.ownerPrimary),
            );
          }

          if (provider.error != null) {
            return _ErrorState(
              message: provider.error!,
              onRetry: () {
                final shopId =
                    context.read<AuthProvider>().currentUser?.shopId ?? '';
                provider.load(shopId);
              },
            );
          }

          if (provider.recommendations.isEmpty) {
            return const _EmptyState();
          }

          return RefreshIndicator(
            color: AppColors.ownerPrimary,
            onRefresh: () {
              final shopId =
                  context.read<AuthProvider>().currentUser?.shopId ?? '';
              return provider.load(shopId);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.recommendations.length,
              itemBuilder: (context, index) {
                final rec = provider.recommendations[index];
                return _RecommendationCard(
                  recommendation: rec,
                  onAccept: () => _confirmAccept(context, provider, rec),
                  onDismiss: () => _dismiss(context, provider, rec.id),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmAccept(
    BuildContext context,
    PriceRecommendationProvider provider,
    PriceRecommendation rec,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Apply Price Changes', style: AppTextStyles.headingM),
        content: Text(
          'Apply price changes to "${rec.productName}"?',
          style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: AppTextStyles.labelL
                    .copyWith(color: AppColors.textSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.success,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Apply', style: AppTextStyles.labelL),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await provider.accept(rec.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Price changes applied for "${rec.productName}"'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error ?? 'Failed to apply changes'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }

  Future<void> _dismiss(
    BuildContext context,
    PriceRecommendationProvider provider,
    String id,
  ) async {
    try {
      await provider.dismiss(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recommendation dismissed'),
            backgroundColor: AppColors.textSecondary,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to dismiss'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }
}

class _RecommendationCard extends StatelessWidget {
  final PriceRecommendation recommendation;
  final VoidCallback onAccept;
  final VoidCallback onDismiss;

  const _RecommendationCard({
    required this.recommendation,
    required this.onAccept,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final rec = recommendation;
    final pct = rec.changePercent;
    final isUp = rec.isIncrease;
    final badgeColor = isUp ? AppColors.success : AppColors.warning;
    final badgeLabel = isUp
        ? '+${pct.abs().toStringAsFixed(0)}%'
        : '-${pct.abs().toStringAsFixed(0)}%';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
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
            // Product name + badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    rec.productName,
                    style: AppTextStyles.headingM,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    badgeLabel,
                    style: AppTextStyles.labelL.copyWith(
                      color: badgeColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Sell-through rate
            Text(
              'Sell-through: ${(rec.sellThroughRate * 100).toStringAsFixed(1)}%  •  ${rec.unitsSold30d} units sold (30d)',
              style:
                  AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            // Reason
            Text(
              rec.reason,
              style: AppTextStyles.bodyS.copyWith(color: AppColors.textHint),
            ),
            const SizedBox(height: 12),
            // Price table
            if (rec.currentPrices.isNotEmpty) ...[
              _PriceTable(
                currentPrices: rec.currentPrices,
                suggestedPrices: rec.suggestedPrices,
              ),
              const SizedBox(height: 14),
            ],
            // Action buttons or status chip
            if (rec.isPending)
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.success,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: onAccept,
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: Text('Accept', style: AppTextStyles.labelL),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: onDismiss,
                      child: Text(
                        'Dismiss',
                        style: AppTextStyles.labelL
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              )
            else
              Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: Text(
                    rec.status == 'accepted' ? 'Accepted' : 'Dismissed',
                    style: AppTextStyles.labelM.copyWith(
                      color: rec.status == 'accepted'
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                  ),
                  backgroundColor: rec.status == 'accepted'
                      ? AppColors.successLight
                      : AppColors.background,
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PriceTable extends StatelessWidget {
  final Map<String, double> currentPrices;
  final Map<String, double> suggestedPrices;

  const _PriceTable({
    required this.currentPrices,
    required this.suggestedPrices,
  });

  @override
  Widget build(BuildContext context) {
    final units = currentPrices.keys.toList();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text('Unit',
                      style: AppTextStyles.labelM
                          .copyWith(color: AppColors.textHint)),
                ),
                Expanded(
                  child: Text('Current',
                      style: AppTextStyles.labelM
                          .copyWith(color: AppColors.textHint),
                      textAlign: TextAlign.right),
                ),
                Expanded(
                  child: Text('Suggested',
                      style: AppTextStyles.labelM
                          .copyWith(color: AppColors.textHint),
                      textAlign: TextAlign.right),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          ...units.map((unit) {
            final current = currentPrices[unit] ?? 0;
            final suggested = suggestedPrices[unit] ?? 0;
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(unit,
                        style: AppTextStyles.bodyS
                            .copyWith(color: AppColors.textPrimary)),
                  ),
                  Expanded(
                    child: Text(
                      current.toStringAsFixed(0),
                      style: AppTextStyles.bodyS
                          .copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      suggested.toStringAsFixed(0),
                      style: AppTextStyles.bodyS.copyWith(
                        color: suggested > current
                            ? AppColors.success
                            : AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
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
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(Icons.price_change_rounded,
                    color: AppColors.success, size: 36),
              ),
            ),
            const SizedBox(height: 16),
            Text('All Prices Optimal', style: AppTextStyles.headingM),
            const SizedBox(height: 8),
            Text(
              'No pending price recommendations at the moment. Check back after more sales data is collected.',
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
  final VoidCallback onRetry;

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
