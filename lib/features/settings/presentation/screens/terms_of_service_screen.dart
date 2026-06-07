import 'package:flutter/material.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/features/settings/presentation/screens/policy_widgets.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          PolicyHeader(
            icon: Icons.gavel_outlined,
            title: l10n.termsOfService,
            subtitle: l10n.lastUpdatedJune2026,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                PolicyIntroCard(
                  icon: Icons.gavel_outlined,
                  text: l10n.termsOfServiceIntro,
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
          title: l10n.termsSec1Title,
          icon: Icons.handshake_outlined,
          color: AppColors.ownerPrimary,
          bullets: [l10n.termsSec1B1, l10n.termsSec1B2, l10n.termsSec1B3],
        ),
        PolicySection(
          number: '02',
          title: l10n.termsSec2Title,
          icon: Icons.manage_accounts_outlined,
          color: AppColors.accent,
          bullets: [
            l10n.termsSec2B1,
            l10n.termsSec2B2,
            l10n.termsSec2B3,
            l10n.termsSec2B4,
          ],
        ),
        PolicySection(
          number: '03',
          title: l10n.termsSec3Title,
          icon: Icons.check_circle_outline,
          color: AppColors.success,
          bullets: [
            l10n.termsSec3B1,
            l10n.termsSec3B2,
            l10n.termsSec3B3,
            l10n.termsSec3B4,
          ],
        ),
        PolicySection(
          number: '04',
          title: l10n.termsSec4Title,
          icon: Icons.storage_outlined,
          color: AppColors.warning,
          bullets: [l10n.termsSec4B1, l10n.termsSec4B2, l10n.termsSec4B3],
        ),
        PolicySection(
          number: '05',
          title: l10n.termsSec5Title,
          icon: Icons.wifi_outlined,
          color: const Color(0xFF7B1FA2),
          bullets: [l10n.termsSec5B1, l10n.termsSec5B2, l10n.termsSec5B3],
        ),
        PolicySection(
          number: '06',
          title: l10n.termsSec6Title,
          icon: Icons.shield_outlined,
          color: AppColors.danger,
          bullets: [l10n.termsSec6B1, l10n.termsSec6B2, l10n.termsSec6B3],
        ),
        PolicySection(
          number: '07',
          title: l10n.termsSec7Title,
          icon: Icons.cancel_outlined,
          color: AppColors.ownerPrimary,
          bullets: [l10n.termsSec7B1, l10n.termsSec7B2, l10n.termsSec7B3],
        ),
        PolicySection(
          number: '08',
          title: l10n.termsSec8Title,
          icon: Icons.gavel_outlined,
          color: AppColors.accent,
          bullets: [l10n.termsSec8B1, l10n.termsSec8B2, l10n.termsSec8B3],
        ),
      ];
}
