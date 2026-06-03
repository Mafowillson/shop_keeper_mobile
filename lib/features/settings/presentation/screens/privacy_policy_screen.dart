import 'package:flutter/material.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/features/settings/presentation/screens/policy_widgets.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const PolicyHeader(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Last updated: June 2026',
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const PolicyIntroCard(
                  icon: Icons.shield_outlined,
                  text:
                      'ShopKeeper is committed to protecting your privacy. This policy explains what data we collect, how we use it, and your rights as a user.',
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
      title: 'Information We Collect',
      icon: Icons.folder_outlined,
      color: AppColors.ownerPrimary,
      bullets: [
        'Account information: name, email address, and role (owner or staff).',
        'Shop data: product catalogue, sales records, customer debts, and stock levels.',
        'Device information: FCM token for push notifications.',
        'Usage data: app activity logs for debugging and service improvement.',
      ],
    ),
    PolicySection(
      number: '02',
      title: 'How We Use Your Data',
      icon: Icons.tune_outlined,
      color: AppColors.accent,
      bullets: [
        'To authenticate you and secure your account.',
        'To sync your shop data across sessions and devices.',
        'To send push notifications relevant to your business (stock alerts, sales, debts).',
        'To generate AI-powered business insights on request.',
        'To improve the app and fix issues.',
      ],
    ),
    PolicySection(
      number: '03',
      title: 'Data Storage & Security',
      icon: Icons.lock_outline_rounded,
      color: AppColors.success,
      bullets: [
        'Your data is stored on secured servers with encrypted connections (HTTPS).',
        'Passwords are hashed using bcrypt — we never store them in plain text.',
        'Auth tokens are stored in encrypted secure storage on your device.',
        'We do not sell your data to third parties.',
      ],
    ),
    PolicySection(
      number: '04',
      title: 'Third-Party Services',
      icon: Icons.cloud_outlined,
      color: AppColors.warning,
      bullets: [
        'Firebase Cloud Messaging (FCM) — for push notifications. Google Privacy Policy applies.',
        'MongoDB Atlas — for cloud data storage. MongoDB Privacy Policy applies.',
        'We do not use advertising networks or analytics platforms.',
      ],
    ),
    PolicySection(
      number: '05',
      title: 'Your Rights',
      icon: Icons.verified_user_outlined,
      color: Color(0xFF7B1FA2),
      bullets: [
        'Access: you may request a copy of your stored data at any time.',
        'Correction: you may update your account details in the app.',
        'Deletion: you may request account and data deletion by contacting support.',
        'Portability: your sales and inventory data can be exported on request.',
      ],
    ),
    PolicySection(
      number: '06',
      title: 'Data Retention',
      icon: Icons.history_rounded,
      color: AppColors.ownerPrimary,
      bullets: [
        'Active account data is retained for as long as your account exists.',
        'After account deletion, data is purged within 30 days.',
        'Anonymised aggregate data may be retained for service analytics.',
      ],
    ),
    PolicySection(
      number: '07',
      title: 'Contact',
      icon: Icons.mail_outline_rounded,
      color: AppColors.accent,
      bullets: [
        'For privacy-related questions or requests, contact us at:',
        'privacy@shopkeeper.cm',
        'We respond within 5 business days.',
      ],
    ),
  ];
}
