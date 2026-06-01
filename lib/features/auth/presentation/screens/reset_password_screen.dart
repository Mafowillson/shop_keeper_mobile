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

class ResetPasswordScreen extends StatefulWidget {
  /// Email passed from the forgot-password screen.
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

  // ── Countdown ────────────────────────────────────────────────────────────

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

  // ── Code helpers ─────────────────────────────────────────────────────────

  String get _enteredCode =>
      _codeControllers.map((c) => c.text).join();

  bool get _codeComplete => _enteredCode.length == _codeLength;

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < _codeLength && i < digits.length; i++) {
        _codeControllers[i].text = digits[i];
      }
      final next =
          _codeControllers.indexWhere((c) => c.text.isEmpty);
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

  // ── Actions ──────────────────────────────────────────────────────────────

  Future<void> _handleReset() async {
    if (!_codeComplete) return;
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.resetPassword(
      email: widget.email,
      code: _enteredCode,
      newPassword: _newPasswordController.text.trim(),
    );

    if (!mounted) return;

    if (!success) {
      SnackBarHelper.showError(
          context, auth.errorMessage ?? 'Invalid code. Please try again.');
      _clearCode();
      return;
    }

    SnackBarHelper.showSuccess(
        context, 'Password reset! Please log in with your new password.');
    context.go('/login');
  }

  Future<void> _handleResend() async {
    if (_resendCountdown > 0) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.forgotPassword(widget.email);

    if (!mounted) return;

    if (success) {
      _startCountdown();
      SnackBarHelper.showSuccess(context, 'A new code has been sent.');
    } else {
      SnackBarHelper.showError(
          context, auth.errorMessage ?? 'Could not send code. Try again.');
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
        title: Text('Reset Password',
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
                // ── Header ──────────────────────────────────────────────────
                Text(
                  'Enter the 6-digit code sent to',
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

                // ── OTP row ──────────────────────────────────────────────────
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

                // ── Resend row ───────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive it? ",
                      style: AppTextStyles.bodyS
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    _resendCountdown > 0
                        ? Text(
                            'Resend in ${_resendCountdown}s',
                            style: AppTextStyles.bodyS
                                .copyWith(color: AppColors.textSecondary),
                          )
                        : GestureDetector(
                            onTap: auth.isLoading ? null : _handleResend,
                            child: Text(
                              'Resend',
                              style: AppTextStyles.bodyS.copyWith(
                                color: AppColors.ownerPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                  ],
                ),
                const SizedBox(height: 32),

                // ── New password ─────────────────────────────────────────────
                Text('New Password',
                    style: AppTextStyles.bodyS
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                AppTextField(
                  label: 'New Password',
                  hintText: 'Minimum 6 characters',
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
                      return 'Password is required';
                    }
                    if (v.trim().length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Confirm Password',
                  hintText: 'Re-enter your new password',
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
                      return 'Please confirm your password';
                    }
                    if (v.trim() != _newPasswordController.text.trim()) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // ── Submit ───────────────────────────────────────────────────
                AppButton.primary(
                  label: 'Reset Password',
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

// ── Reusable OTP box ─────────────────────────────────────────────────────────

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
