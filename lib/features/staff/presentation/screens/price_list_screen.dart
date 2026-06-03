import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/products/domain/entities/product.dart';
import 'package:shopkeeper/features/products/presentation/providers/product_provider.dart';

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
              ),
              _CategorySliver(
                categories: categories,
                selected: _selectedCategory,
                onSelect: (c) => setState(() => _selectedCategory = c),
              ),
            ],
            body: _Body(
              provider: provider,
              products: products,
              onRefresh: () {
                final shopId = context
                        .read<AuthProvider>()
                        .currentUser
                        ?.shopId ??
                    '';
                return context
                    .read<ProductProvider>()
                    .loadProducts(shopId);
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

  const _SearchAppBar({
    required this.controller,
    required this.onChanged,
    required this.resultCount,
  });

  @override
  Widget build(BuildContext context) => SliverAppBar(
        pinned: true,
        backgroundColor: AppColors.staffPrimary,
        foregroundColor: Colors.white,
        // Let Flutter place the back button and title automatically.
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Price List',
                style: AppTextStyles.headingM
                    .copyWith(color: Colors.white)),
            Text(
              '$resultCount product${resultCount == 1 ? '' : 's'}',
              style: AppTextStyles.labelM
                  .copyWith(color: Colors.white60),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: AppColors.staffPrimary,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: TextField(
              controller: controller,
              onChanged: (_) => onChanged(),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search products…',
                hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5)),
                prefixIcon: Icon(Icons.search,
                    color: Colors.white.withValues(alpha: 0.75),
                    size: 20),
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

  const _CategorySliver({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => SliverPersistentHeader(
        pinned: true,
        delegate: _CategoryDelegate(
          categories: categories,
          selected: selected,
          onSelect: onSelect,
        ),
      );
}

class _CategoryDelegate extends SliverPersistentHeaderDelegate {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelect;

  _CategoryDelegate({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  double get minExtent => 44;
  @override
  double get maxExtent => 44;

  @override
  bool shouldRebuild(_CategoryDelegate old) =>
      old.selected != selected || old.categories.length != categories.length;

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Container(
        color: Colors.white,
        height: 44,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          itemCount: categories.length,
          itemBuilder: (_, i) {
            final cat = categories[i];
            final isSelected = cat == selected;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onSelect(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.staffPrimary
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.staffPrimary
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: AppTextStyles.labelL.copyWith(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
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
  final Future<void> Function() onRefresh;

  const _Body({
    required this.provider,
    required this.products,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading && provider.products.isEmpty) {
      return const Center(
          child:
              CircularProgressIndicator(color: AppColors.staffPrimary));
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
                label: const Text('Retry'),
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.staffPrimary),
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
            Text('No products found',
                style: AppTextStyles.bodyM
                    .copyWith(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.staffPrimary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
        itemCount: products.length,
        itemBuilder: (_, i) => _PriceCard(product: products[i]),
      ),
    );
  }
}

// ── Price card ────────────────────────────────────────────────────────────────

class _PriceCard extends StatelessWidget {
  final Product product;
  const _PriceCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final isOut = product.isOutOfStock;

    // Sort units smallest → largest so retail appears first.
    final sortedUnits = [...product.units]
      ..sort((a, b) => a.quantityInBase.compareTo(b.quantityInBase));

    final priceCells = <Widget>[];
    for (int i = 0; i < sortedUnits.length; i++) {
      if (i > 0) {
        priceCells.add(const VerticalDivider(
            width: 1, thickness: 1, color: AppColors.border));
      }
      final unit = sortedUnits[i];
      final isBase = unit.quantityInBase == 1;
      priceCells.add(Expanded(
        child: _PriceCell(
          icon: isBase ? Icons.sell_outlined : Icons.inventory_2_outlined,
          label: isBase ? unit.name : '${unit.name} ×${unit.quantityInBase}',
          value: 'FCFA ${unit.price.toStringAsFixed(0)}',
          valueColor: isBase ? AppColors.staffPrimary : AppColors.accent,
        ),
      ));
    }
    priceCells.add(const VerticalDivider(
        width: 1, thickness: 1, color: AppColors.border));
    priceCells.add(Expanded(
      child: _PriceCell(
        icon: Icons.layers_outlined,
        label: 'In stock',
        value: '${product.stockQty} ${product.baseUnit}',
        valueColor: product.isOutOfStock
            ? AppColors.danger
            : product.isLowStock
                ? AppColors.warning
                : AppColors.textPrimary,
      ),
    ));

    return Opacity(
      opacity: isOut ? 0.5 : 1.0,
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
            // ── Header ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Row(
                children: [
                  // Colour accent bar
                  Container(
                    width: 4,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isOut
                          ? Colors.grey.shade300
                          : AppColors.staffPrimary,
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
                          product.category,
                          style: AppTextStyles.bodyS.copyWith(
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StockPill(product),
                ],
              ),
            ),

            // Divider
            const Divider(height: 1, color: AppColors.border),

            // ── Price row (all units + stock) ──────────────────────────
            IntrinsicHeight(
              child: Row(children: priceCells),
            ),

            // ── Stock bar ──────────────────────────────────────────────
            if (!isOut)
              _StockBar(product: product),
          ],
        ),
      ),
    );
  }
}

// ── Price cell ────────────────────────────────────────────────────────────────

class _PriceCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _PriceCell({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.labelM
                        .copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.headingS
                  .copyWith(color: valueColor, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
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

    final barColor = product.isLowStock
        ? AppColors.warning
        : AppColors.success;

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
        color: Colors.white,
      ),
      child: ClipRRect(
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(14)),
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
  const _StockPill(this.product);

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color fg;
    final Color bg;

    if (product.isOutOfStock) {
      label = 'Out of Stock';
      fg = AppColors.danger;
      bg = AppColors.dangerLight;
    } else if (product.isLowStock) {
      label = 'Low Stock';
      fg = AppColors.warning;
      bg = AppColors.warningLight;
    } else {
      label = 'Available';
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
