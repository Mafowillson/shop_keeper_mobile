import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/cache/cache_metadata_service.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/offline/hive_boxes.dart';
import 'package:shopkeeper/core/widgets/last_updated_indicator.dart';
import 'package:shopkeeper/core/widgets/offline_banner.dart';
import 'package:shopkeeper/core/widgets/snack_bar_helper.dart';
import 'package:shopkeeper/di/injection.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/products/domain/entities/product.dart';
import 'package:shopkeeper/features/products/presentation/providers/product_provider.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';

Color _stockAccent(Product p) => p.isOutOfStock
    ? AppColors.danger
    : p.isLowStock
        ? AppColors.warning
        : AppColors.success;

// ── Screen ────────────────────────────────────────────────────────────────────

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _shopId => context.read<AuthProvider>().currentUser?.shopId ?? '';

  Future<void> _load({String? category}) => context
      .read<ProductProvider>()
      .loadProducts(_shopId, category: category == 'All' ? null : category);

  void _onSearchChanged(String query) {
    context.read<ProductProvider>().searchProducts(query, _shopId);
  }

  void _onCategoryChanged(String category) {
    setState(() => _selectedCategory = category);
    _load(category: category);
  }

  void _showRestockSheet(BuildContext context, Product product) {
    final qtyCtrl = TextEditingController();
    UnitDefinition? selectedUnit =
        product.units.isNotEmpty ? product.units.last : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final qty = int.tryParse(qtyCtrl.text) ?? 0;
          final unit = selectedUnit;
          final addedBase = unit != null ? qty * unit.quantityInBase : qty;
          final newTotal = product.stockQty + addedBase;

          return Padding(
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
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add_box_outlined,
                          color: AppColors.accent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Restock', style: AppTextStyles.headingM),
                          Text(
                            product.name,
                            style: AppTextStyles.bodyS,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text('Current stock: ', style: AppTextStyles.bodyS),
                      Text(
                        '${product.stockQty} ${product.baseUnit.isNotEmpty ? product.baseUnit : 'units'}',
                        style: AppTextStyles.headingS.copyWith(
                          color: product.isOutOfStock
                              ? AppColors.danger
                              : product.isLowStock
                                  ? AppColors.warning
                                  : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
                if (product.units.length > 1) ...[
                  const SizedBox(height: 16),
                  Text('Unit received',
                      style: AppTextStyles.labelL
                          .copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: product.units.map((u) {
                      final isSelected = selectedUnit == u;
                      return GestureDetector(
                        onTap: () => setSheet(() => selectedUnit = u),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.accent
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            '${u.name} (×${u.quantityInBase})',
                            style: AppTextStyles.labelL.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 16),
                Text('Quantity received',
                    style: AppTextStyles.labelL
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                TextField(
                  controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  onChanged: (_) => setSheet(() {}),
                  style: AppTextStyles.displayM,
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: AppTextStyles.displayM
                        .copyWith(color: AppColors.textHint),
                    suffixText: selectedUnit?.name ??
                        (product.baseUnit.isNotEmpty
                            ? product.baseUnit
                            : 'units'),
                    suffixStyle: AppTextStyles.headingS
                        .copyWith(color: AppColors.textSecondary),
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
                          const BorderSide(color: AppColors.accent, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                ),
                if (addedBase > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.trending_up,
                            size: 16, color: AppColors.success),
                        const SizedBox(width: 8),
                        Text('New total: ',
                            style: AppTextStyles.bodyS
                                .copyWith(color: AppColors.success)),
                        Text(
                          '$newTotal ${product.baseUnit.isNotEmpty ? product.baseUnit : 'units'}',
                          style: AppTextStyles.headingS
                              .copyWith(color: AppColors.success),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Consumer<ProductProvider>(
                  builder: (_, provider, __) => SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: provider.isSaving || addedBase == 0
                          ? null
                          : () async {
                              final scaffoldMessenger =
                                  ScaffoldMessenger.of(context);
                              final ok = await context
                                  .read<ProductProvider>()
                                  .restockProduct(product.id, newTotal);
                              if (!ctx.mounted) return;
                              if (ok) {
                                Navigator.pop(ctx);
                                scaffoldMessenger.showSnackBar(SnackBar(
                                  content: Text(
                                    'Stock updated: $newTotal ${product.baseUnit.isNotEmpty ? product.baseUnit : 'units'}',
                                  ),
                                  backgroundColor: AppColors.success,
                                ));
                              } else {
                                final err = context
                                    .read<ProductProvider>()
                                    .errorMessage;
                                scaffoldMessenger.showSnackBar(SnackBar(
                                  content:
                                      Text(err ?? 'Failed to update stock'),
                                  backgroundColor: AppColors.danger,
                                ));
                              }
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
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
                              'Add Stock',
                              style: AppTextStyles.headingS
                                  .copyWith(color: Colors.white),
                            ),
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

  Future<void> _confirmDeactivate(BuildContext context, Product product) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.removeProduct, style: AppTextStyles.headingM),
        content: Text(
          l10n.deactivateProductConfirm(product.name),
          style: AppTextStyles.bodyM,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(l10n.remove),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    final ok =
        await context.read<ProductProvider>().deactivateProduct(product.id);
    if (!context.mounted) return;
    if (ok) {
      SnackBarHelper.showSuccess(
          context, '${product.name} ${l10n.remove.toLowerCase()}d');
    } else {
      final err = context.read<ProductProvider>().errorMessage ?? l10n.error;
      SnackBarHelper.showError(context, err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          final categories = ['All', ...provider.categories];
          final products = provider.products;
          final outCount = products.where((p) => p.isOutOfStock).length;
          final lowCount = products.where((p) => p.isLowStock).length;

          return RefreshIndicator(
            onRefresh: () => _load(category: _selectedCategory),
            color: AppColors.ownerPrimary,
            child: CustomScrollView(
              slivers: [
                // ── App bar + stock summary ─────────────────────────────
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 148,
                  backgroundColor: AppColors.ownerPrimary,
                  foregroundColor: Colors.white,
                  title: Text(
                    l10n.products,
                    style: AppTextStyles.headingL.copyWith(color: Colors.white),
                  ),
                  actions: [
                    if (provider.isRefreshing)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          ),
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      tooltip: l10n.addProductTooltip,
                      onPressed: () async {
                        await context.push('/owner/products/add');
                        if (mounted) _load(category: _selectedCategory);
                      },
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.ownerPrimary,
                            Color(0xFF1B5E20),
                          ],
                        ),
                      ),
                      alignment: Alignment.bottomLeft,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                      child: Row(
                        children: [
                          _HeaderStat(
                            value: '${products.length}',
                            label: 'products',
                          ),
                          if (outCount > 0) ...[
                            const SizedBox(width: 10),
                            _HeaderStat(
                              value: '$outCount',
                              label: 'out of stock',
                              accent: AppColors.danger,
                            ),
                          ],
                          if (lowCount > 0) ...[
                            const SizedBox(width: 10),
                            _HeaderStat(
                              value: '$lowCount',
                              label: 'low stock',
                              accent: AppColors.warning,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Sticky search + category chips ──────────────────────
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyBarDelegate(
                    categories: categories,
                    selectedCategory: _selectedCategory,
                    searchController: _searchController,
                    onSearchChanged: _onSearchChanged,
                    onClearSearch: () {
                      _searchController.clear();
                      _load(category: _selectedCategory);
                    },
                    onCategoryChanged: _onCategoryChanged,
                  ),
                ),

                // ── Offline + error banners ─────────────────────────────
                const SliverToBoxAdapter(child: OfflineBanner()),
                if (provider.errorMessage != null)
                  SliverToBoxAdapter(
                    child: _ErrorBanner(
                      message: provider.errorMessage!,
                      onRetry: () => _load(category: _selectedCategory),
                    ),
                  ),

                // ── Count row ───────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(
                      provider.isLoading && products.isEmpty
                          ? l10n.loadingEllipsis
                          : '${products.length} ${l10n.products.toLowerCase()}',
                      style: AppTextStyles.bodyM
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ),

                // ── Loading / empty / list ──────────────────────────────
                if (provider.isLoading && products.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.ownerPrimary),
                    ),
                  )
                else if (products.isEmpty)
                  SliverFillRemaining(
                    child: _EmptyState(
                      hasSearch: _searchController.text.isNotEmpty,
                      onAdd: () async {
                        await context.push('/owner/products/add');
                        if (mounted) _load(category: _selectedCategory);
                      },
                      l10n: l10n,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _ProductCard(
                          product: products[i],
                          l10n: l10n,
                          onEdit: () async {
                            await context
                                .push('/owner/products/${products[i].id}/edit');
                            if (mounted) _load(category: _selectedCategory);
                          },
                          onRestock: () =>
                              _showRestockSheet(context, products[i]),
                          onDeactivate: () =>
                              _confirmDeactivate(context, products[i]),
                        ),
                        childCount: products.length,
                      ),
                    ),
                  ),

                // ── Footer ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: LastUpdatedIndicator(
                    boxName: HiveBoxes.products,
                    metadata: getIt<CacheMetadataService>(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Header stat chip ──────────────────────────────────────────────────────────

class _HeaderStat extends StatelessWidget {
  final String value;
  final String label;
  final Color? accent;

  const _HeaderStat({
    required this.value,
    required this.label,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: accent != null
            ? Border.all(color: accent!.withValues(alpha: 0.5))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyles.headingM.copyWith(color: Colors.white),
          ),
          Text(
            label,
            style: AppTextStyles.bodyS.copyWith(
              color: accent ?? Colors.white.withValues(alpha: 0.8),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sticky search + filter bar ────────────────────────────────────────────────

class _StickyBarDelegate extends SliverPersistentHeaderDelegate {
  final List<String> categories;
  final String selectedCategory;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onCategoryChanged;

  const _StickyBarDelegate({
    required this.categories,
    required this.selectedCategory,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onCategoryChanged,
  });

  static const double _h = 104.0;

  @override
  double get minExtent => _h;
  @override
  double get maxExtent => _h;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      elevation: overlapsContent ? 2 : 0,
      shadowColor: Colors.black12,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            SizedBox(
              height: 44,
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                style: AppTextStyles.bodyM,
                decoration: InputDecoration(
                  hintText: 'Search by name or category…',
                  hintStyle:
                      AppTextStyles.bodyM.copyWith(color: AppColors.textHint),
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.textHint, size: 20),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              size: 18, color: AppColors.textHint),
                          padding: EdgeInsets.zero,
                          onPressed: onClearSearch,
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: AppColors.ownerPrimary, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Category chips
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final cat = categories[i];
                  final selected = selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => onCategoryChanged(cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.ownerPrimary
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? AppColors.ownerPrimary
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: AppTextStyles.labelL.copyWith(
                          color:
                              selected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_StickyBarDelegate old) => true;
}

// ── Product card ──────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onRestock;
  final VoidCallback onDeactivate;
  final AppLocalizations l10n;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onRestock,
    required this.onDeactivate,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final accent = _stockAccent(product);
    final unitLabel = product.baseUnit.isNotEmpty ? product.baseUnit : 'units';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left accent strip
              Container(width: 4, color: accent),
              // Content
              Expanded(
                child: InkWell(
                  onTap: onEdit,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 14, 4, 14),
                    child: Row(
                      children: [
                        // Product icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.inventory_2_outlined,
                              color: AppColors.accent, size: 22),
                        ),
                        const SizedBox(width: 12),
                        // Text column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: AppTextStyles.bodyM
                                    .copyWith(fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                product.category,
                                style: AppTextStyles.bodyS
                                    .copyWith(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    '${l10n.fcfa} ${product.retailPrice.toStringAsFixed(0)}',
                                    style: AppTextStyles.labelL.copyWith(
                                      color: AppColors.ownerPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Stock chip
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: accent.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      product.isOutOfStock
                                          ? 'Out of stock'
                                          : '${product.stockQty} $unitLabel',
                                      style: AppTextStyles.bodyS.copyWith(
                                        color: accent,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Actions menu
                        IconButton(
                          icon: const Icon(Icons.more_vert,
                              color: AppColors.textHint, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24)),
                            ),
                            builder: (_) => _ProductActionsSheet(
                              product: product,
                              onEdit: onEdit,
                              onRestock: onRestock,
                              onDeactivate: onDeactivate,
                              l10n: l10n,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Error banner ──────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.dangerLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: AppTextStyles.bodyS.copyWith(color: AppColors.danger)),
          ),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.danger,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool hasSearch;
  final VoidCallback onAdd;
  final AppLocalizations l10n;

  const _EmptyState(
      {required this.hasSearch, required this.onAdd, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: Icon(
                hasSearch ? Icons.search_off : Icons.inventory_2_outlined,
                size: 36,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasSearch ? l10n.noProductsMatchSearch : l10n.noProductsYet,
              style: AppTextStyles.headingM
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (!hasSearch) ...[
              const SizedBox(height: 8),
              Text(
                l10n.addFirstProduct,
                style: AppTextStyles.bodyM
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.addProduct),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.ownerPrimary,
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

// ── Product actions sheet ─────────────────────────────────────────────────────

class _ProductActionsSheet extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onRestock;
  final VoidCallback onDeactivate;
  final AppLocalizations l10n;

  const _ProductActionsSheet({
    required this.product,
    required this.onEdit,
    required this.onRestock,
    required this.onDeactivate,
    required this.l10n,
  });

  void _dismiss(BuildContext context, VoidCallback action) {
    Navigator.pop(context);
    action();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Product summary
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.inventory_2_outlined,
                        color: AppColors.accent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name,
                            style: AppTextStyles.headingS,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(
                          '${product.category}  ·  ${l10n.fcfa} ${product.retailPrice.toStringAsFixed(0)}  ·  ${product.stockQty} in stock',
                          style: AppTextStyles.bodyS,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.edit_outlined,
              iconColor: AppColors.ownerPrimary,
              title: l10n.edit,
              subtitle: 'Update name, price, category or units',
              onTap: () => _dismiss(context, onEdit),
            ),
            const SizedBox(height: 4),
            _ActionTile(
              icon: Icons.add_box_outlined,
              iconColor: AppColors.accent,
              title: 'Restock',
              subtitle: 'New stock arrived? Add to current quantity',
              onTap: () => _dismiss(context, onRestock),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: AppColors.border),
            ),
            _ActionTile(
              icon: Icons.delete_outline,
              iconColor: AppColors.danger,
              title: l10n.remove,
              subtitle: 'Deactivate and hide from your catalogue',
              titleColor: AppColors.danger,
              onTap: () => _dismiss(context, onDeactivate),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color? titleColor;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.headingS.copyWith(
                        color: titleColor ?? AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.bodyS),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: AppColors.textHint, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
