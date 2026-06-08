import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/widgets/app_button.dart';
import 'package:shopkeeper/core/widgets/app_text_field.dart';
import 'package:shopkeeper/core/widgets/snack_bar_helper.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';

class RegisterShopScreen extends StatefulWidget {
  const RegisterShopScreen({super.key});

  @override
  State<RegisterShopScreen> createState() => _RegisterShopScreenState();
}

class _RegisterShopScreenState extends State<RegisterShopScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _shopNameController;
  late final TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _shopNameController = TextEditingController();
    _locationController = TextEditingController();
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleRegisterShop() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;

    final authProvider = context.read<AuthProvider>();
    await authProvider.registerShop(_shopNameController.text.trim());

    if (mounted) {
      if (authProvider.errorMessage != null) {
        SnackBarHelper.showError(context, authProvider.errorMessage!);
      } else {
        SnackBarHelper.showSuccess(context, l10n.shopRegisteredSuccessfully);
        context.go('/owner/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: size.height * 0.35,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.ownerPrimary, AppColors.ownerPrimaryDark],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.business_outlined,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.welcomeToShopKeeper,
                      style:
                          AppTextStyles.displayL.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.setUpBusinessDetails,
                      style:
                          AppTextStyles.bodyM.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -24),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.05),
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, _) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.registerYourShop,
                          style: AppTextStyles.displayS.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.setUpBusinessDetails,
                          style: AppTextStyles.bodyS,
                        ),
                        const SizedBox(height: 28),
                        AppTextField(
                          label: l10n.shopName,
                          hintText: l10n.hintExShopName,
                          controller: _shopNameController,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return l10n.fieldRequired;
                            }
                            return null;
                          },
                          prefixIcon:
                              const Icon(Icons.storefront_outlined, size: 22),
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          label: l10n.shopLocation,
                          hintText: l10n.hintExShopLocation,
                          controller: _locationController,
                          prefixIcon:
                              const Icon(Icons.location_on_outlined, size: 22),
                        ),
                        const SizedBox(height: 36),
                        AppButton.primary(
                          label: l10n.completeOnboarding,
                          isLoading: authProvider.isLoading,
                          onPressed: _handleRegisterShop,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
