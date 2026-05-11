import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/widgets/app_button.dart';
import 'package:shopkeeper/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:shopkeeper/features/onboarding/presentation/screens/onboarding_screen_1.dart';
import 'package:shopkeeper/features/onboarding/presentation/screens/onboarding_screen_2.dart';
import 'package:shopkeeper/features/onboarding/presentation/screens/onboarding_screen_3.dart';
import 'package:shopkeeper/features/onboarding/presentation/screens/onboarding_screen_4.dart';
import 'package:shopkeeper/features/onboarding/presentation/screens/onboarding_screen_5.dart';

class OnboardingPageView extends StatefulWidget {
  const OnboardingPageView({super.key});

  @override
  State<OnboardingPageView> createState() => _OnboardingPageViewState();
}

class _OnboardingPageViewState extends State<OnboardingPageView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<OnboardingProvider>(
        builder: (context, provider, _) => Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                // Update provider when page changes
                while (provider.currentPage < index) {
                  provider.nextPage();
                }
                while (provider.currentPage > index) {
                  provider.previousPage();
                }
              },
              children: const [
                OnboardingScreen1(),
                OnboardingScreen2(),
                OnboardingScreen3(),
                OnboardingScreen4(),
                OnboardingScreen5(),
              ],
            ),
            Positioned(
              bottom: 32,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          provider.skipOnboarding();
                          context.go('/login');
                        },
                        child: Text(
                          'Skip',
                          style: AppTextStyles.bodyM.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      Text(
                        '${provider.currentPage + 1}/5',
                        style: AppTextStyles.bodyM.copyWith(
                          color: AppColors.ownerPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: provider.currentPage < 4
                            ? () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            : null,
                        child: Text(
                          'Next',
                          style: AppTextStyles.bodyM.copyWith(
                            color: provider.currentPage < 4
                                ? AppColors.ownerPrimary
                                : Colors.grey[400],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (provider.currentPage == 4)
                    AppButton.primary(
                      label: 'Get Started',
                      onPressed: () {
                        provider.completeOnboarding();
                        context.go('/login');
                      },
                    )
                  else
                    AppButton.outlined(
                      label: 'Skip to Login',
                      onPressed: () {
                        provider.skipOnboarding();
                        context.go('/login');
                      },
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
