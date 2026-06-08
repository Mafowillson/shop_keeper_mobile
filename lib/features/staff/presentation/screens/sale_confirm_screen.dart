import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/widgets/app_button.dart';
import 'package:shopkeeper/core/widgets/snack_bar_helper.dart';
import 'package:shopkeeper/core/enums/user_role.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:shopkeeper/features/sales/domain/entities/sale.dart';
import 'package:shopkeeper/features/sales/presentation/providers/cart_provider.dart';
import 'package:shopkeeper/features/sales/presentation/providers/sales_provider.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';

class SaleConfirmScreen extends StatefulWidget {
  const SaleConfirmScreen({super.key});

  @override
  State<SaleConfirmScreen> createState() => _SaleConfirmScreenState();
}

class _SaleConfirmScreenState extends State<SaleConfirmScreen> {
  Sale? _completedSale;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _submit());
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    final cart = context.read<CartProvider>();
    final authShopId = context.read<AuthProvider>().currentUser?.shopId ?? '';
    final shopId = authShopId.isNotEmpty
        ? authShopId
        : cart.items.firstOrNull?.product.shopId ?? '';

    final sale = await context.read<SalesProvider>().recordSale(
          shopId: shopId,
          cartItems: List.from(cart.items),
          paidAmount: cart.paidAmount,
          isCredit: cart.isCredit,
          customerId: cart.customerId,
        );

    if (!mounted) return;

    if (sale != null) {
      cart.clear();
      if (_isOwner) {
        context.read<DashboardProvider>().loadStats(shopId);
      }
      setState(() {
        _completedSale = sale;
        _isSubmitting = false;
      });
    } else {
      setState(() => _isSubmitting = false);
      final err = context.read<SalesProvider>().errorMessage ?? 'Sale failed';
      SnackBarHelper.showError(context, err);
    }
  }

  bool get _isOwner =>
      context.read<AuthProvider>().currentUser?.role == UserRole.owner;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primaryColor =
        _isOwner ? AppColors.ownerPrimary : AppColors.staffPrimary;

    if (_isSubmitting) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          title: Text(l10n.processingEllipsis,
              style: AppTextStyles.headingL.copyWith(color: Colors.white)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: primaryColor),
              const SizedBox(height: 16),
              Text(l10n.recordingEllipsis),
            ],
          ),
        ),
      );
    }

    if (_completedSale == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          title: Text(l10n.sales,
              style: AppTextStyles.headingL.copyWith(color: Colors.white)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.danger, size: 64),
                const SizedBox(height: 16),
                Text(
                  context.read<SalesProvider>().errorMessage ??
                      l10n.somethingWentWrong,
                  style: AppTextStyles.bodyM.copyWith(color: AppColors.danger),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                AppButton.outlined(
                    label: l10n.tryAgain, onPressed: _submit, width: 180),
              ],
            ),
          ),
        ),
      );
    }

    final sale = _completedSale!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.saleRecorded,
            style: AppTextStyles.headingL.copyWith(color: Colors.white)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 56),
                  const SizedBox(height: 12),
                  Text(l10n.paymentSuccessful,
                      style: AppTextStyles.headingL
                          .copyWith(color: AppColors.success)),
                  const SizedBox(height: 4),
                  Text(
                    l10n.saleRef(sale.id.substring(0, 8).toUpperCase()),
                    style: AppTextStyles.bodyM
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.receipt, style: AppTextStyles.headingM),
                  const SizedBox(height: 12),
                  const Divider(),
                  ...sale.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.products,
                                  style: AppTextStyles.bodyM
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '${item.quantity}× ${item.unit}  •  ${l10n.fcfa} ${item.unitPrice.toStringAsFixed(0)}',
                                  style: AppTextStyles.bodyS,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${l10n.fcfa} ${item.totalPrice.toStringAsFixed(0)}',
                            style: AppTextStyles.bodyM
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 6),
                  _Row(l10n.total,
                      '${l10n.fcfa} ${sale.totalAmount.toStringAsFixed(0)}'),
                  const SizedBox(height: 4),
                  _Row(
                    sale.isCredit ? l10n.owedCredit : l10n.paid,
                    sale.isCredit
                        ? '${l10n.fcfa} ${sale.dueAmount.toStringAsFixed(0)}'
                        : '${l10n.fcfa} ${sale.paidAmount.toStringAsFixed(0)}',
                    color: sale.isCredit ? AppColors.danger : AppColors.success,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppButton.primary(
              label: l10n.newSale,
              onPressed: () =>
                  context.go(_isOwner ? '/owner/dashboard' : '/staff/home'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _Row(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary)),
        Text(value,
            style: AppTextStyles.bodyM.copyWith(
              fontWeight: FontWeight.w700,
              color: color ?? AppColors.textPrimary,
            )),
      ],
    );
  }
}
