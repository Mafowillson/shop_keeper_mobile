import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/widgets/app_button.dart';
import 'package:shopkeeper/core/widgets/app_text_field.dart';
import 'package:shopkeeper/core/widgets/snack_bar_helper.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/staff/presentation/providers/staff_provider.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';

class CreateStaffScreen extends StatefulWidget {
  const CreateStaffScreen({super.key});

  @override
  State<CreateStaffScreen> createState() => _CreateStaffScreenState();
}

class _CreateStaffScreenState extends State<CreateStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();

    final shopId = context.read<AuthProvider>().currentUser?.shopId;
    final provider = context.read<StaffProvider>();
    final success = await provider.createStaff(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      shopId: shopId,
    );

    if (!mounted) return;

    if (success) {
      SnackBarHelper.showSuccess(context, l10n.staffCreatedSuccessfully);
      context.pop();
    } else {
      SnackBarHelper.showError(
          context, provider.errorMessage ?? l10n.failedCreateStaff);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.addStaffMember,
            style: AppTextStyles.headingL.copyWith(color: Colors.white)),
        backgroundColor: AppColors.ownerPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderCard(l10n: l10n),
              const SizedBox(height: 24),
              Text(l10n.accountDetails, style: AppTextStyles.headingM),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.fullName,
                hintText: l10n.hintExFullName,
                controller: _nameController,
                prefixIcon: const Icon(Icons.badge_outlined,
                    color: AppColors.textSecondary),
                validator: (v) {
                  if (v == null || v.trim().length < 2) {
                    return l10n.nameMinTwoChars;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.emailAddress,
                hintText: l10n.hintExEmail,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined,
                    color: AppColors.textSecondary),
                validator: (v) {
                  if (v == null || !v.contains('@') || !v.contains('.')) {
                    return l10n.enterValidEmailAddress;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.phoneNumber,
                hintText: l10n.hintExPhoneIntl,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined,
                    color: AppColors.textSecondary),
                validator: (v) {
                  if (v == null || v.trim().length < 9) {
                    return l10n.enterValidPhone;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _PhonePasswordNote(l10n: l10n),
              const SizedBox(height: 32),
              Consumer<StaffProvider>(
                builder: (context, provider, _) => AppButton.primary(
                  label: l10n.createStaffAccount,
                  isLoading: provider.isLoading,
                  onPressed: provider.isLoading ? null : _submit,
                ),
              ),
              const SizedBox(height: 16),
              AppButton.outlined(
                label: l10n.cancel,
                onPressed: () => context.pop(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final AppLocalizations l10n;
  const _HeaderCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.ownerPrimary,
            AppColors.ownerPrimary.withValues(alpha: 0.82)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.person_add_alt_1,
                color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.newStaffAccount,
                    style:
                        AppTextStyles.headingL.copyWith(color: Colors.white)),
                const SizedBox(height: 6),
                Text(
                  l10n.fillInStaffDetails,
                  style: AppTextStyles.bodyS.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhonePasswordNote extends StatelessWidget {
  final AppLocalizations l10n;
  const _PhonePasswordNote({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.phoneAsPassword,
              style: AppTextStyles.bodyS.copyWith(
                color: AppColors.accentDark,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
