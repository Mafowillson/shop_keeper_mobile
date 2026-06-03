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
  late final TextEditingController _emailController;
  late final TextEditingController _credentialController;
  UserRole _role = UserRole.owner;
  bool _obscure = true;

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

  bool get _isStaff => _role == UserRole.staff;

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    await auth.login(
      _emailController.text.trim(),
      _credentialController.text.trim(),
      _role,
    );
    if (!mounted) return;
    if (auth.errorMessage != null) {
      SnackBarHelper.showError(context, auth.errorMessage!);
      return;
    }
    final user = auth.currentUser!;
    context
        .go(user.role == UserRole.owner ? '/owner/dashboard' : '/staff/home');
  }

  void _switchRole(UserRole role) {
    if (_role == role) return;
    setState(() {
      _role = role;
      _credentialController.clear();
      _obscure = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ownerPrimary,
      body: Column(
        children: [
          const Expanded(flex: 2, child: _HeroPanel()),
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                child: Consumer<AuthProvider>(
                  builder: (context, auth, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.welcomeBack,
                          style: AppTextStyles.headingL),
                      const SizedBox(height: 4),
                      Text(
                        'Sign in to continue',
                        style: AppTextStyles.bodyS,
                      ),
                      const SizedBox(height: 24),

                      // ── Role toggle ─────────────────────────────────
                      _RoleToggle(
                        selected: _role,
                        onSelect: _switchRole,
                      ),
                      const SizedBox(height: 20),

                      // ── Email ───────────────────────────────────────
                      AppTextField(
                        label: AppStrings.email,
                        hintText: 'your@email.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined,
                            color: AppColors.textHint, size: 20),
                      ),
                      const SizedBox(height: 16),

                      // ── Password / Phone ────────────────────────────
                      AppTextField(
                        label: _isStaff ? 'Phone Number' : AppStrings.password,
                        hintText: _isStaff ? 'e.g. 677 000 000' : '••••••••',
                        controller: _credentialController,
                        keyboardType: _isStaff
                            ? TextInputType.phone
                            : TextInputType.visiblePassword,
                        obscureText: !_isStaff && _obscure,
                        prefixIcon: Icon(
                          _isStaff ? Icons.phone_outlined : Icons.lock_outline,
                          color: AppColors.textHint,
                          size: 20,
                        ),
                        suffixIcon: _isStaff
                            ? null
                            : GestureDetector(
                                onTap: () =>
                                    setState(() => _obscure = !_obscure),
                                child: Icon(
                                  _obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.textHint,
                                  size: 20,
                                ),
                              ),
                      ),

                      // ── Forgot password (owner only) ────────────────
                      if (!_isStaff)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.go('/forgot-password'),
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 40)),
                            child: Text(
                              AppStrings.forgotPassword,
                              style: AppTextStyles.labelL
                                  .copyWith(color: AppColors.accent),
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 20),

                      const SizedBox(height: 8),

                      // ── Sign in button ──────────────────────────────
                      AppButton.primary(
                        label: 'Sign In',
                        isLoading: auth.isLoading,
                        onPressed: auth.isLoading ? null : _submit,
                      ),

                      const SizedBox(height: 20),

                      // ── Register link ───────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'New here?  ',
                            style: AppTextStyles.bodyM
                                .copyWith(color: AppColors.textSecondary),
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

// ── Hero panel ─────────────────────────────────────────────────────────────────

class _HeroPanel extends StatelessWidget {
  const _HeroPanel();

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.ownerPrimaryDark, AppColors.ownerPrimary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.storefront_rounded,
                  size: 38, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.appName,
              style: AppTextStyles.displayM.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.tagline,
              style: AppTextStyles.bodyS.copyWith(color: Colors.white60),
            ),
          ],
        ),
      );
}

// ── Role toggle ────────────────────────────────────────────────────────────────

class _RoleToggle extends StatelessWidget {
  final UserRole selected;
  final ValueChanged<UserRole> onSelect;
  const _RoleToggle({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) => Container(
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            _RoleTab(
              label: 'Owner',
              icon: Icons.storefront_outlined,
              isSelected: selected == UserRole.owner,
              onTap: () => onSelect(UserRole.owner),
            ),
            _RoleTab(
              label: 'Staff',
              icon: Icons.badge_outlined,
              isSelected: selected == UserRole.staff,
              onTap: () => onSelect(UserRole.staff),
            ),
          ],
        ),
      );
}

class _RoleTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  const _RoleTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            height: 25,
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected
                      ? AppColors.ownerPrimary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppTextStyles.labelL.copyWith(
                    color: isSelected
                        ? AppColors.ownerPrimary
                        : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
