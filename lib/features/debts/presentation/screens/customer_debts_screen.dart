import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/cache/cache_metadata_service.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/enums/risk_category.dart';
import 'package:shopkeeper/core/offline/hive_boxes.dart';
import 'package:shopkeeper/core/utils/currency_formatter.dart' show formatFCFA;
import 'package:shopkeeper/core/widgets/app_text_field.dart';
import 'package:shopkeeper/core/widgets/last_updated_indicator.dart';
import 'package:shopkeeper/core/widgets/offline_banner.dart';
import 'package:shopkeeper/core/widgets/risk_badge.dart';
import 'package:shopkeeper/di/injection.dart';
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
    switch (_selectedFilter) {
      case 'With Debt':
        list = list.where((c) => c.totalDebt > 0).toList();
      case 'High':
        list = list.where((c) => c.totalDebt > 30000).toList();
      case 'Medium':
        list = list
            .where((c) => c.totalDebt > 10000 && c.totalDebt <= 30000)
            .toList();
      case 'Low':
        list =
            list.where((c) => c.totalDebt > 0 && c.totalDebt <= 10000).toList();
      case 'Clear':
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(l10n.addCustomer, style: AppTextStyles.headingL),
            const SizedBox(height: 2),
            Text(
              'Add a new credit customer to your shop',
              style: AppTextStyles.bodyS,
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: nameCtrl,
              label: l10n.fullName,
              hintText: l10n.hintExFullName,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: phoneCtrl,
              label: l10n.phoneOptional,
              hintText: l10n.hintExPhone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
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
                            scaffoldMessenger.showSnackBar(SnackBar(
                              content: Text('${customer.name} added'),
                              backgroundColor: AppColors.success,
                            ));
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.ownerPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: provider.isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          l10n.saveCustomer,
                          style: AppTextStyles.headingS
                              .copyWith(color: Colors.white),
                        ),
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
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateCustomerSheet,
        backgroundColor: AppColors.ownerPrimary,
        tooltip: l10n.addCustomer,
        child: const Icon(Icons.person_add_outlined, color: Colors.white),
      ),
      body: Consumer<DebtProvider>(
        builder: (context, provider, _) {
          final filtered = _filtered(provider.customers);
          return RefreshIndicator(
            onRefresh: () {
              final shopId =
                  context.read<AuthProvider>().currentUser?.shopId ?? '';
              return context.read<DebtProvider>().loadCustomers(shopId);
            },
            color: AppColors.ownerPrimary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: OfflineBanner()),

                // ── Expanding header ────────────────────────────────────
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 160,
                  elevation: 0,
                  backgroundColor: AppColors.ownerPrimary,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.ownerPrimaryDark,
                            AppColors.ownerPrimary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 72, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            l10n.customers,
                            style: AppTextStyles.headingL
                                .copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 10),
                          if (!provider.isLoading ||
                              provider.customers.isNotEmpty)
                            Row(
                              children: [
                                _HeaderStat(
                                  label: l10n.totalOutstandingDebt,
                                  value:
                                      formatFCFA(provider.totalOutstandingDebt),
                                  valueColor: AppColors.accentLight,
                                ),
                                const SizedBox(width: 28),
                                _HeaderStat(
                                  label: 'Debtors',
                                  value:
                                      '${provider.customersWithDebt.length} of ${provider.customers.length}',
                                  valueColor: Colors.white,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Sticky search + filter ──────────────────────────────
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyBarDelegate(
                    searchController: _searchController,
                    selectedFilter: _selectedFilter,
                    onSearchChanged: () => setState(() {}),
                    onFilterChanged: (f) => setState(() => _selectedFilter = f),
                    l10n: l10n,
                  ),
                ),

                // ── Error banner ────────────────────────────────────────
                if (provider.errorMessage != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.dangerLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.danger.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppColors.danger, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                provider.errorMessage!,
                                style: AppTextStyles.bodyS
                                    .copyWith(color: AppColors.danger),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // ── Loading skeleton ────────────────────────────────────
                if (provider.isLoading && provider.customers.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )

                // ── Empty state ─────────────────────────────────────────
                else if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(
                      hasActiveSearch: _searchController.text.isNotEmpty ||
                          _selectedFilter != 'All',
                      l10n: l10n,
                    ),
                  )

                // ── Customer list ───────────────────────────────────────
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) {
                          if (i == filtered.length) {
                            return LastUpdatedIndicator(
                              boxName: HiveBoxes.customers,
                              metadata: getIt<CacheMetadataService>(),
                            );
                          }
                          return _CustomerCard(
                            customer: filtered[i],
                            l10n: l10n,
                            onTap: () =>
                                context.push('/owner/debts/${filtered[i].id}'),
                          );
                        },
                        childCount: filtered.length + 1,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Header stat ───────────────────────────────────────────────────────────────

class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _HeaderStat(
      {required this.label, required this.value, required this.valueColor});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.bodyS
                  .copyWith(color: Colors.white60, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value,
              style: AppTextStyles.headingS.copyWith(color: valueColor)),
        ],
      );
}

// ── Sticky search + filter delegate ──────────────────────────────────────────

class _StickyBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController searchController;
  final String selectedFilter;
  final VoidCallback onSearchChanged;
  final ValueChanged<String> onFilterChanged;
  final AppLocalizations l10n;

  static const double _height = 116.0;

  const _StickyBarDelegate({
    required this.searchController,
    required this.selectedFilter,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.l10n,
  });

  @override
  double get minExtent => _height;
  @override
  double get maxExtent => _height;

  @override
  bool shouldRebuild(_StickyBarDelegate old) =>
      old.selectedFilter != selectedFilter ||
      old.searchController.text != searchController.text;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: TextField(
              controller: searchController,
              onChanged: (_) => onSearchChanged(),
              style: AppTextStyles.bodyM,
              decoration: InputDecoration(
                hintText: l10n.searchByNameOrPhone,
                hintStyle:
                    AppTextStyles.bodyM.copyWith(color: AppColors.textHint),
                prefixIcon: const Icon(Icons.search,
                    size: 20, color: AppColors.textHint),
                suffixIcon: searchController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          searchController.clear();
                          onSearchChanged();
                        },
                        child: const Icon(Icons.close,
                            size: 18, color: AppColors.textHint),
                      )
                    : null,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['All', 'With Debt', 'High', 'Medium', 'Low', 'Clear']
                  .map((f) {
                final isActive = selectedFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => onFilterChanged(f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.ownerPrimary
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive
                              ? AppColors.ownerPrimary
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        f,
                        style: AppTextStyles.labelL.copyWith(
                          color:
                              isActive ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Customer card ─────────────────────────────────────────────────────────────

Color _riskAccent(RiskCategory r) {
  switch (r) {
    case RiskCategory.high:
      return AppColors.danger;
    case RiskCategory.medium:
      return AppColors.warning;
    case RiskCategory.low:
      return AppColors.success;
    case RiskCategory.newCustomer:
      return AppColors.accent;
  }
}

class _CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;
  final AppLocalizations l10n;
  const _CustomerCard(
      {required this.customer, required this.onTap, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final accent = _riskAccent(customer.riskCategory);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(color: accent, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    customer.initials,
                    style: AppTextStyles.headingS.copyWith(color: accent),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name + phone
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: AppTextStyles.headingS,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (customer.phone.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        customer.phone,
                        style: AppTextStyles.bodyS,
                      ),
                    ],
                    const SizedBox(height: 6),
                    RiskBadge(customer.riskCategory),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Debt amount + arrow
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatFCFA(customer.totalDebt),
                    style: AppTextStyles.headingS.copyWith(
                      color: customer.totalDebt > 0
                          ? AppColors.danger
                          : AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.debtLabel,
                    style: AppTextStyles.bodyS,
                  ),
                ],
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right,
                  color: AppColors.textHint, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool hasActiveSearch;
  final AppLocalizations l10n;
  const _EmptyState({required this.hasActiveSearch, required this.l10n});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.ownerPrimary.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.people_outline_rounded,
                  color: AppColors.ownerPrimary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                hasActiveSearch ? l10n.noCustomersFound : l10n.noCustomersFound,
                style: AppTextStyles.headingS
                    .copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                hasActiveSearch
                    ? 'Try a different name, phone, or filter'
                    : 'Add your first customer using the button below',
                style: AppTextStyles.bodyS,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}
