import 'package:flutter/material.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final double? width;
  final double height;

  const AppButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.width,
    this.height = 50,
    super.key,
  });

  const AppButton.primary({
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false,
    double? width,
    Key? key,
  }) : this(
    label: label,
    onPressed: onPressed,
    isLoading: isLoading,
    variant: AppButtonVariant.primary,
    width: width,
    key: key,
  );

  const AppButton.outlined({
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false,
    double? width,
    Key? key,
  }) : this(
    label: label,
    onPressed: onPressed,
    isLoading: isLoading,
    variant: AppButtonVariant.outlined,
    width: width,
    key: key,
  );

  const AppButton.danger({
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false,
    double? width,
    Key? key,
  }) : this(
    label: label,
    onPressed: onPressed,
    isLoading: isLoading,
    variant: AppButtonVariant.danger,
    width: width,
    key: key,
  );

  const AppButton.accent({
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false,
    double? width,
    Key? key,
  }) : this(
    label: label,
    onPressed: onPressed,
    isLoading: isLoading,
    variant: AppButtonVariant.accent,
    width: width,
    key: key,
  );

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final textStyle = _getTextStyle();

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: isLoading
            ? const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(label, style: textStyle),
      ),
    );
  }

  ButtonStyle _getButtonStyle() {
    switch (variant) {
      case AppButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.ownerPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        );
      case AppButtonVariant.outlined:
        return OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.ownerPrimary, width: 1.5),
          foregroundColor: AppColors.ownerPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        );
      case AppButtonVariant.danger:
        return OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.danger, width: 1.5),
          foregroundColor: AppColors.danger,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        );
      case AppButtonVariant.accent:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        );
    }
  }

  TextStyle _getTextStyle() {
    return AppTextStyles.headingM.copyWith(
      color: variant == AppButtonVariant.outlined || variant == AppButtonVariant.danger
          ? null
          : Colors.white,
    );
  }
}

enum AppButtonVariant { primary, outlined, danger, accent }
