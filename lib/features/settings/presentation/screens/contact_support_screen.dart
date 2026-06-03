import 'package:flutter/material.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const _SupportHeader(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const _SectionLabel('Get in touch'),
                const SizedBox(height: 10),
                const _ContactCard(),
                const SizedBox(height: 24),
                const _ResponseTimeCard(),
                const SizedBox(height: 24),
                const _SectionLabel('Frequently asked questions'),
                const SizedBox(height: 10),
                const _FaqCard(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── URL actions (file-level so all widgets can call them) ──────────────────────

Future<void> _launchEmail(BuildContext context) async {
  final subject = Uri.encodeComponent('ShopKeeper Support Request');
  final uri = Uri.parse('mailto:support@shopkeeper.cm?subject=$subject');
  if (!await launchUrl(uri)) {
    if (context.mounted) _showError(context, 'Could not open email app.');
  }
}

Future<void> _openWhatsApp(BuildContext context) async {
  final uri = Uri.parse('https://wa.me/237672635068');
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    if (context.mounted) _showError(context, 'Could not open WhatsApp.');
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
    setState(() => _submitting = true);

    final subject =
        Uri.encodeComponent('Bug Report: ${_titleController.text.trim()}');
    final body = Uri.encodeComponent(
      'Description:\n${_descController.text.trim()}\n\n---\nSent from ShopKeeper app',
    );
    final uri = Uri.parse(
        'mailto:support@shopkeeper.cm?subject=$subject&body=$body');

    final launched = await launchUrl(uri);
    if (mounted) {
      setState(() => _submitting = false);
      if (launched) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not open email app.'),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          // ── drag handle ──────────────────────────────────────
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

          // ── sheet header ─────────────────────────────────────
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
                  Text('Report a Bug', style: AppTextStyles.headingS),
                  Text("We'll get back to you within 24 hours",
                      style: AppTextStyles.bodyS),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(height: 28, color: AppColors.border),

          // ── title field ──────────────────────────────────────
          _SheetField(
            controller: _titleController,
            label: 'Bug title',
            hint: 'e.g. App crashes when adding a product',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),

          // ── description field ────────────────────────────────
          _SheetField(
            controller: _descController,
            label: 'Description',
            hint: 'Describe what happened and steps to reproduce it…',
            maxLines: 4,
            alignLabelWithHint: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),

          // ── action buttons ───────────────────────────────────
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
                    'Cancel',
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
                          'Send Report',
                          style: AppTextStyles.labelL
                              .copyWith(color: Colors.white),
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
          hintStyle: AppTextStyles.bodyM.copyWith(color: AppColors.textHint),
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
            borderSide:
                const BorderSide(color: AppColors.ownerPrimary, width: 2),
          ),
        ),
      );
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _SupportHeader extends StatelessWidget {
  const _SupportHeader();

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
                        child: const Icon(
                          Icons.headset_mic_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Contact Support',
                        style: AppTextStyles.headingL
                            .copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "We're here to help — reach out any time",
                        style:
                            AppTextStyles.bodyS.copyWith(color: Colors.white60),
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
        style: AppTextStyles.headingS.copyWith(color: AppColors.textSecondary),
      );
}

// ── Contact card ───────────────────────────────────────────────────────────────

class _ContactCard extends StatelessWidget {
  const _ContactCard();

  @override
  Widget build(BuildContext context) => _Card(
        children: [
          _ContactTile(
            icon: Icons.email_outlined,
            color: AppColors.ownerPrimary,
            label: 'Email Support',
            subtitle: 'support@shopkeeper.cm',
            badge: null,
            onTap: () => _launchEmail(context),
          ),
          const _Divider(),
          _ContactTile(
            icon: Icons.chat_bubble_outline_rounded,
            color: const Color(0xFF25D366),
            label: 'WhatsApp',
            subtitle: '+237 672 635 068',
            badge: 'Fastest',
            onTap: () => _openWhatsApp(context),
          ),
          const _Divider(),
          _ContactTile(
            icon: Icons.bug_report_outlined,
            color: AppColors.danger,
            label: 'Report a Bug',
            subtitle: 'Help us improve the app',
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
  const _ResponseTimeCard();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.ownerPrimary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: AppColors.ownerPrimary.withValues(alpha: 0.2)),
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
                    'Average response time',
                    style: AppTextStyles.labelL
                        .copyWith(color: AppColors.ownerPrimary),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Email: within 24 hours  ·  WhatsApp: within 2 hours',
                    style: AppTextStyles.bodyS,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

// ── FAQ card ───────────────────────────────────────────────────────────────────

class _FaqCard extends StatefulWidget {
  const _FaqCard();

  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard> {
  int? _expanded;

  static const _faqs = [
    (
      q: 'How do I add a product with multiple units?',
      a:
          'Go to Products → Add Product. In the Units section, add each unit (e.g. carton, pack) with its price and quantity relative to the base unit. The unit with "Qty in base = 1" is your base unit — all stock is tracked in this unit.',
    ),
    (
      q: 'Why is a staff login notification not showing?',
      a:
          'Make sure "Staff login alerts" is enabled in Settings → Alert Preferences. Also ensure the staff member is assigned a Shop ID and that your FCM device token is registered.',
    ),
    (
      q: 'How is my stock calculated?',
      a:
          'Stock is always stored in base units. When you record a sale, the sold quantity (in the chosen unit) is multiplied by that unit\'s "quantity in base" and subtracted from stock. The dashboard shows how much is available in each unit.',
    ),
    (
      q: 'Can I change the large sale threshold?',
      a:
          'Yes — go to Settings → Alert Preferences and tap the "Large sale threshold" row. Enter the FCFA amount above which a sale should trigger an alert.',
    ),
    (
      q: 'How do I create a staff account?',
      a:
          'From your profile screen, tap "Add Staff Member". Fill in their name, email, and phone number. Their phone number is their login password.',
    ),
  ];

  @override
  Widget build(BuildContext context) => _Card(
        children: List.generate(_faqs.length, (i) {
          final faq = _faqs[i];
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
                          color:
                              AppColors.ownerPrimary.withValues(alpha: 0.08),
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
              if (i < _faqs.length - 1) const _Divider(),
            ],
          );
        }),
      );
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
