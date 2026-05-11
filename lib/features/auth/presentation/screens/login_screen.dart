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
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: 'owner@shopkeeper.cm');
    _passwordController = TextEditingController(text: 'password');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin(UserRole role) async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.login(_emailController.text, _passwordController.text, role);

    if (mounted) {
      if (authProvider.errorMessage != null) {
        SnackBarHelper.showError(context, authProvider.errorMessage!);
      } else {
        final destination = role == UserRole.owner ? '/owner/dashboard' : '/staff/home';
        context.go(destination);
      }
    }
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
                      Text(
                        AppStrings.welcomeBack,
                        style: AppTextStyles.headingL,
                      ),
                      const SizedBox(height: 24),
                      AppTextField(
                        label: AppStrings.email,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: AppStrings.password,
                        controller: _passwordController,
                        obscureText: true,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
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
                        isLoading: authProvider.isLoading,
                        onPressed: () => _handleLogin(UserRole.owner),
                      ),
                      const SizedBox(height: 12),
                      AppButton.outlined(
                        label: AppStrings.continueAsStaff,
                        isLoading: authProvider.isLoading,
                        onPressed: () => _handleLogin(UserRole.staff),
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
