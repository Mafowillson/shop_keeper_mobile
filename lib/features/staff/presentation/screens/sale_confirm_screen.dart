import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/widgets/app_button.dart';
import 'package:shopkeeper/core/widgets/snack_bar_helper.dart';
import 'package:shopkeeper/core/enums/user_role.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:shopkeeper/features/debts/presentation/providers/debt_provider.dart';
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
  bool _generatingPdf = false;
  List<_ReceiptLine> _receiptLines = [];
  String _customerName = '';

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

    // Capture product names and customer name before cart is cleared
    final lines = cart.items
        .map((i) => _ReceiptLine(
              productName: i.product.name,
              quantity: i.quantity,
              unit: i.unit.name,
              unitPrice: i.unitPrice,
              totalPrice: i.subtotal,
            ))
        .toList();

    String customerName = 'Walk-in Customer';
    if (cart.customerId != null) {
      final customers = context.read<DebtProvider>().customers;
      final match = customers.where((c) => c.id == cart.customerId).firstOrNull;
      if (match != null) customerName = match.name;
    }

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
        _receiptLines = lines;
        _customerName = customerName;
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

  void _shareAsText(Sale sale) {
    final shopName =
        context.read<AuthProvider>().currentUser?.shopName ?? 'ShopKeeper';
    final dateStr =
        DateFormat('dd MMM yyyy, HH:mm').format(sale.createdAt.toLocal());
    final ref = sale.id.substring(0, 8).toUpperCase();

    final buf = StringBuffer();
    buf.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━');
    buf.writeln('  $shopName');
    buf.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━');
    buf.writeln('Ref     : #$ref');
    buf.writeln('Date    : $dateStr');
    buf.writeln('Customer: $_customerName');
    buf.writeln('─────────────────────────');
    for (final line in _receiptLines) {
      buf.writeln('${line.quantity}× ${line.productName} (${line.unit})');
      buf.writeln(
          '   ${line.unitPrice.toStringAsFixed(0)} × ${line.quantity} = ${line.totalPrice.toStringAsFixed(0)} FCFA');
    }
    buf.writeln('─────────────────────────');
    buf.writeln('Total   : ${sale.totalAmount.toStringAsFixed(0)} FCFA');
    buf.writeln('Paid    : ${sale.paidAmount.toStringAsFixed(0)} FCFA');
    if (sale.dueAmount > 0) {
      buf.writeln('Owed    : ${sale.dueAmount.toStringAsFixed(0)} FCFA');
    }
    buf.writeln('Payment : ${sale.isCredit ? "Credit" : "Cash"}');
    buf.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━');
    buf.writeln('Thank you for your purchase!');

    Share.share(buf.toString(), subject: 'Receipt #$ref – $shopName');
  }

  Future<void> _shareAsPdf(Sale sale) async {
    setState(() => _generatingPdf = true);
    try {
      final shopName =
          context.read<AuthProvider>().currentUser?.shopName ?? 'ShopKeeper';
      final dateStr =
          DateFormat('dd MMM yyyy, HH:mm').format(sale.createdAt.toLocal());
      final ref = sale.id.substring(0, 8).toUpperCase();

      final doc = pw.Document();

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a5,
          margin: const pw.EdgeInsets.all(36),
          build: (_) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────
              pw.Center(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      shopName,
                      style: pw.TextStyle(
                          fontSize: 22, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'RECEIPT',
                      style:
                          const pw.TextStyle(fontSize: 11, letterSpacing: 2.0),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),
              pw.Divider(thickness: 1.5),
              pw.SizedBox(height: 8),
              // ── Meta ─────────────────────────────────────────────────────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Ref: #$ref',
                      style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(dateStr, style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Text('Customer: $_customerName',
                  style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 16),
              // ── Items header ──────────────────────────────────────────────
              pw.Container(
                color: PdfColors.grey200,
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 4,
                      child: pw.Text('Item',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    ),
                    pw.SizedBox(
                      width: 28,
                      child: pw.Text('Qty',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 10),
                          textAlign: pw.TextAlign.center),
                    ),
                    pw.SizedBox(
                      width: 58,
                      child: pw.Text('Price',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 10),
                          textAlign: pw.TextAlign.right),
                    ),
                    pw.SizedBox(
                      width: 58,
                      child: pw.Text('Total',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 10),
                          textAlign: pw.TextAlign.right),
                    ),
                  ],
                ),
              ),
              // ── Items rows ────────────────────────────────────────────────
              ..._receiptLines.map(
                (line) => pw.Container(
                  padding:
                      const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                        bottom: pw.BorderSide(color: PdfColors.grey200)),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 4,
                        child: pw.Text(
                          '${line.productName} (${line.unit})',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                      pw.SizedBox(
                        width: 28,
                        child: pw.Text('${line.quantity}',
                            style: const pw.TextStyle(fontSize: 10),
                            textAlign: pw.TextAlign.center),
                      ),
                      pw.SizedBox(
                        width: 58,
                        child: pw.Text(line.unitPrice.toStringAsFixed(0),
                            style: const pw.TextStyle(fontSize: 10),
                            textAlign: pw.TextAlign.right),
                      ),
                      pw.SizedBox(
                        width: 58,
                        child: pw.Text(line.totalPrice.toStringAsFixed(0),
                            style: const pw.TextStyle(fontSize: 10),
                            textAlign: pw.TextAlign.right),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 14),
              pw.Divider(thickness: 1.5),
              pw.SizedBox(height: 8),
              // ── Totals ────────────────────────────────────────────────────
              _pdfRow('Total', '${sale.totalAmount.toStringAsFixed(0)} FCFA',
                  bold: true, size: 13),
              pw.SizedBox(height: 5),
              _pdfRow('Paid', '${sale.paidAmount.toStringAsFixed(0)} FCFA'),
              if (sale.dueAmount > 0) ...[
                pw.SizedBox(height: 5),
                _pdfRow(
                    'Balance Due', '${sale.dueAmount.toStringAsFixed(0)} FCFA',
                    color: PdfColors.red700),
              ],
              pw.SizedBox(height: 5),
              _pdfRow('Payment', sale.isCredit ? 'Credit' : 'Cash'),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text('Thank you for your purchase!',
                    style: const pw.TextStyle(fontSize: 10)),
              ),
            ],
          ),
        ),
      );

      await Printing.sharePdf(
        bytes: await doc.save(),
        filename: 'receipt_$ref.pdf',
      );
    } finally {
      if (mounted) setState(() => _generatingPdf = false);
    }
  }

  pw.Widget _pdfRow(
    String label,
    String value, {
    bool bold = false,
    double size = 11,
    PdfColor? color,
  }) {
    final style = pw.TextStyle(
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      fontSize: size,
      color: color,
    );
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: style),
        pw.Text(value, style: style),
      ],
    );
  }

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
            // ── Success banner ──────────────────────────────────────────────
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
            // ── Receipt card ────────────────────────────────────────────────
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
                  Row(
                    children: [
                      Expanded(
                          child: Text(l10n.receipt,
                              style: AppTextStyles.headingM)),
                      Text(
                        _customerName,
                        style: AppTextStyles.bodyS
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  ..._receiptLines.map(
                    (line) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  line.productName,
                                  style: AppTextStyles.bodyM
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '${line.quantity}× ${line.unit}  •  ${l10n.fcfa} ${line.unitPrice.toStringAsFixed(0)}',
                                  style: AppTextStyles.bodyS,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${l10n.fcfa} ${line.totalPrice.toStringAsFixed(0)}',
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
            const SizedBox(height: 16),
            // ── Share buttons ───────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareAsText(sale),
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: Text(l10n.shareReceipt),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      textStyle: AppTextStyles.labelL,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _generatingPdf ? null : () => _shareAsPdf(sale),
                    icon: _generatingPdf
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: primaryColor),
                          )
                        : const Icon(Icons.picture_as_pdf_outlined, size: 18),
                    label: Text(l10n.pdfReceipt),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(
                          color:
                              _generatingPdf ? AppColors.border : primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      textStyle: AppTextStyles.labelL,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // ── New sale ────────────────────────────────────────────────────
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

class _ReceiptLine {
  final String productName;
  final int quantity;
  final String unit;
  final double unitPrice;
  final double totalPrice;

  const _ReceiptLine({
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalPrice,
  });
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
