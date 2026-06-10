import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/widgets/app_button.dart';
import 'package:shopkeeper/core/widgets/app_text_field.dart';
import 'package:shopkeeper/core/enums/user_role.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/debts/domain/entities/customer.dart';
import 'package:shopkeeper/features/debts/presentation/providers/debt_provider.dart';
import 'package:shopkeeper/features/sales/presentation/providers/cart_provider.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isCredit = false;
  Customer? _selectedCustomer;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '0');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shopId = context.read<AuthProvider>().currentUser?.shopId ?? '';
      final provider = context.read<DebtProvider>();
      if (provider.customers.isEmpty) provider.loadCustomers(shopId);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  bool _canProceed(double total) {
    if (_isCredit) return _selectedCustomer != null;
    final entered = double.tryParse(_amountController.text) ?? 0;
    if (entered < total && _selectedCustomer == null) return false;
    return entered > 0;
  }

  bool get _isOwner =>
      context.read<AuthProvider>().currentUser?.role == UserRole.owner;

  void _proceed(double total) {
    final entered = double.tryParse(_amountController.text) ?? 0;
    final paid = _isCredit ? 0.0 : entered.clamp(0.0, total);

    context.read<CartProvider>().setPayment(
          paidAmount: paid,
          isCredit: _isCredit,
          customerId: _selectedCustomer?.id,
        );
    context.push(_isOwner ? '/owner/sale/confirm' : '/staff/sale/confirm');
  }

  void _openCustomerPicker() {
    final primaryColor =
        _isOwner ? AppColors.ownerPrimary : AppColors.staffPrimary;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CustomerPickerSheet(
        showWalkIn: !_isCredit,
        primaryColor: primaryColor,
        onSelected: (c) {
          setState(() => _selectedCustomer = c);
          Navigator.pop(context);
        },
        onCreateNew: () {
          Navigator.pop(context);
          _openCreateCustomerSheet();
        },
      ),
    );
  }

  void _openCreateCustomerSheet() {
    final l10n = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.newCustomer, style: AppTextStyles.headingL),
            const SizedBox(height: 16),
            AppTextField(
                controller: nameCtrl,
                label: l10n.fullName,
                hintText: l10n.hintExFullName),
            const SizedBox(height: 10),
            AppTextField(
              controller: phoneCtrl,
              label: l10n.phoneOptional,
              hintText: l10n.hintExPhone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            Consumer<DebtProvider>(
              builder: (_, provider, __) => SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: provider.isSaving
                      ? null
                      : () async {
                          final name = nameCtrl.text.trim();
                          if (name.isEmpty) return;
                          final debtProvider = context.read<DebtProvider>();
                          final shopId = context
                                  .read<AuthProvider>()
                                  .currentUser
                                  ?.shopId ??
                              '';
                          final customer = await debtProvider.createCustomer(
                            shopId: shopId,
                            name: name,
                            phone: phoneCtrl.text.trim().isEmpty
                                ? null
                                : phoneCtrl.text.trim(),
                          );
                          if (!ctx.mounted) return;
                          Navigator.pop(ctx);
                          if (customer != null) {
                            setState(() => _selectedCustomer = customer);
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: _isOwner
                        ? AppColors.ownerPrimary
                        : AppColors.staffPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: provider.isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(l10n.saveAndSelect),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primaryColor =
        _isOwner ? AppColors.ownerPrimary : AppColors.staffPrimary;
    return Consumer<CartProvider>(
      builder: (_, cart, __) {
        final total = cart.total;
        final entered = double.tryParse(_amountController.text) ?? 0;
        final change = _isCredit ? 0.0 : (entered - total);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(l10n.payment,
                style: AppTextStyles.headingL.copyWith(color: Colors.white)),
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, const Color(0xFF1A5C48)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.saleTotal,
                          style: AppTextStyles.bodyM
                              .copyWith(color: Colors.white70)),
                      const SizedBox(height: 6),
                      Text(
                        '${l10n.fcfa} ${total.toStringAsFixed(0)}',
                        style: AppTextStyles.displayM
                            .copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.itemCount(cart.itemCount),
                        style:
                            AppTextStyles.bodyS.copyWith(color: Colors.white60),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(l10n.paymentType, style: AppTextStyles.headingM),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _TypeChip(
                      label: l10n.cash,
                      icon: Icons.money,
                      color: AppColors.success,
                      selected: !_isCredit,
                      onTap: () => setState(() {
                        _isCredit = false;
                        _amountController.text = '0';
                      }),
                    ),
                    const SizedBox(width: 12),
                    _TypeChip(
                      label: l10n.credit,
                      icon: Icons.account_balance_wallet_outlined,
                      color: AppColors.danger,
                      selected: _isCredit,
                      onTap: () => setState(() {
                        _isCredit = true;
                        _amountController.text = '0';
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(l10n.customers, style: AppTextStyles.headingM),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _openCustomerPicker,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedCustomer != null
                            ? primaryColor
                            : AppColors.border,
                        width: _selectedCustomer != null ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _selectedCustomer != null
                              ? Icons.person
                              : (!_isCredit
                                  ? Icons.person_outline
                                  : Icons.person_search),
                          color: _selectedCustomer != null
                              ? primaryColor
                              : AppColors.textSecondary,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _selectedCustomer != null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_selectedCustomer!.name,
                                        style: AppTextStyles.bodyM.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: primaryColor)),
                                    if (_selectedCustomer!.phone.isNotEmpty)
                                      Text(_selectedCustomer!.phone,
                                          style: AppTextStyles.bodyS.copyWith(
                                              color: AppColors.textSecondary)),
                                  ],
                                )
                              : Text(
                                  _isCredit
                                      ? l10n.selectCustomerHint
                                      : l10n.walkInCustomer,
                                  style: AppTextStyles.bodyM.copyWith(
                                    color: _isCredit
                                        ? AppColors.textSecondary
                                        : AppColors.textPrimary,
                                    fontWeight: _isCredit
                                        ? FontWeight.w400
                                        : FontWeight.w500,
                                  ),
                                ),
                        ),
                        Icon(Icons.chevron_right,
                            color: Colors.grey[400], size: 20),
                      ],
                    ),
                  ),
                ),
                if ((_isCredit || change < 0) && _selectedCustomer == null) ...[
                  const SizedBox(height: 6),
                  Text(l10n.customerRequiredForCredit,
                      style: AppTextStyles.bodyS
                          .copyWith(color: AppColors.danger)),
                ],
                const SizedBox(height: 24),
                if (!_isCredit) ...[
                  Text(l10n.amountPaid, style: AppTextStyles.headingM),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.headingL,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixText: '${l10n.fcfa} ',
                      prefixStyle: AppTextStyles.headingM
                          .copyWith(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _SummaryRow(l10n.total, total, l10n: l10n),
                        const Divider(height: 20),
                        _SummaryRow(l10n.paid, entered, l10n: l10n),
                        const Divider(height: 20),
                        _SummaryRow(
                          change >= 0 ? l10n.change : l10n.owed,
                          change >= 0 ? change : -change,
                          color: change >= 0
                              ? AppColors.success
                              : AppColors.danger,
                          bold: true,
                          l10n: l10n,
                        ),
                      ],
                    ),
                  ),
                  if (change < 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.dangerLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.danger.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: AppColors.danger, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.partialPaymentNote,
                              style: AppTextStyles.bodyS
                                  .copyWith(color: AppColors.danger),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
                if (_isCredit) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.dangerLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.danger.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: AppColors.danger, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.fullAmountAsDebt,
                            style: AppTextStyles.bodyS
                                .copyWith(color: AppColors.danger),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                Row(
                  children: [
                    Expanded(
                      child: AppButton.outlined(
                        label: l10n.back,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton.primary(
                        label: l10n.confirm,
                        onPressed:
                            _canProceed(total) ? () => _proceed(total) : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : AppColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTextStyles.headingS
                    .copyWith(color: selected ? color : AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color? color;
  final bool bold;
  final AppLocalizations l10n;

  const _SummaryRow(this.label, this.amount,
      {this.color, this.bold = false, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyM.copyWith(
            color: AppColors.textSecondary,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          '${l10n.fcfa} ${amount.toStringAsFixed(0)}',
          style: AppTextStyles.bodyM.copyWith(
            color: color ?? AppColors.textPrimary,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CustomerPickerSheet extends StatefulWidget {
  final ValueChanged<Customer?> onSelected;
  final VoidCallback onCreateNew;
  final bool showWalkIn;
  final Color primaryColor;

  const _CustomerPickerSheet({
    required this.onSelected,
    required this.onCreateNew,
    required this.showWalkIn,
    required this.primaryColor,
  });

  @override
  State<_CustomerPickerSheet> createState() => _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends State<_CustomerPickerSheet> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String get _query => _searchCtrl.text.trim();

  List<Customer> _filtered(List<Customer> all) {
    final q = _query.toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where((c) => c.name.toLowerCase().contains(q) || c.phone.contains(q))
        .toList();
  }

  Color _debtColor(Customer c) {
    if (c.totalDebt > 10000) return AppColors.danger;
    if (c.totalDebt > 0) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSearching = _query.isNotEmpty;

    return Consumer<DebtProvider>(
      builder: (_, provider, __) {
        final customers = _filtered(provider.customers);

        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          expand: false,
          builder: (_, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // ── Drag handle ───────────────────────────────────────────
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // ── Header ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 14, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(l10n.selectCustomer,
                            style: AppTextStyles.headingL),
                      ),
                      OutlinedButton.icon(
                        onPressed: widget.onCreateNew,
                        icon: const Icon(Icons.person_add_outlined, size: 16),
                        label: Text(l10n.newButton),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: widget.primaryColor,
                          side: BorderSide(color: widget.primaryColor),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          textStyle: AppTextStyles.labelL,
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Walk-in card (cash mode, not while searching) ─────────
                if (widget.showWalkIn && !isSearching) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                    child: GestureDetector(
                      onTap: () => widget.onSelected(null),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 13),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.textSecondary
                                    .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person_outline,
                                  color: AppColors.textSecondary, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.walkInCustomer,
                                    style: AppTextStyles.bodyM
                                        .copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'No record needed',
                                    style: AppTextStyles.labelS.copyWith(
                                        color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.successLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Default',
                                style: AppTextStyles.labelS.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Section label
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 16, 2),
                    child: Row(
                      children: [
                        Text(
                          l10n.customers.toUpperCase(),
                          style: AppTextStyles.labelS.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                            child: Divider(height: 1, color: AppColors.border)),
                      ],
                    ),
                  ),
                ],
                // ── Search field ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: l10n.searchByNameOrPhone,
                      hintStyle: AppTextStyles.bodyM
                          .copyWith(color: AppColors.textSecondary),
                      prefixIcon: const Icon(Icons.search,
                          size: 20, color: AppColors.textSecondary),
                      suffixIcon: isSearching
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: widget.primaryColor, width: 1.5),
                      ),
                    ),
                  ),
                ),
                // ── Customer list ─────────────────────────────────────────
                Expanded(
                  child: provider.isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                              color: widget.primaryColor))
                      : customers.isEmpty
                          ? _PickerEmptyState(
                              searchQuery: _query,
                              onCreateNew: widget.onCreateNew,
                              l10n: l10n,
                            )
                          : ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                              itemCount: customers.length,
                              itemBuilder: (_, i) => _CustomerTile(
                                customer: customers[i],
                                debtColor: _debtColor(customers[i]),
                                onTap: () => widget.onSelected(customers[i]),
                                l10n: l10n,
                              ),
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Customer tile ─────────────────────────────────────────────────────────────

class _CustomerTile extends StatelessWidget {
  final Customer customer;
  final Color debtColor;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  const _CustomerTile({
    required this.customer,
    required this.debtColor,
    required this.onTap,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: debtColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      customer.initials,
                      style: AppTextStyles.headingS.copyWith(color: debtColor),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Name + phone
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: AppTextStyles.bodyM
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (customer.phone.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined,
                                size: 12, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              customer.phone,
                              style: AppTextStyles.labelS
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Debt badge or arrow
                if (customer.totalDebt > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: debtColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: debtColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '${l10n.fcfa} ${customer.totalDebt.toStringAsFixed(0)}',
                      style: AppTextStyles.labelS.copyWith(
                        color: debtColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  Icon(Icons.arrow_forward_ios,
                      size: 14, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _PickerEmptyState extends StatelessWidget {
  final String searchQuery;
  final VoidCallback onCreateNew;
  final AppLocalizations l10n;

  const _PickerEmptyState({
    required this.searchQuery,
    required this.onCreateNew,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final isSearching = searchQuery.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(
                isSearching ? Icons.search_off : Icons.people_outline,
                size: 34,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isSearching ? l10n.noCustomersFound : l10n.noCustomersFound,
              style: AppTextStyles.bodyM.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isSearching
                  ? 'Try a different name or phone number.'
                  : 'Add a customer to link sales and track debts.',
              style:
                  AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (!isSearching) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onCreateNew,
                icon: const Icon(Icons.person_add_outlined, size: 18),
                label: Text(l10n.createNewCustomer),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
