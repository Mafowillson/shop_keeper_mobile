import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/widgets/app_button.dart';
import 'package:shopkeeper/core/widgets/app_text_field.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/debts/domain/entities/customer.dart';
import 'package:shopkeeper/features/debts/presentation/providers/debt_provider.dart';
import 'package:shopkeeper/features/sales/presentation/providers/cart_provider.dart';

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
    final total = context.read<CartProvider>().total;
    _amountController = TextEditingController(text: total.toStringAsFixed(0));

    // Pre-load customers so the picker is instant.
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

  bool get _canProceed {
    if (_isCredit) return _selectedCustomer != null;
    final entered = double.tryParse(_amountController.text) ?? 0;
    return entered > 0;
  }

  void _proceed(double total) {
    final entered = double.tryParse(_amountController.text) ?? 0;
    final paid = _isCredit ? 0.0 : entered;

    context.read<CartProvider>().setPayment(
          paidAmount: paid,
          isCredit: _isCredit,
          customerId: _isCredit ? _selectedCustomer?.id : null,
        );
    context.push('/staff/sale/confirm');
  }

  void _openCustomerPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CustomerPickerSheet(
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
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New Customer', style: AppTextStyles.headingL),
            const SizedBox(height: 16),
            AppTextField(controller: nameCtrl, label: 'Full Name', hintText: 'e.g. Jean-Pierre Foka'),
            const SizedBox(height: 10),
            AppTextField(
              controller: phoneCtrl,
              label: 'Phone (optional)',
              hintText: 'e.g. 677001122',
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
                          final shopId =
                              context.read<AuthProvider>().currentUser?.shopId ?? '';
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
                    backgroundColor: AppColors.staffPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: provider.isSaving
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Save & Select'),
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
    return Consumer<CartProvider>(
      builder: (_, cart, __) {
        final total = cart.total;
        final entered = double.tryParse(_amountController.text) ?? 0;
        final change = _isCredit ? 0.0 : (entered - total);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('Payment',
                style:
                    AppTextStyles.headingL.copyWith(color: Colors.white)),
            backgroundColor: AppColors.staffPrimary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.staffPrimary, Color(0xFF1A5C48)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sale Total',
                          style: AppTextStyles.bodyM
                              .copyWith(color: Colors.white70)),
                      const SizedBox(height: 6),
                      Text(
                        'FCFA ${total.toStringAsFixed(0)}',
                        style: AppTextStyles.displayM
                            .copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${cart.itemCount} item${cart.itemCount == 1 ? '' : 's'}',
                        style: AppTextStyles.bodyS
                            .copyWith(color: Colors.white60),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Payment type toggle
                Text('Payment type', style: AppTextStyles.headingM),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _TypeChip(
                      label: 'Cash',
                      icon: Icons.money,
                      color: AppColors.success,
                      selected: !_isCredit,
                      onTap: () => setState(() {
                        _isCredit = false;
                        _amountController.text = total.toStringAsFixed(0);
                      }),
                    ),
                    const SizedBox(width: 12),
                    _TypeChip(
                      label: 'Credit',
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

                if (!_isCredit) ...[
                  Text('Amount paid', style: AppTextStyles.headingM),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.headingL,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixText: 'FCFA ',
                      prefixStyle: AppTextStyles.headingM
                          .copyWith(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.staffPrimary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Change summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _SummaryRow('Total', total),
                        const Divider(height: 20),
                        _SummaryRow('Paid', entered),
                        const Divider(height: 20),
                        _SummaryRow(
                          'Change',
                          change,
                          color: change >= 0
                              ? AppColors.success
                              : AppColors.danger,
                          bold: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else ...[
                  // ── Customer selector (required for credit) ──────────────
                  Text('Customer', style: AppTextStyles.headingM),
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
                              ? AppColors.staffPrimary
                              : AppColors.border,
                          width: _selectedCustomer != null ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _selectedCustomer != null
                                ? Icons.person
                                : Icons.person_search,
                            color: _selectedCustomer != null
                                ? AppColors.staffPrimary
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
                                              color: AppColors.staffPrimary)),
                                      if (_selectedCustomer!.phone.isNotEmpty)
                                        Text(_selectedCustomer!.phone,
                                            style: AppTextStyles.bodyS.copyWith(
                                                color: AppColors.textSecondary)),
                                    ],
                                  )
                                : Text('Select customer…',
                                    style: AppTextStyles.bodyM.copyWith(
                                        color: AppColors.textSecondary)),
                          ),
                          Icon(Icons.chevron_right,
                              color: Colors.grey[400], size: 20),
                        ],
                      ),
                    ),
                  ),
                  if (_selectedCustomer == null) ...[
                    const SizedBox(height: 6),
                    Text('A customer is required for credit sales.',
                        style: AppTextStyles.bodyS
                            .copyWith(color: AppColors.danger)),
                  ],
                  const SizedBox(height: 16),
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
                            'Full amount will be recorded as debt.',
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
                        label: 'Back',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton.primary(
                        label: 'Confirm',
                        onPressed: _canProceed ? () => _proceed(total) : null,
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
                style: AppTextStyles.headingS.copyWith(
                    color: selected ? color : AppColors.textPrimary),
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

  const _SummaryRow(this.label, this.amount,
      {this.color, this.bold = false});

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
          'FCFA ${amount.toStringAsFixed(0)}',
          style: AppTextStyles.bodyM.copyWith(
            color: color ?? AppColors.textPrimary,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ── Customer picker bottom sheet ──────────────────────────────────────────────

class _CustomerPickerSheet extends StatefulWidget {
  final ValueChanged<Customer> onSelected;
  final VoidCallback onCreateNew;

  const _CustomerPickerSheet({
    required this.onSelected,
    required this.onCreateNew,
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

  List<Customer> _filtered(List<Customer> all) {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where((c) =>
            c.name.toLowerCase().contains(q) || c.phone.contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DebtProvider>(
      builder: (_, provider, __) {
        final customers = _filtered(provider.customers);

        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) => Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('Select Customer',
                          style: AppTextStyles.headingL),
                    ),
                    TextButton.icon(
                      onPressed: widget.onCreateNew,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('New'),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.staffPrimary),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search by name or phone…',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
              ),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : customers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline,
                                    size: 48, color: Colors.grey[300]),
                                const SizedBox(height: 12),
                                Text('No customers found',
                                    style: AppTextStyles.bodyM.copyWith(
                                        color: Colors.grey[500])),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: widget.onCreateNew,
                                  child: const Text('Create new customer'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount: customers.length,
                            itemBuilder: (_, i) {
                              final c = customers[i];
                              return ListTile(
                                onTap: () => widget.onSelected(c),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                leading: CircleAvatar(
                                  backgroundColor:
                                      AppColors.accent.withValues(alpha: 0.15),
                                  child: Text(c.initials,
                                      style: AppTextStyles.headingS
                                          .copyWith(color: AppColors.accent)),
                                ),
                                title: Text(c.name,
                                    style: AppTextStyles.bodyM.copyWith(
                                        fontWeight: FontWeight.w600)),
                                subtitle: c.phone.isNotEmpty
                                    ? Text(c.phone,
                                        style: AppTextStyles.bodyS)
                                    : null,
                                trailing: c.totalDebt > 0
                                    ? Text(
                                        'FCFA ${c.totalDebt.toStringAsFixed(0)} debt',
                                        style: AppTextStyles.bodyS
                                            .copyWith(color: AppColors.danger),
                                      )
                                    : null,
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}
