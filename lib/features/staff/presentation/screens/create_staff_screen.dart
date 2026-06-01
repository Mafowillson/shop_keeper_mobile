import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/widgets/app_button.dart';
import 'package:shopkeeper/core/widgets/app_text_field.dart';
import 'package:shopkeeper/core/widgets/snack_bar_helper.dart';
import 'package:shopkeeper/features/staff/presentation/providers/staff_provider.dart';

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
    FocusScope.of(context).unfocus();

    final provider = context.read<StaffProvider>();
    final success = await provider.createStaff(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      SnackBarHelper.showSuccess(context, 'Staff account created successfully');
      context.pop();
    } else {
      SnackBarHelper.showError(
          context, provider.errorMessage ?? 'Failed to create staff');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Add Staff Member', style: AppTextStyles.headingL.copyWith(color: Colors.white)),
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
              _HeaderCard(),
              const SizedBox(height: 24),
              Text('Account details', style: AppTextStyles.headingM),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Full Name',
                hintText: 'e.g. Jean-Paul Mbassi',
                controller: _nameController,
                prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.textSecondary),
                validator: (v) {
                  if (v == null || v.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Email Address',
                hintText: 'e.g. staff@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary),
                validator: (v) {
                  if (v == null || !v.contains('@') || !v.contains('.')) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Phone Number',
                hintText: 'e.g. 237612345678',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.textSecondary),
                validator: (v) {
                  if (v == null || v.trim().length < 9) {
                    return 'Enter a valid phone number (min 9 digits)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _PhonePasswordNote(),
              const SizedBox(height: 32),
              Consumer<StaffProvider>(
                builder: (context, provider, _) => AppButton.primary(
                  label: 'Create Staff Account',
                  isLoading: provider.isLoading,
                  onPressed: provider.isLoading ? null : _submit,
                ),
              ),
              const SizedBox(height: 16),
              AppButton.outlined(
                label: 'Cancel',
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
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.ownerPrimary, AppColors.ownerPrimary.withValues(alpha: 0.82)],
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
            child: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Staff Account',
                  style: AppTextStyles.headingL.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  'Fill in the details below to create login credentials for your staff member.',
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
          const Icon(Icons.info_outline_rounded, color: AppColors.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'The phone number serves as this staff member\'s password. '
              'Share their email and phone number so they can log in to ShopKeeper.',
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
