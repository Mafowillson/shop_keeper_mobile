import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/widgets/app_button.dart';
import 'package:shopkeeper/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';

class _Feature {
  final IconData icon;
  final String text;
  const _Feature(this.icon, this.text);
}

class _PageData {
  final IconData icon;
  final List<Color> gradient;
  final String title;
  final String description;
  final List<_Feature> features;
  const _PageData({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.description,
    this.features = const [],
  });
}

List<_PageData> _buildPages(AppLocalizations l10n) => [
      _PageData(
        icon: Icons.storefront_rounded,
        gradient: const [Color(0xFF145214), Color(0xFF1B5E20)],
        title: l10n.onboarding1Title,
        description: l10n.onboarding1Description,
      ),
      _PageData(
        icon: Icons.inventory_2_outlined,
        gradient: const [Color(0xFFE65100), Color(0xFFF57F17)],
        title: l10n.onboarding2Title,
        description: l10n.onboarding2Description,
        features: [
          _Feature(Icons.check_circle_outline, l10n.onboardingFeatureLiveStock),
          _Feature(Icons.notifications_outlined,
              l10n.onboardingFeatureLowStockAlerts),
          _Feature(Icons.warning_amber_outlined, l10n.onboardingFeatureRisk),
        ],
      ),
      _PageData(
        icon: Icons.receipt_long_outlined,
        gradient: const [Color(0xFF1B5E20), Color(0xFF388E3C)],
        title: l10n.onboarding3Title,
        description: l10n.onboarding3Description,
        features: [
          _Feature(Icons.add_shopping_cart_outlined,
              l10n.onboardingFeatureQuickSale),
          _Feature(Icons.history_outlined, l10n.onboardingFeatureHistory),
          _Feature(Icons.bar_chart_rounded, l10n.onboardingFeatureReports),
        ],
      ),
      _PageData(
        icon: Icons.account_balance_wallet_outlined,
        gradient: const [Color(0xFFBF360C), Color(0xFFE64A19)],
        title: l10n.onboarding4Title,
        description: l10n.onboarding4Description,
        features: [
          _Feature(Icons.people_outline, l10n.onboardingFeatureProfiles),
          _Feature(
              Icons.trending_down_rounded, l10n.onboardingFeatureRiskScoring),
          _Feature(
              Icons.payments_outlined, l10n.onboardingFeaturePaymentTracking),
        ],
      ),
      _PageData(
        icon: Icons.auto_awesome_outlined,
        gradient: const [Color(0xFF4A148C), Color(0xFF7B1FA2)],
        title: l10n.onboarding5Title,
        description: l10n.onboarding5Description,
        features: [
          _Feature(Icons.insights_outlined, l10n.onboardingFeatureWeekly),
          _Feature(Icons.search_outlined, l10n.onboardingFeatureAnomaly),
          _Feature(Icons.chat_outlined, l10n.onboardingFeatureChat),
        ],
      ),
    ];

class OnboardingPageView extends StatefulWidget {
  const OnboardingPageView({super.key});

  @override
  State<OnboardingPageView> createState() => _OnboardingPageViewState();
}

class _OnboardingPageViewState extends State<OnboardingPageView> {
  late final PageController _controller;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next(List<_PageData> pages) {
    if (_current == pages.length - 1) {
      _finish(skip: false);
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finish({required bool skip}) {
    final provider = context.read<OnboardingProvider>();
    if (skip) {
      provider.skipOnboarding();
    } else {
      provider.completeOnboarding();
    }
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = _buildPages(l10n);
    final isLast = _current == pages.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 16),
                  Text(
                    '${_current + 1} / ${pages.length}',
                    style: AppTextStyles.labelL
                        .copyWith(color: AppColors.textHint),
                  ),
                  TextButton(
                    onPressed: () => _finish(skip: true),
                    child: Text(
                      l10n.skip,
                      style: AppTextStyles.labelL
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (context, i) => _OnboardingSlide(data: pages[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DotIndicators(current: _current, total: pages.length),
                  const SizedBox(height: 20),
                  AppButton.primary(
                    label: isLast ? l10n.getStarted : l10n.next,
                    onPressed: () => _next(pages),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  final _PageData data;
  const _OnboardingSlide({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(flex: 52, child: _GraphicSection(data: data)),
        Expanded(flex: 48, child: _ContentSection(data: data)),
      ],
    );
  }
}

class _GraphicSection extends StatelessWidget {
  final _PageData data;
  const _GraphicSection({required this.data});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _BottomWaveClipper(),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: data.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(data.icon, size: 52, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 28)
      ..quadraticBezierTo(size.width * 0.25, size.height + 10, size.width * 0.5,
          size.height - 14)
      ..quadraticBezierTo(
          size.width * 0.75, size.height - 38, size.width, size.height - 14)
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(_BottomWaveClipper oldClipper) => false;
}

class _ContentSection extends StatelessWidget {
  final _PageData data;
  const _ContentSection({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.title,
            style: AppTextStyles.displayS
                .copyWith(color: AppColors.textPrimary, height: 1.2),
          ),
          const SizedBox(height: 10),
          Text(
            data.description,
            style: AppTextStyles.bodyM.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          if (data.features.isNotEmpty) ...[
            const SizedBox(height: 20),
            ...data.features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _FeatureRow(feature: f, accentColor: data.gradient.last),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final _Feature feature;
  final Color accentColor;
  const _FeatureRow({required this.feature, required this.accentColor});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(feature.icon, size: 16, color: accentColor),
          ),
          const SizedBox(width: 12),
          Text(feature.text,
              style:
                  AppTextStyles.labelL.copyWith(color: AppColors.textPrimary)),
        ],
      );
}

class _DotIndicators extends StatelessWidget {
  final int current;
  final int total;
  const _DotIndicators({required this.current, required this.total});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(total, (i) {
          final isActive = i == current;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: isActive ? 22 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: isActive ? AppColors.ownerPrimary : AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      );
}
