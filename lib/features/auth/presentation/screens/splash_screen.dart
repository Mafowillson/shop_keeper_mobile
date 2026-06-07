import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _bootstrap();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final authProvider = context.read<AuthProvider>();
    final onboardingProvider = context.read<OnboardingProvider>();

    // Let animations play before doing any work.
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final restored = await authProvider.tryRestoreSession();
    if (!mounted) return;

    if (!restored) {
      if (!onboardingProvider.hasSeenOnboarding) {
        context.go('/onboarding');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A2E12),
              Color(0xFF1B5E20),
              Color(0xFF145214),
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // ── Background geometry ────────────────────────────────────
            _RotatingRing(size: size, controller: _pulseController),
            _BackgroundDots(),

            // ── Main content ───────────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // Icon ring stack
                  _LogoSection(controller: _pulseController),

                  const SizedBox(height: 36),

                  // App name
                  Text(
                    l10n.appName,
                    style: AppTextStyles.displayL.copyWith(
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ).animate(delay: 500.ms).fadeIn(duration: 600.ms).slideY(
                        begin: 0.4,
                        end: 0,
                        duration: 600.ms,
                        curve: Curves.easeOut,
                      ),

                  const SizedBox(height: 10),

                  // Accent divider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _AccentLine(alignRight: false),
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const _AccentLine(alignRight: true),
                    ],
                  )
                      .animate(delay: 700.ms)
                      .fadeIn(duration: 500.ms)
                      .scaleX(begin: 0, end: 1, duration: 500.ms),

                  const SizedBox(height: 14),

                  // Tagline
                  Text(
                    l10n.tagline,
                    style: AppTextStyles.bodyM.copyWith(
                      color: Colors.white.withValues(alpha: 0.65),
                      letterSpacing: 0.5,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate(delay: 800.ms)
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.3, end: 0, duration: 600.ms),

                  const Spacer(flex: 3),

                  // Loading dots
                  _PulseDots().animate(delay: 1200.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Rotating ring background ──────────────────────────────────────────────────

class _RotatingRing extends StatelessWidget {
  final Size size;
  final AnimationController controller;

  const _RotatingRing({required this.size, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Stack(
          children: [
            // Large top-right ring
            Positioned(
              top: -size.width * 0.35,
              right: -size.width * 0.25,
              child: Transform.rotate(
                angle: controller.value * 0.3,
                child: Container(
                  width: size.width * 0.9,
                  height: size.width * 0.9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white
                          .withValues(alpha: 0.04 + controller.value * 0.03),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            // Medium bottom-left ring
            Positioned(
              bottom: -size.width * 0.3,
              left: -size.width * 0.2,
              child: Transform.rotate(
                angle: -controller.value * 0.25,
                child: Container(
                  width: size.width * 0.75,
                  height: size.width * 0.75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.accent
                          .withValues(alpha: 0.06 + controller.value * 0.04),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            // Small accent ring (top-left)
            Positioned(
              top: size.height * 0.12,
              left: size.width * 0.06,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white
                        .withValues(alpha: 0.07 + controller.value * 0.05),
                    width: 1,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Floating background dots ──────────────────────────────────────────────────

class _BackgroundDots extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dots = [
      (0.08, 0.20, 4.0, 0.35),
      (0.88, 0.15, 5.0, 0.25),
      (0.15, 0.75, 3.5, 0.20),
      (0.82, 0.70, 6.0, 0.30),
      (0.50, 0.08, 4.0, 0.20),
      (0.70, 0.40, 3.0, 0.15),
      (0.25, 0.45, 5.0, 0.18),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          for (int i = 0; i < dots.length; i++)
            Positioned(
              left: dots[i].$1 * constraints.maxWidth,
              top: dots[i].$2 * constraints.maxHeight,
              child: Container(
                width: dots[i].$3,
                height: dots[i].$3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: dots[i].$4),
                ),
              )
                  .animate(
                    onPlay: (c) => c.repeat(reverse: true),
                    delay: Duration(milliseconds: i * 200),
                  )
                  .fadeIn(duration: 800.ms)
                  .then()
                  .fadeOut(duration: 800.ms),
            ),
        ],
      );
    });
  }
}

// ── Logo / icon section ───────────────────────────────────────────────────────

class _LogoSection extends StatelessWidget {
  final AnimationController controller;

  const _LogoSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final pulse = controller.value;
        return SizedBox(
          width: 180,
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outermost glow pulse
              Container(
                width: 150 + pulse * 18,
                height: 150 + pulse * 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.ownerPrimary
                      .withValues(alpha: 0.15 - pulse * 0.10),
                ),
              ),
              // Outer ring
              Container(
                width: 136,
                height: 136,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10 + pulse * 0.06),
                    width: 1,
                  ),
                  color: Colors.white.withValues(alpha: 0.03),
                ),
              ),
              // Accent ring
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        AppColors.accent.withValues(alpha: 0.30 + pulse * 0.20),
                    width: 1.5,
                  ),
                  color: Colors.transparent,
                ),
              ),
              // Inner filled circle
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.18),
                      Colors.white.withValues(alpha: 0.06),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
              ),
              // Icon
              const Icon(
                Icons.storefront_rounded,
                size: 46,
                color: Colors.white,
              )
                  .animate()
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 1000.ms,
                    delay: 150.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 300.ms, delay: 150.ms),

              // Accent sparkle top-right of icon
              Positioned(
                top: 28,
                right: 26,
                child: Transform.rotate(
                  angle: math.pi / 4,
                  child: Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: AppColors.accent.withValues(alpha: 0.85),
                  ),
                )
                    .animate(delay: 1000.ms)
                    .scale(
                      begin: const Offset(0, 0),
                      end: const Offset(1, 1),
                      duration: 400.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 200.ms),
              ),
            ],
          ),
        );
      },
    )
        .animate()
        .scale(
          begin: const Offset(0.6, 0.6),
          end: const Offset(1, 1),
          duration: 700.ms,
          curve: Curves.easeOut,
        )
        .fadeIn(duration: 500.ms);
  }
}

// ── Accent divider line ───────────────────────────────────────────────────────

class _AccentLine extends StatelessWidget {
  final bool alignRight;

  const _AccentLine({required this.alignRight});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: alignRight ? Alignment.centerLeft : Alignment.centerRight,
          end: alignRight ? Alignment.centerRight : Alignment.centerLeft,
          colors: [
            AppColors.accent,
            AppColors.accent.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

// ── Animated loading dots ─────────────────────────────────────────────────────

class _PulseDots extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        )
            .animate(
              onPlay: (c) => c.repeat(reverse: true),
              delay: Duration(milliseconds: i * 180),
            )
            .scaleXY(
              begin: 0.4,
              end: 1.0,
              duration: 500.ms,
              curve: Curves.easeInOut,
            )
            .fadeIn(
              begin: 0.3,
              duration: 500.ms,
            );
      }),
    );
  }
}
