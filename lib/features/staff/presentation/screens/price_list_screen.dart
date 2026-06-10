import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/enums/user_role.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/products/domain/entities/product.dart';
import 'package:shopkeeper/features/products/presentation/providers/product_provider.dart';
import 'package:shopkeeper/features/staff/presentation/screens/product_detail_screen.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';
import 'package:shopkeeper/l10n/app_localizations_ext.dart';

class PriceListScreen extends StatefulWidget {
  const PriceListScreen({super.key});

  @override
  State<PriceListScreen> createState() => _PriceListScreenState();
}

class _PriceListScreenState extends State<PriceListScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shopId = context.read<AuthProvider>().currentUser?.shopId ?? '';
      final provider = context.read<ProductProvider>();
      if (provider.products.isEmpty) provider.loadProducts(shopId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _filtered(List<Product> all) {
    var list = all.where((p) => p.isActive).toList();
    if (_selectedCategory != 'All') {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }
    final q = _searchController.text.toLowerCase().trim();
    if (q.isNotEmpty) {
      list = list.where((p) => p.name.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  List<String> _categories(List<Product> all) {
    final cats = all.map((p) => p.category).toSet().toList()..sort();
    return ['All', ...cats];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isOwner =
        context.read<AuthProvider>().currentUser?.role == UserRole.owner;
    final primaryColor =
        isOwner ? AppColors.ownerPrimary : AppColors.staffPrimary;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          final categories = _categories(provider.products);
          final products = _filtered(provider.products);

          return NestedScrollView(
            headerSliverBuilder: (_, __) => [
              _SearchAppBar(
                controller: _searchController,
                onChanged: () => setState(() {}),
                resultCount: products.length,
                l10n: l10n,
                primaryColor: primaryColor,
              ),
              _CategorySliver(
                categories: categories,
                selected: _selectedCategory,
                onSelect: (c) => setState(() => _selectedCategory = c),
                l10n: l10n,
                primaryColor: primaryColor,
              ),
            ],
            body: _Body(
              provider: provider,
              products: products,
              l10n: l10n,
              primaryColor: primaryColor,
              onRefresh: () {
                final shopId =
                    context.read<AuthProvider>().currentUser?.shopId ?? '';
                return context.read<ProductProvider>().loadProducts(shopId);
              },
            ),
          );
        },
      ),
    );
  }
}

// ── Search app bar ────────────────────────────────────────────────────────────

class _SearchAppBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;
  final int resultCount;
  final AppLocalizations l10n;
  final Color primaryColor;

  const _SearchAppBar({
    required this.controller,
    required this.onChanged,
    required this.resultCount,
    required this.l10n,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) => SliverAppBar(
        pinned: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.priceList,
                style: AppTextStyles.headingM.copyWith(color: Colors.white)),
            Text(
              '$resultCount ${l10n.products.toLowerCase()}',
              style: AppTextStyles.labelM.copyWith(color: Colors.white60),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: primaryColor,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: TextField(
              controller: controller,
              onChanged: (_) => onChanged(),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: l10n.searchProductsHint,
                hintStyle:
                    TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                prefixIcon: Icon(Icons.search,
                    color: Colors.white.withValues(alpha: 0.75), size: 20),
                suffixIcon: controller.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          controller.clear();
                          onChanged();
                        },
                        child: Icon(Icons.close,
                            color: Colors.white.withValues(alpha: 0.75),
                            size: 18),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.12),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      );
}

// ── Category sliver ───────────────────────────────────────────────────────────

class _CategorySliver extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelect;
  final AppLocalizations l10n;
  final Color primaryColor;

  const _CategorySliver({
    required this.categories,
    required this.selected,
    required this.onSelect,
    required this.l10n,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) => SliverPersistentHeader(
        pinned: true,
        delegate: _CategoryDelegate(
          categories: categories,
          selected: selected,
          onSelect: onSelect,
          l10n: l10n,
          primaryColor: primaryColor,
        ),
      );
}

class _CategoryDelegate extends SliverPersistentHeaderDelegate {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelect;
  final AppLocalizations l10n;
  final Color primaryColor;

  _CategoryDelegate({
    required this.categories,
    required this.selected,
    required this.onSelect,
    required this.l10n,
    required this.primaryColor,
  });

  @override
  double get minExtent => 44;
  @override
  double get maxExtent => 44;

  @override
  bool shouldRebuild(_CategoryDelegate old) =>
      old.selected != selected ||
      old.categories.length != categories.length ||
      old.l10n.localeName != l10n.localeName ||
      old.primaryColor != primaryColor;

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Container(
        color: Colors.white,
        height: 44,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          itemCount: categories.length,
          itemBuilder: (_, i) {
            final cat = categories[i];
            final isSelected = cat == selected;
            final displayText =
                cat == 'All' ? l10n.all : l10n.translateCategory(cat);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onSelect(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? primaryColor : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    displayText,
                    style: AppTextStyles.labelL.copyWith(
                      color:
                          isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final ProductProvider provider;
  final List<Product> products;
  final AppLocalizations l10n;
  final Color primaryColor;
  final Future<void> Function() onRefresh;

  const _Body({
    required this.provider,
    required this.products,
    required this.l10n,
    required this.primaryColor,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading && provider.products.isEmpty) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }

    if (provider.errorMessage != null && provider.products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off,
                  size: 48, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              Text(provider.errorMessage!,
                  style: AppTextStyles.bodyM
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(l10n.retry),
                style: FilledButton.styleFrom(backgroundColor: primaryColor),
              ),
            ],
          ),
        ),
      );
    }

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 52, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(l10n.noProductsMatchSearch,
                style: AppTextStyles.bodyM.copyWith(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
        itemCount: products.length,
        itemBuilder: (_, i) => _PriceCard(
            product: products[i], l10n: l10n, primaryColor: primaryColor),
      ),
    );
  }
}

// ── Price card ────────────────────────────────────────────────────────────────

class _PriceCard extends StatelessWidget {
  final Product product;
  final AppLocalizations l10n;
  final Color primaryColor;
  const _PriceCard(
      {required this.product, required this.l10n, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final isOut = product.isOutOfStock;
    final sortedUnits = [...product.units]
      ..sort((a, b) => a.quantityInBase.compareTo(b.quantityInBase));

    return Opacity(
      opacity: isOut ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
              product: product,
              primaryColor: primaryColor,
            ),
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Header: name + category + status ──
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 36,
                      decoration: BoxDecoration(
                        color:
                            isOut ? Colors.grey.shade300 : primaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: AppTextStyles.headingS,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.translateCategory(product.category),
                            style: AppTextStyles.bodyS
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StockPill(product, l10n: l10n),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              // ── Unit price rows ──
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                child: Column(
                  children: [
                    for (int i = 0; i < sortedUnits.length; i++) ...[
                      _UnitPriceRow(
                        unit: sortedUnits[i],
                        l10n: l10n,
                        primaryColor: primaryColor,
                      ),
                      const Divider(height: 1, color: AppColors.border),
                    ],
                    // ── Stock row ──
                    _StockCountRow(product: product, l10n: l10n),
                  ],
                ),
              ),
              // ── Stock progress bar ──
              if (!isOut) _StockBar(product: product),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Unit price row ────────────────────────────────────────────────────────────

class _UnitPriceRow extends StatelessWidget {
  final UnitDefinition unit;
  final AppLocalizations l10n;
  final Color primaryColor;
  const _UnitPriceRow(
      {required this.unit, required this.l10n, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final isBase = unit.quantityInBase == 1;
    final color = isBase ? primaryColor : AppColors.accent;
    final label =
        isBase ? unit.name : '${unit.name} ×${unit.quantityInBase}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Icon(
            isBase ? Icons.sell_outlined : Icons.inventory_2_outlined,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style:
                  AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Text(
            '${l10n.fcfa} ${unit.price.toStringAsFixed(0)}',
            style: AppTextStyles.headingS.copyWith(color: color, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ── Stock count row ───────────────────────────────────────────────────────────

class _StockCountRow extends StatelessWidget {
  final Product product;
  final AppLocalizations l10n;
  const _StockCountRow({required this.product, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final stockColor = product.isOutOfStock
        ? AppColors.danger
        : product.isLowStock
            ? AppColors.warning
            : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          const Icon(Icons.layers_outlined,
              size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.inStock,
              style:
                  AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Text(
            '${product.stockQty} ${product.baseUnit}',
            style: AppTextStyles.headingS
                .copyWith(color: stockColor, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ── Stock bar ─────────────────────────────────────────────────────────────────

class _StockBar extends StatelessWidget {
  final Product product;
  const _StockBar({required this.product});

  @override
  Widget build(BuildContext context) {
    final threshold = product.lowStockThreshold.toDouble();
    final stock = product.stockQty.toDouble();
    final max = (threshold * 3).clamp(1.0, double.infinity);
    final ratio = (stock / max).clamp(0.0, 1.0);

    final barColor = product.isLowStock ? AppColors.warning : AppColors.success;

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
        color: Colors.white,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
        child: LinearProgressIndicator(
          value: ratio,
          minHeight: 4,
          backgroundColor: Colors.grey.shade100,
          valueColor: AlwaysStoppedAnimation<Color>(barColor),
        ),
      ),
    );
  }
}

// ── Stock pill ────────────────────────────────────────────────────────────────

class _StockPill extends StatelessWidget {
  final Product product;
  final AppLocalizations l10n;
  const _StockPill(this.product, {required this.l10n});

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color fg;
    final Color bg;

    if (product.isOutOfStock) {
      label = l10n.outOfStock;
      fg = AppColors.danger;
      bg = AppColors.dangerLight;
    } else if (product.isLowStock) {
      label = l10n.lowStockAlert;
      fg = AppColors.warning;
      bg = AppColors.warningLight;
    } else {
      label = l10n.availableLabel;
      fg = AppColors.success;
      bg = AppColors.successLight;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(label,
              style: AppTextStyles.labelM
                  .copyWith(color: fg, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
