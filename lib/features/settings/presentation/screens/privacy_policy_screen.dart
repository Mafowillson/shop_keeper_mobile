import 'package:flutter/material.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/features/settings/presentation/screens/policy_widgets.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          PolicyHeader(
            icon: Icons.privacy_tip_outlined,
            title: l10n.privacyPolicy,
            subtitle: l10n.lastUpdatedJune2026,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                PolicyIntroCard(
                  icon: Icons.shield_outlined,
                  text: l10n.privacyPolicyIntro,
                ),
                const SizedBox(height: 16),
                ..._buildSections(l10n).map(
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

  static List<PolicySection> _buildSections(AppLocalizations l10n) => [
        PolicySection(
          number: '01',
          title: l10n.privacySec1Title,
          icon: Icons.folder_outlined,
          color: AppColors.ownerPrimary,
          bullets: [
            l10n.privacySec1B1,
            l10n.privacySec1B2,
            l10n.privacySec1B3,
            l10n.privacySec1B4,
          ],
        ),
        PolicySection(
          number: '02',
          title: l10n.privacySec2Title,
          icon: Icons.tune_outlined,
          color: AppColors.accent,
          bullets: [
            l10n.privacySec2B1,
            l10n.privacySec2B2,
            l10n.privacySec2B3,
            l10n.privacySec2B4,
            l10n.privacySec2B5,
          ],
        ),
        PolicySection(
          number: '03',
          title: l10n.privacySec3Title,
          icon: Icons.lock_outline_rounded,
          color: AppColors.success,
          bullets: [
            l10n.privacySec3B1,
            l10n.privacySec3B2,
            l10n.privacySec3B3,
            l10n.privacySec3B4,
          ],
        ),
        PolicySection(
          number: '04',
          title: l10n.privacySec4Title,
          icon: Icons.cloud_outlined,
          color: AppColors.warning,
          bullets: [
            l10n.privacySec4B1,
            l10n.privacySec4B2,
            l10n.privacySec4B3,
          ],
        ),
        PolicySection(
          number: '05',
          title: l10n.privacySec5Title,
          icon: Icons.verified_user_outlined,
          color: const Color(0xFF7B1FA2),
          bullets: [
            l10n.privacySec5B1,
            l10n.privacySec5B2,
            l10n.privacySec5B3,
            l10n.privacySec5B4,
          ],
        ),
        PolicySection(
          number: '06',
          title: l10n.privacySec6Title,
          icon: Icons.history_rounded,
          color: AppColors.ownerPrimary,
          bullets: [
            l10n.privacySec6B1,
            l10n.privacySec6B2,
            l10n.privacySec6B3,
          ],
        ),
        PolicySection(
          number: '07',
          title: l10n.privacySec7Title,
          icon: Icons.mail_outline_rounded,
          color: AppColors.accent,
          bullets: [
            l10n.privacySec7B1,
            l10n.privacySec7B2,
            l10n.privacySec7B3,
          ],
        ),
      ];
}
