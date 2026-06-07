import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/widgets/app_button.dart';
import 'package:shopkeeper/core/widgets/snack_bar_helper.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  static const _codeLength = 6;

  final List<TextEditingController> _controllers =
      List.generate(_codeLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_codeLength, (_) => FocusNode());

  int _resendCountdown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startResendCountdown() {
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

  String get _enteredCode => _controllers.map((c) => c.text).join();
  bool get _isCodeComplete => _enteredCode.length == _codeLength;

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < _codeLength && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      final nextEmpty = _controllers.indexWhere((c) => c.text.isEmpty);
      final target = nextEmpty == -1 ? _codeLength - 1 : nextEmpty;
      _focusNodes[target].requestFocus();
      setState(() {});
      return;
    }
    if (value.isNotEmpty && index < _codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _clearCode() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
    setState(() {});
  }

  Future<void> _handleVerify() async {
    if (!_isCodeComplete) return;
    final l10n = AppLocalizations.of(context)!;

    final auth = context.read<AuthProvider>();
    final success = await auth.verifyEmail(_enteredCode);

    if (!mounted) return;

    if (!success) {
      SnackBarHelper.showError(
          context, auth.errorMessage ?? l10n.invalidCodeTryAgain);
      _clearCode();
      return;
    }

    final user = auth.currentUser!;
    final isOwner = user.role.name == 'owner';
    context.go(isOwner
        ? (user.shopId.isEmpty ? '/register-shop' : '/owner/dashboard')
        : '/staff/home');
  }

  Future<void> _handleResend() async {
    if (_resendCountdown > 0) return;
    final l10n = AppLocalizations.of(context)!;

    final auth = context.read<AuthProvider>();
    final success = await auth.resendVerificationCode();

    if (!mounted) return;

    if (success) {
      _startResendCountdown();
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
    final email = auth.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.ownerPrimary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_unread_outlined,
                    size: 56, color: AppColors.ownerPrimary),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.verifyYourEmail,
                style: AppTextStyles.displayS.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.enterCodeSentTo,
                style: AppTextStyles.bodyM
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: AppTextStyles.bodyM.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _OtpRow(
                controllers: _controllers,
                focusNodes: _focusNodes,
                onChanged: _onDigitChanged,
                onKeyEvent: _onKeyEvent,
              ),
              const SizedBox(height: 40),
              AppButton.primary(
                label: l10n.verifyEmailButton,
                isLoading: auth.isLoading,
                onPressed:
                    _isCodeComplete && !auth.isLoading ? _handleVerify : null,
              ),
              const SizedBox(height: 24),
              _ResendRow(
                countdown: _resendCountdown,
                isLoading: auth.isLoading,
                onResend: _handleResend,
                l10n: l10n,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  context.read<AuthProvider>().logout();
                  context.go('/login');
                },
                child: Text(
                  l10n.useDifferentAccount,
                  style: AppTextStyles.bodyM
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpRow extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function(int index, String value) onChanged;
  final void Function(int index, KeyEvent event) onKeyEvent;

  const _OtpRow({
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
    required this.onKeyEvent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        controllers.length,
        (i) => _OtpBox(
          controller: controllers[i],
          focusNode: focusNodes[i],
          onChanged: (v) => onChanged(i, v),
          onKeyEvent: (e) => onKeyEvent(i, e),
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
              borderSide:
                  const BorderSide(color: AppColors.ownerPrimary, width: 2),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ResendRow extends StatelessWidget {
  final int countdown;
  final bool isLoading;
  final VoidCallback onResend;
  final AppLocalizations l10n;

  const _ResendRow({
    required this.countdown,
    required this.isLoading,
    required this.onResend,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${l10n.didntReceiveCode} ',
          style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
        ),
        countdown > 0
            ? Text(
                l10n.resendInSeconds(countdown),
                style: AppTextStyles.bodyM
                    .copyWith(color: AppColors.textSecondary),
              )
            : GestureDetector(
                onTap: isLoading ? null : onResend,
                child: Text(
                  l10n.resend,
                  style: AppTextStyles.bodyM.copyWith(
                    color: AppColors.ownerPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
      ],
    );
  }
}
