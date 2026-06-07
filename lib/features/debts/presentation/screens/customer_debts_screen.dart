import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/utils/currency_formatter.dart' show formatFCFA;
import 'package:shopkeeper/core/widgets/app_text_field.dart';
import 'package:shopkeeper/core/widgets/risk_badge.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/debts/domain/entities/customer.dart';
import 'package:shopkeeper/features/debts/presentation/providers/debt_provider.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';

class CustomerDebtsScreen extends StatefulWidget {
  const CustomerDebtsScreen({super.key});

  @override
  State<CustomerDebtsScreen> createState() => _CustomerDebtsScreenState();
}

class _CustomerDebtsScreenState extends State<CustomerDebtsScreen> {
  String _selectedFilter = 'All';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shopId = context.read<AuthProvider>().currentUser?.shopId ?? '';
      context.read<DebtProvider>().loadCustomers(shopId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Customer> _filtered(List<Customer> all) {
    var list = all;
    if (_selectedFilter == 'With Debt') {
      list = list.where((c) => c.totalDebt > 0).toList();
    }
    if (_selectedFilter == 'High') {
      list = list.where((c) => c.totalDebt > 30000).toList();
    }
    if (_selectedFilter == 'Medium') {
      list = list
          .where((c) => c.totalDebt > 10000 && c.totalDebt <= 30000)
          .toList();
    }
    if (_selectedFilter == 'Low') {
      list =
          list.where((c) => c.totalDebt > 0 && c.totalDebt <= 10000).toList();
    }
    if (_selectedFilter == 'Clear') {
      list = list.where((c) => c.totalDebt == 0).toList();
    }

    final q = _searchController.text.toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((c) => c.name.toLowerCase().contains(q) || c.phone.contains(q))
          .toList();
    }
    return list;
  }

  void _showCreateCustomerSheet() {
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
            Text(l10n.addCustomer, style: AppTextStyles.headingL),
            const SizedBox(height: 20),
            AppTextField(
              controller: nameCtrl,
              label: l10n.fullName,
              hintText: 'e.g. Jean-Pierre Foka',
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: phoneCtrl,
              label: l10n.phoneOptional,
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
                          final scaffoldMessenger =
                              ScaffoldMessenger.of(context);
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
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                  content: Text(
                                      '${customer.name} ${l10n.add.toLowerCase()}ed')),
                            );
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.ownerPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: provider.isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(l10n.saveCustomer),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.customers),
        backgroundColor: AppColors.ownerPrimary,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateCustomerSheet,
        backgroundColor: AppColors.ownerPrimary,
        icon: const Icon(Icons.person_add),
        label: Text(l10n.addCustomer),
      ),
      body: Consumer<DebtProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.customers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final filtered = _filtered(provider.customers);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: _SummaryCard(
                  totalDebt: provider.totalOutstandingDebt,
                  debtorCount: provider.customersWithDebt.length,
                  totalCount: provider.customers.length,
                  l10n: l10n,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: l10n.searchByNameOrPhone,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    'All',
                    'With Debt',
                    'High',
                    'Medium',
                    'Low',
                    'Clear'
                  ].map((f) {
                    final selected = _selectedFilter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(f),
                        selected: selected,
                        onSelected: (_) => setState(() => _selectedFilter = f),
                        backgroundColor: Colors.grey[200],
                        selectedColor: AppColors.ownerPrimary,
                        labelStyle: AppTextStyles.bodyM.copyWith(
                          color: selected ? Colors.white : Colors.grey[700],
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (provider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(provider.errorMessage!,
                      style: AppTextStyles.bodyM
                          .copyWith(color: AppColors.danger)),
                ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people,
                                size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(l10n.noCustomersFound,
                                style: AppTextStyles.bodyM
                                    .copyWith(color: Colors.grey[600])),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () {
                          final shopId = context
                                  .read<AuthProvider>()
                                  .currentUser
                                  ?.shopId ??
                              '';
                          return context
                              .read<DebtProvider>()
                              .loadCustomers(shopId);
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) => _CustomerCard(
                            customer: filtered[i],
                            l10n: l10n,
                            onTap: () =>
                                context.push('/owner/debts/${filtered[i].id}'),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double totalDebt;
  final int debtorCount;
  final int totalCount;
  final AppLocalizations l10n;
  const _SummaryCard(
      {required this.totalDebt,
      required this.debtorCount,
      required this.totalCount,
      required this.l10n});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.danger, AppColors.danger.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.totalOutstandingDebt,
                style: AppTextStyles.bodyM.copyWith(color: Colors.white70)),
            const SizedBox(height: 8),
            Text(formatFCFA(totalDebt),
                style: AppTextStyles.displayM.copyWith(color: Colors.white)),
            const SizedBox(height: 8),
            Text(
              '$debtorCount debtor${debtorCount == 1 ? '' : 's'} out of $totalCount customer${totalCount == 1 ? '' : 's'}',
              style: AppTextStyles.bodyM.copyWith(color: Colors.white70),
            ),
          ],
        ),
      );
}

class _CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;
  final AppLocalizations l10n;
  const _CustomerCard(
      {required this.customer, required this.onTap, required this.l10n});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Center(
                  child: Text(customer.initials,
                      style: AppTextStyles.headingS
                          .copyWith(color: AppColors.accent)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(customer.name,
                              style: AppTextStyles.bodyM
                                  .copyWith(fontWeight: FontWeight.w600)),
                        ),
                        RiskBadge(customer.riskCategory),
                      ],
                    ),
                    if (customer.phone.isNotEmpty)
                      Text(customer.phone,
                          style: AppTextStyles.bodyM
                              .copyWith(color: Colors.grey[600], fontSize: 12)),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.debtLabel,
                            style: AppTextStyles.bodyM.copyWith(
                                color: Colors.grey[600], fontSize: 12)),
                        Text(
                          formatFCFA(customer.totalDebt),
                          style: AppTextStyles.bodyM.copyWith(
                            fontWeight: FontWeight.w600,
                            color: customer.totalDebt > 0
                                ? AppColors.danger
                                : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      );
}
