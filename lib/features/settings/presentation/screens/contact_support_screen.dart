import 'package:flutter/material.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _SupportHeader(l10n: l10n),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SectionLabel(l10n.getInTouch),
                const SizedBox(height: 10),
                _ContactCard(l10n: l10n),
                const SizedBox(height: 24),
                _ResponseTimeCard(l10n: l10n),
                const SizedBox(height: 24),
                _SectionLabel(l10n.frequentlyAskedQuestions),
                const SizedBox(height: 10),
                _FaqCard(l10n: l10n),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── URL actions ────────────────────────────────────────────────────────────────

Future<void> _launchEmail(BuildContext context, AppLocalizations l10n) async {
  final subject = Uri.encodeComponent('ShopKeeper Support Request');
  final uri = Uri.parse('mailto:support@shopkeeper.cm?subject=$subject');
  if (!await launchUrl(uri)) {
    if (context.mounted) _showError(context, l10n.couldNotOpenEmail);
  }
}

Future<void> _openWhatsApp(BuildContext context, AppLocalizations l10n) async {
  final uri = Uri.parse('https://wa.me/237672635068');
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    if (context.mounted) _showError(context, l10n.couldNotOpenWhatsApp);
  }
}

void _openBugReport(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _BugReportSheet(),
  );
}

void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

// ── Bug report bottom sheet ────────────────────────────────────────────────────

class _BugReportSheet extends StatefulWidget {
  const _BugReportSheet();

  @override
  State<_BugReportSheet> createState() => _BugReportSheetState();
}

class _BugReportSheetState extends State<_BugReportSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _titleController.text.trim().isNotEmpty &&
      _descController.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _submitting = true);

    final subject =
        Uri.encodeComponent('Bug Report: ${_titleController.text.trim()}');
    final body = Uri.encodeComponent(
      'Description:\n${_descController.text.trim()}\n\n---\nSent from ShopKeeper app',
    );
    final uri =
        Uri.parse('mailto:support@shopkeeper.cm?subject=$subject&body=$body');

    final launched = await launchUrl(uri);
    if (mounted) {
      setState(() => _submitting = false);
      if (launched) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.couldNotOpenEmail),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + keyboardHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.bug_report_outlined,
                    color: AppColors.danger, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.reportABug, style: AppTextStyles.headingS),
                  Text(l10n.wellGetBackWithin24h,
                      style: AppTextStyles.bodyS),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(height: 28, color: AppColors.border),
          _SheetField(
            controller: _titleController,
            label: l10n.bugTitle,
            hint: l10n.bugTitleHint,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          _SheetField(
            controller: _descController,
            label: l10n.description,
            hint: l10n.bugDescriptionHint,
            maxLines: 4,
            alignLabelWithHint: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Text(
                    l10n.cancel,
                    style: AppTextStyles.labelL
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: (_canSubmit && !_submitting) ? _submit : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    disabledBackgroundColor:
                        AppColors.danger.withValues(alpha: 0.35),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          l10n.sendReport,
                          style:
                              AppTextStyles.labelL.copyWith(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final bool alignLabelWithHint;
  final ValueChanged<String>? onChanged;

  const _SheetField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.alignLabelWithHint = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        maxLines: maxLines,
        onChanged: onChanged,
        textCapitalization: TextCapitalization.sentences,
        style: AppTextStyles.bodyM.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle:
              AppTextStyles.bodyM.copyWith(color: AppColors.textHint),
          alignLabelWithHint: alignLabelWithHint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: AppColors.ownerPrimary, width: 2),
          ),
        ),
      );
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _SupportHeader extends StatelessWidget {
  final AppLocalizations l10n;
  const _SupportHeader({required this.l10n});

  @override
  Widget build(BuildContext context) => SliverAppBar(
        pinned: true,
        expandedHeight: 210,
        elevation: 0,
        backgroundColor: AppColors.ownerPrimary,
        foregroundColor: Colors.white,
        flexibleSpace: FlexibleSpaceBar(
          collapseMode: CollapseMode.pin,
          background: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.ownerPrimaryDark, AppColors.ownerPrimary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -30,
                  bottom: -30,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.headset_mic_outlined,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.contactSupport,
                        style: AppTextStyles.headingL
                            .copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        l10n.weAreHereToHelp,
                        style: AppTextStyles.bodyS
                            .copyWith(color: Colors.white60),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

// ── Section label ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTextStyles.headingS
            .copyWith(color: AppColors.textSecondary),
      );
}

// ── Contact card ───────────────────────────────────────────────────────────────

class _ContactCard extends StatelessWidget {
  final AppLocalizations l10n;
  const _ContactCard({required this.l10n});

  @override
  Widget build(BuildContext context) => _Card(
        children: [
          _ContactTile(
            icon: Icons.email_outlined,
            color: AppColors.ownerPrimary,
            label: l10n.emailSupport,
            subtitle: 'support@shopkeeper.cm',
            badge: null,
            onTap: () => _launchEmail(context, l10n),
          ),
          const _Divider(),
          _ContactTile(
            icon: Icons.chat_bubble_outline_rounded,
            color: const Color(0xFF25D366),
            label: l10n.whatsApp,
            subtitle: '+237 672 635 068',
            badge: l10n.fastestBadge,
            onTap: () => _openWhatsApp(context, l10n),
          ),
          const _Divider(),
          _ContactTile(
            icon: Icons.bug_report_outlined,
            color: AppColors.danger,
            label: l10n.reportABug,
            subtitle: l10n.helpUsImprove,
            badge: null,
            onTap: () => _openBugReport(context),
          ),
        ],
      );
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          label,
                          style: AppTextStyles.labelL
                              .copyWith(color: AppColors.textPrimary),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF25D366)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badge!,
                              style: AppTextStyles.labelS.copyWith(
                                color: const Color(0xFF25D366),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.bodyS),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: Colors.grey[350]),
            ],
          ),
        ),
      );
}

// ── Response time card ─────────────────────────────────────────────────────────

class _ResponseTimeCard extends StatelessWidget {
  final AppLocalizations l10n;
  const _ResponseTimeCard({required this.l10n});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.ownerPrimary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.ownerPrimary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.ownerPrimary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.access_time_rounded,
                  color: AppColors.ownerPrimary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.averageResponseTime,
                    style: AppTextStyles.labelL
                        .copyWith(color: AppColors.ownerPrimary),
                  ),
                  const SizedBox(height: 3),
                  Text(l10n.responseTimeDetails,
                      style: AppTextStyles.bodyS),
                ],
              ),
            ),
          ],
        ),
      );
}

// ── FAQ card ───────────────────────────────────────────────────────────────────

class _FaqCard extends StatefulWidget {
  final AppLocalizations l10n;
  const _FaqCard({required this.l10n});

  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard> {
  int? _expanded;

  List<({String q, String a})> get _faqs => [
        (q: widget.l10n.faq1Q, a: widget.l10n.faq1A),
        (q: widget.l10n.faq2Q, a: widget.l10n.faq2A),
        (q: widget.l10n.faq3Q, a: widget.l10n.faq3A),
        (q: widget.l10n.faq4Q, a: widget.l10n.faq4A),
        (q: widget.l10n.faq5Q, a: widget.l10n.faq5A),
      ];

  @override
  Widget build(BuildContext context) {
    final faqs = _faqs;
    return _Card(
      children: List.generate(faqs.length, (i) {
        final faq = faqs[i];
        final isOpen = _expanded == i;
        return Column(
          children: [
            InkWell(
              onTap: () =>
                  setState(() => _expanded = isOpen ? null : i),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.ownerPrimary
                            .withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: AppTextStyles.labelS.copyWith(
                            color: AppColors.ownerPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        faq.q,
                        style: AppTextStyles.labelL.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: isOpen
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: isOpen ? 0.25 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(Icons.arrow_forward_ios_rounded,
                          size: 13, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Container(
                width: double.infinity,
                color: AppColors.ownerPrimary.withValues(alpha: 0.03),
                padding: const EdgeInsets.fromLTRB(52, 0, 16, 16),
                child: Text(
                  faq.a,
                  style: AppTextStyles.bodyM.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.55,
                  ),
                ),
              ),
              crossFadeState: isOpen
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
            if (i < faqs.length - 1) const _Divider(),
          ],
        );
      }),
    );
  }
}

// ── Shared ─────────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(children: children),
        ),
      );
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => const Divider(
      height: 1, indent: 16, endIndent: 0, color: AppColors.border);
}
