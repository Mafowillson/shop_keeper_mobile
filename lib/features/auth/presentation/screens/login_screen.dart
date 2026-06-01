import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_strings.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/enums/user_role.dart';
import 'package:shopkeeper/core/widgets/app_button.dart';
import 'package:shopkeeper/core/widgets/app_text_field.dart';
import 'package:shopkeeper/core/widgets/snack_bar_helper.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _credentialController;
  UserRole _selectedRole = UserRole.owner;
  // Tracks which button triggered the current loading state.
  UserRole? _loadingRole;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _credentialController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _credentialController.dispose();
    super.dispose();
  }

  // Staff authenticate with their phone number; owners use a password.
  bool get _isStaff => _selectedRole == UserRole.staff;
  String get _credentialLabel => _isStaff ? 'Phone Number' : AppStrings.password;
  TextInputType get _credentialKeyboard =>
      _isStaff ? TextInputType.phone : TextInputType.visiblePassword;

  Future<void> _handleLogin(UserRole role) async {
    setState(() {
      _selectedRole = role;
      _loadingRole = role;
    });

    final authProvider = context.read<AuthProvider>();
    await authProvider.login(
      _emailController.text.trim(),
      _credentialController.text.trim(),
      role,
    );

    if (!mounted) return;
    setState(() => _loadingRole = null);

    if (authProvider.errorMessage != null) {
      SnackBarHelper.showError(context, authProvider.errorMessage!);
      return;
    }

    final user = authProvider.currentUser!;
    final isOwner = user.role == UserRole.owner;
    context.go(isOwner ? '/owner/dashboard' : '/staff/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            color: AppColors.ownerPrimary,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.storefront, size: 64, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.appName,
                    style: AppTextStyles.displayL.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.tagline,
                    style: AppTextStyles.bodyM.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.welcomeBack, style: AppTextStyles.headingL),
                      const SizedBox(height: 24),
                      AppTextField(
                        label: AppStrings.email,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      // Label and keyboard type adapt to the selected role.
                      AppTextField(
                        label: _credentialLabel,
                        controller: _credentialController,
                        obscureText: !_isStaff,
                        keyboardType: _credentialKeyboard,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.go('/forgot-password'),
                          child: Text(
                            AppStrings.forgotPassword,
                            style: AppTextStyles.bodyM.copyWith(
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      AppButton.primary(
                        label: AppStrings.continueAsOwner,
                        isLoading: _loadingRole == UserRole.owner,
                        onPressed: authProvider.isLoading
                            ? null
                            : () => _handleLogin(UserRole.owner),
                      ),
                      const SizedBox(height: 12),
                      AppButton.outlined(
                        label: AppStrings.continueAsStaff,
                        isLoading: _loadingRole == UserRole.staff,
                        onPressed: authProvider.isLoading
                            ? null
                            : () => _handleLogin(UserRole.staff),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'New here? ',
                            style: AppTextStyles.bodyM.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/register'),
                            child: Text(
                              'Create an account',
                              style: AppTextStyles.bodyM.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
