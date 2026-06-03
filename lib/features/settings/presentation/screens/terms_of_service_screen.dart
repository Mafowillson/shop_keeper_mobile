import 'package:flutter/material.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/features/settings/presentation/screens/policy_widgets.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const PolicyHeader(
            icon: Icons.gavel_outlined,
            title: 'Terms of Service',
            subtitle: 'Last updated: June 2026',
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const PolicyIntroCard(
                  icon: Icons.gavel_outlined,
                  text:
                      'By using ShopKeeper, you agree to these terms. Please read them carefully. If you do not agree, please stop using the app.',
                ),
                const SizedBox(height: 16),
                ..._sections.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PolicySectionCard(section: s),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  static const _sections = [
    PolicySection(
      number: '01',
      title: 'Acceptance of Terms',
      icon: Icons.handshake_outlined,
      color: AppColors.ownerPrimary,
      bullets: [
        'By creating an account or using ShopKeeper, you confirm that you are at least 18 years old.',
        'You agree to use the app only for legitimate business management purposes.',
        'These terms may be updated periodically. Continued use constitutes acceptance.',
      ],
    ),
    PolicySection(
      number: '02',
      title: 'Account Responsibilities',
      icon: Icons.manage_accounts_outlined,
      color: AppColors.accent,
      bullets: [
        'You are responsible for maintaining the confidentiality of your login credentials.',
        'You must not share your owner account with unauthorised individuals.',
        'You are responsible for all activity that occurs under your account.',
        'Report any suspected unauthorised access to support immediately.',
      ],
    ),
    PolicySection(
      number: '03',
      title: 'Permitted Use',
      icon: Icons.check_circle_outline,
      color: AppColors.success,
      bullets: [
        'ShopKeeper may only be used for legitimate shop and inventory management.',
        'You must not use the app to record fraudulent transactions or falsify records.',
        'You must not attempt to reverse-engineer, hack, or abuse the service.',
        'Automated access (bots, scrapers) is strictly prohibited.',
      ],
    ),
    PolicySection(
      number: '04',
      title: 'Data & Content Ownership',
      icon: Icons.storage_outlined,
      color: AppColors.warning,
      bullets: [
        'You retain full ownership of all business data you enter into ShopKeeper.',
        'By using the service, you grant us a limited licence to store and process your data solely to provide the service.',
        'We do not claim ownership of your product catalogue, sales records, or customer data.',
      ],
    ),
    PolicySection(
      number: '05',
      title: 'Service Availability',
      icon: Icons.wifi_outlined,
      color: Color(0xFF7B1FA2),
      bullets: [
        'We aim for high availability but do not guarantee uninterrupted service.',
        'Scheduled maintenance will be communicated in advance where possible.',
        'We are not liable for losses caused by service interruptions beyond our control.',
      ],
    ),
    PolicySection(
      number: '06',
      title: 'Limitation of Liability',
      icon: Icons.shield_outlined,
      color: AppColors.danger,
      bullets: [
        'ShopKeeper is provided "as is" without warranties of any kind.',
        'We are not liable for business decisions made based on data in the app.',
        'Our total liability for any claim shall not exceed the amount you paid for the service in the preceding 3 months.',
      ],
    ),
    PolicySection(
      number: '07',
      title: 'Termination',
      icon: Icons.cancel_outlined,
      color: AppColors.ownerPrimary,
      bullets: [
        'You may stop using ShopKeeper and request account deletion at any time.',
        'We reserve the right to suspend or terminate accounts that violate these terms.',
        'Upon termination, your data will be deleted within 30 days per our Privacy Policy.',
      ],
    ),
    PolicySection(
      number: '08',
      title: 'Governing Law',
      icon: Icons.gavel_outlined,
      color: AppColors.accent,
      bullets: [
        'These terms are governed by the laws of the Republic of Cameroon.',
        'Any disputes shall be resolved through good-faith negotiation first.',
        'For questions, contact us at: legal@shopkeeper.cm',
      ],
    ),
  ];
}
