import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/widgets/snack_bar_helper.dart';
import 'package:shopkeeper/core/widgets/stock_badge.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/products/domain/entities/product.dart';
import 'package:shopkeeper/features/products/presentation/providers/product_provider.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';

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
      appBar: AppBar(
        title: Text(l10n.products,
            style: AppTextStyles.headingL.copyWith(color: Colors.white)),
        backgroundColor: AppColors.ownerPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.addProductTooltip,
            onPressed: () async {
              await context.push('/owner/products/add');
              if (mounted) _load(category: _selectedCategory);
            },
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          final categories = ['All', ...provider.categories];
          final products = provider.products;

          return Column(
            children: [
              // ── Search bar ─────────────────────────────────────────────
              Container(
                color: AppColors.ownerPrimary,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: l10n.searchProductsHint,
                    hintStyle:
                        TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                    prefixIcon: Icon(Icons.search,
                        color: Colors.white.withValues(alpha: 0.8)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white),
                            onPressed: () {
                              _searchController.clear();
                              _load(category: _selectedCategory);
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.15),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // ── Category chips ─────────────────────────────────────────
              if (categories.length > 1)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: categories.map((cat) {
                        final selected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: selected,
                            onSelected: (_) => _onCategoryChanged(cat),
                            selectedColor: AppColors.ownerPrimary,
                            labelStyle: AppTextStyles.bodyM.copyWith(
                              color: selected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight:
                                  selected ? FontWeight.w600 : FontWeight.w400,
                            ),
                            backgroundColor: AppColors.background,
                            side: BorderSide(
                              color: selected
                                  ? AppColors.ownerPrimary
                                  : AppColors.border,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

              // ── Count bar ──────────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Text(
                      provider.isLoading
                          ? l10n.loadingEllipsis
                          : '${products.length} ${l10n.products.toLowerCase()}',
                      style: AppTextStyles.bodyM
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    if (provider.isLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.ownerPrimary,
                        ),
                      ),
                  ],
                ),
              ),

              // ── Error banner ───────────────────────────────────────────
              if (provider.errorMessage != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.dangerLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.danger.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.danger, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(provider.errorMessage!,
                            style: AppTextStyles.bodyS
                                .copyWith(color: AppColors.danger)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh,
                            color: AppColors.danger, size: 18),
                        onPressed: () => _load(category: _selectedCategory),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

              // ── Product list ───────────────────────────────────────────
              Expanded(
                child: provider.isLoading && products.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.ownerPrimary))
                    : products.isEmpty
                        ? _EmptyState(
                            hasSearch: _searchController.text.isNotEmpty,
                            onAdd: () async {
                              await context.push('/owner/products/add');
                              if (mounted) {
                                _load(category: _selectedCategory);
                              }
                            },
                            l10n: l10n,
                          )
                        : RefreshIndicator(
                            color: AppColors.ownerPrimary,
                            onRefresh: () => _load(category: _selectedCategory),
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                              itemCount: products.length,
                              itemBuilder: (ctx, i) => _ProductCard(
                                product: products[i],
                                l10n: l10n,
                                onEdit: () async {
                                  await context.push(
                                      '/owner/products/${products[i].id}/edit');
                                  if (mounted) {
                                    _load(category: _selectedCategory);
                                  }
                                },
                                onDeactivate: () =>
                                    _confirmDeactivate(context, products[i]),
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

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDeactivate;
  final AppLocalizations l10n;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDeactivate,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '${l10n.fcfa} ${product.retailPrice.toStringAsFixed(0)}',
                          style: AppTextStyles.bodyM.copyWith(
                            color: AppColors.ownerPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        StockBadge(
                          stockQty: product.stockQty,
                          lowStockThreshold: product.lowStockThreshold,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'remove') onDeactivate();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      const Icon(Icons.edit_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(l10n.edit, style: AppTextStyles.bodyM),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(children: [
                      const Icon(Icons.delete_outline,
                          size: 18, color: AppColors.danger),
                      const SizedBox(width: 8),
                      Text(l10n.remove,
                          style: AppTextStyles.bodyM
                              .copyWith(color: AppColors.danger)),
                    ]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
            Icon(Icons.inventory_2_outlined, size: 72, color: Colors.grey[300]),
            const SizedBox(height: 16),
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
              TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: Text(l10n.addProduct),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.ownerPrimary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
