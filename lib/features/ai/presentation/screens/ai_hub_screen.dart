import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/features/ai/fraud_alerts/presentation/providers/fraud_alert_provider.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';

class AiHubScreen extends StatefulWidget {
  const AiHubScreen({super.key});

  @override
  State<AiHubScreen> createState() => _AiHubScreenState();
}

class _AiHubScreenState extends State<AiHubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Pre-load open fraud alert count for the badge.
      final shopId = context.read<AuthProvider>().currentUser?.shopId ?? '';
      if (shopId.isNotEmpty) {
        context.read<FraudAlertProvider>().load(shopId, openOnly: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final openCount =
        context.select<FraudAlertProvider, int>((p) => p.openCount);

    final features = <_AiFeature>[
      const _AiFeature(
        icon: Icons.chat_bubble_outline_rounded,
        color: AppColors.ownerPrimary,
        colorLight: AppColors.successLight,
        title: 'AI Chat',
        subtitle: 'Ask questions about your shop',
        route: '/owner/chat',
      ),
      const _AiFeature(
        icon: Icons.price_change_outlined,
        color: AppColors.accent,
        colorLight: AppColors.accentLight,
        title: 'Price Recommendations',
        subtitle: 'AI-suggested price adjustments',
        route: '/owner/ai/price-recommendations',
      ),
      _AiFeature(
        icon: Icons.security_outlined,
        color: AppColors.danger,
        colorLight: AppColors.dangerLight,
        title: 'Fraud Alerts',
        subtitle: 'Suspicious transaction monitoring',
        route: '/owner/ai/fraud-alerts',
        badge: openCount,
      ),
      const _AiFeature(
        icon: Icons.insights_outlined,
        color: Color(0xFF6A1B9A),
        colorLight: Color(0xFFF3E5F5),
        title: 'Weekly Insights',
        subtitle: 'AI-generated weekly summaries',
        route: '/owner/ai/weekly-insights',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.ownerPrimary,
        foregroundColor: Colors.white,
        title: Text(
          'AI Features',
          style: AppTextStyles.headingM.copyWith(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header banner
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.ownerPrimary, AppColors.ownerPrimaryDark],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Icon(Icons.auto_awesome_rounded,
                        color: AppColors.accent, size: 26),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ShopKeeper AI',
                        style: AppTextStyles.headingM
                            .copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Powered by AI to help you run your shop smarter',
                        style: AppTextStyles.bodyS.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Feature cards
          ...features.map((f) => _FeatureCard(feature: f)),
        ],
      ),
    );
  }
}

class _AiFeature {
  final IconData icon;
  final Color color;
  final Color colorLight;
  final String title;
  final String subtitle;
  final String route;
  final int badge;

  const _AiFeature({
    required this.icon,
    required this.color,
    required this.colorLight,
    required this.title,
    required this.subtitle,
    required this.route,
    this.badge = 0,
  });
}

class _FeatureCard extends StatelessWidget {
  final _AiFeature feature;

  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      color: AppColors.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.go(feature.route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: feature.colorLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Icon(feature.icon, color: feature.color, size: 24),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(feature.title, style: AppTextStyles.headingS),
                    const SizedBox(height: 3),
                    Text(
                      feature.subtitle,
                      style: AppTextStyles.bodyS
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (feature.badge > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${feature.badge}',
                    style: AppTextStyles.labelM.copyWith(color: Colors.white),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textHint, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
