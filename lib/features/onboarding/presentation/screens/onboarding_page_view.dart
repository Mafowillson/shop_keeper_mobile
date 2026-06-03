import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/widgets/app_button.dart';
import 'package:shopkeeper/features/onboarding/presentation/providers/onboarding_provider.dart';

// ── Page data ──────────────────────────────────────────────────────────────────

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

const _pages = <_PageData>[
  _PageData(
    icon: Icons.storefront_rounded,
    gradient: [Color(0xFF145214), Color(0xFF1B5E20)],
    title: 'Welcome to ShopKeeper',
    description:
        'Your complete shop management solution — built for businesses like yours.',
    features: [],
  ),
  _PageData(
    icon: Icons.inventory_2_outlined,
    gradient: [Color(0xFFE65100), Color(0xFFF57F17)],
    title: 'Smart Inventory',
    description: 'Always know what you have. Never run out of what matters.',
    features: [
      _Feature(Icons.check_circle_outline, 'Live stock levels'),
      _Feature(Icons.notifications_outlined, 'Low-stock alerts'),
      _Feature(Icons.warning_amber_outlined, 'Risk categorisation'),
    ],
  ),
  _PageData(
    icon: Icons.receipt_long_outlined,
    gradient: [Color(0xFF1B5E20), Color(0xFF388E3C)],
    title: 'Record Sales Fast',
    description:
        'Log cash and credit sales in seconds. Daily totals update automatically.',
    features: [
      _Feature(Icons.add_shopping_cart_outlined, 'Quick sale entry'),
      _Feature(Icons.history_outlined, 'Full transaction history'),
      _Feature(Icons.bar_chart_rounded, 'Daily & weekly reports'),
    ],
  ),
  _PageData(
    icon: Icons.account_balance_wallet_outlined,
    gradient: [Color(0xFFBF360C), Color(0xFFE64A19)],
    title: 'Manage Customer Debts',
    description:
        'Track who owes what, flag risky accounts, and record payments on the spot.',
    features: [
      _Feature(Icons.people_outline, 'Customer profiles'),
      _Feature(Icons.trending_down_rounded, 'Risk scoring'),
      _Feature(Icons.payments_outlined, 'Payment tracking'),
    ],
  ),
  _PageData(
    icon: Icons.auto_awesome_outlined,
    gradient: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
    title: 'AI-Powered Insights',
    description:
        'Ask your AI assistant anything. Get weekly reports and smart recommendations.',
    features: [
      _Feature(Icons.insights_outlined, 'Weekly summaries'),
      _Feature(Icons.search_outlined, 'Anomaly detection'),
      _Feature(Icons.chat_outlined, 'Natural language chat'),
    ],
  ),
];

// ── Page view ──────────────────────────────────────────────────────────────────

class OnboardingPageView extends StatefulWidget {
  const OnboardingPageView({super.key});

  @override
  State<OnboardingPageView> createState() => _OnboardingPageViewState();
}

class _OnboardingPageViewState extends State<OnboardingPageView> {
  late final PageController _controller;
  int _current = 0;

  bool get _isLast => _current == _pages.length - 1;

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

  void _next() {
    if (_isLast) {
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Skip row ───────────────────────────────────────────────
            SizedBox(
              height: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 16),
                  // Page counter
                  Text(
                    '${_current + 1} / ${_pages.length}',
                    style: AppTextStyles.labelL
                        .copyWith(color: AppColors.textHint),
                  ),
                  TextButton(
                    onPressed: () => _finish(skip: true),
                    child: Text(
                      'Skip',
                      style: AppTextStyles.labelL
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),

            // ── Pages ──────────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (context, i) =>
                    _OnboardingSlide(data: _pages[i]),
              ),
            ),

            // ── Bottom nav ─────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DotIndicators(
                      current: _current, total: _pages.length),
                  const SizedBox(height: 20),
                  AppButton.primary(
                    label: _isLast ? 'Get Started' : 'Next',
                    onPressed: _next,
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

// ── Slide ──────────────────────────────────────────────────────────────────────

class _OnboardingSlide extends StatelessWidget {
  final _PageData data;
  const _OnboardingSlide({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Graphic area
        Expanded(
          flex: 52,
          child: _GraphicSection(data: data),
        ),
        // Content area
        Expanded(
          flex: 48,
          child: _ContentSection(data: data),
        ),
      ],
    );
  }
}

// ── Graphic section ────────────────────────────────────────────────────────────

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
            // Decorative circles
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
            // Main icon
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
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height + 10,
        size.width * 0.5,
        size.height - 14,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height - 38,
        size.width,
        size.height - 14,
      )
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(_BottomWaveClipper oldClipper) => false;
}

// ── Content section ────────────────────────────────────────────────────────────

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

// ── Feature row ────────────────────────────────────────────────────────────────

class _FeatureRow extends StatelessWidget {
  final _Feature feature;
  final Color accentColor;
  const _FeatureRow(
      {required this.feature, required this.accentColor});

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
          Text(
            feature.text,
            style: AppTextStyles.labelL
                .copyWith(color: AppColors.textPrimary),
          ),
        ],
      );
}

// ── Dot indicators ─────────────────────────────────────────────────────────────

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
              color: isActive
                  ? AppColors.ownerPrimary
                  : AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      );
}
