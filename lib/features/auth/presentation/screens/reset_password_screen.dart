import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/widgets/app_button.dart';
import 'package:shopkeeper/core/widgets/app_text_field.dart';
import 'package:shopkeeper/core/widgets/snack_bar_helper.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({required this.email, super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  static const _codeLength = 6;

  final List<TextEditingController> _codeControllers =
      List.generate(_codeLength, (_) => TextEditingController());
  final List<FocusNode> _codeFocusNodes =
      List.generate(_codeLength, (_) => FocusNode());

  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  int _resendCountdown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    for (final c in _codeControllers) { c.dispose(); }
    for (final f in _codeFocusNodes) { f.dispose(); }
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() => _resendCountdown = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown <= 1) {
        t.cancel();
        setState(() => _resendCountdown = 0);
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  String get _enteredCode => _codeControllers.map((c) => c.text).join();
  bool get _codeComplete => _enteredCode.length == _codeLength;

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < _codeLength && i < digits.length; i++) {
        _codeControllers[i].text = digits[i];
      }
      final next = _codeControllers.indexWhere((c) => c.text.isEmpty);
      _codeFocusNodes[next == -1 ? _codeLength - 1 : next].requestFocus();
      setState(() {});
      return;
    }
    if (value.isNotEmpty && index < _codeLength - 1) {
      _codeFocusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _codeControllers[index].text.isEmpty &&
        index > 0) {
      _codeFocusNodes[index - 1].requestFocus();
    }
  }

  void _clearCode() {
    for (final c in _codeControllers) { c.clear(); }
    _codeFocusNodes[0].requestFocus();
    setState(() {});
  }

  Future<void> _handleReset() async {
    if (!_codeComplete) return;
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;

    final auth = context.read<AuthProvider>();
    final success = await auth.resetPassword(
      email: widget.email,
      code: _enteredCode,
      newPassword: _newPasswordController.text.trim(),
    );

    if (!mounted) return;

    if (!success) {
      SnackBarHelper.showError(
          context, auth.errorMessage ?? l10n.invalidCodeTryAgain);
      _clearCode();
      return;
    }

    SnackBarHelper.showSuccess(context, l10n.passwordResetSuccess);
    context.go('/login');
  }

  Future<void> _handleResend() async {
    if (_resendCountdown > 0) return;
    final l10n = AppLocalizations.of(context)!;

    final auth = context.read<AuthProvider>();
    final success = await auth.forgotPassword(widget.email);

    if (!mounted) return;

    if (success) {
      _startCountdown();
      SnackBarHelper.showSuccess(context, l10n.newCodeSent);
    } else {
      SnackBarHelper.showError(
          context, auth.errorMessage ?? l10n.couldNotSendCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
        title: Text(l10n.resetPasswordTitle,
            style: AppTextStyles.headingM
                .copyWith(color: AppColors.textPrimary)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.enterCodeSentTo,
                  style: AppTextStyles.bodyM
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.email,
                  style: AppTextStyles.bodyM.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    _codeLength,
                    (i) => _OtpBox(
                      controller: _codeControllers[i],
                      focusNode: _codeFocusNodes[i],
                      onChanged: (v) => _onDigitChanged(i, v),
                      onKeyEvent: (e) => _onKeyEvent(i, e),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${l10n.didntReceiveIt} ',
                      style: AppTextStyles.bodyS
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    _resendCountdown > 0
                        ? Text(
                            l10n.resendInSeconds(_resendCountdown),
                            style: AppTextStyles.bodyS
                                .copyWith(color: AppColors.textSecondary),
                          )
                        : GestureDetector(
                            onTap: auth.isLoading ? null : _handleResend,
                            child: Text(
                              l10n.resend,
                              style: AppTextStyles.bodyS.copyWith(
                                color: AppColors.ownerPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(l10n.newPassword,
                    style: AppTextStyles.bodyS
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                AppTextField(
                  label: l10n.newPassword,
                  hintText: l10n.minimumSixChars,
                  controller: _newPasswordController,
                  obscureText: _obscureNew,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () =>
                        setState(() => _obscureNew = !_obscureNew),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return l10n.passwordRequired;
                    }
                    if (v.trim().length < 6) {
                      return l10n.passwordMinSixChars;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: l10n.confirmPassword,
                  hintText: l10n.minimumSixChars,
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return l10n.pleaseConfirmPassword;
                    }
                    if (v.trim() != _newPasswordController.text.trim()) {
                      return l10n.passwordsDoNotMatch;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                AppButton.primary(
                  label: l10n.resetPasswordTitle,
                  isLoading: auth.isLoading,
                  onPressed: (_codeComplete && !auth.isLoading)
                      ? _handleReset
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKeyEvent;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKeyEvent,
  });

  @override
  Widget build(BuildContext context) {
    final filled = controller.text.isNotEmpty;
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: onKeyEvent,
      child: SizedBox(
        width: 48,
        height: 56,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: AppTextStyles.displayS.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            filled: true,
            fillColor: filled
                ? AppColors.ownerPrimary.withValues(alpha: 0.08)
                : AppColors.surface,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: filled ? AppColors.ownerPrimary : AppColors.border,
                width: filled ? 2 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: AppColors.ownerPrimary, width: 2),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
