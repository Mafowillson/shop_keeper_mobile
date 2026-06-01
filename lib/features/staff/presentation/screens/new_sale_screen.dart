import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/enums/price_type.dart';
import 'package:shopkeeper/core/widgets/app_button.dart';
import 'package:shopkeeper/core/widgets/stock_badge.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/products/domain/entities/product.dart';
import 'package:shopkeeper/features/products/presentation/providers/product_provider.dart';
import 'package:shopkeeper/features/sales/domain/entities/cart_item.dart';
import 'package:shopkeeper/features/sales/presentation/providers/cart_provider.dart';

class NewSaleScreen extends StatefulWidget {
  const NewSaleScreen({super.key});

  @override
  State<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends State<NewSaleScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load products if not already loaded.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shopId =
          context.read<AuthProvider>().currentUser?.shopId ?? '';
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
    final q = _searchController.text.toLowerCase();
    if (q.isEmpty) return all;
    return all.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('New Sale',
            style: AppTextStyles.headingL.copyWith(color: Colors.white)),
        backgroundColor: AppColors.staffPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Row(
        children: [
          // ── Product catalog (left) ───────────────────────────────────
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // Search
                Container(
                  color: AppColors.staffPrimary,
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search…',
                      hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6)),
                      prefixIcon: Icon(Icons.search,
                          color: Colors.white.withValues(alpha: 0.8)),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.15),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                // Product list
                Expanded(
                  child: Consumer<ProductProvider>(
                    builder: (_, pp, __) {
                      if (pp.isLoading && pp.products.isEmpty) {
                        return const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.staffPrimary));
                      }
                      final products = _filtered(pp.products);
                      if (products.isEmpty) {
                        return Center(
                          child: Text('No products',
                              style: AppTextStyles.bodyM
                                  .copyWith(color: AppColors.textSecondary)),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: products.length,
                        itemBuilder: (_, i) =>
                            _ProductTile(product: products[i]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Cart panel (right) ───────────────────────────────────────
          const _CartPanel(),
        ],
      ),
    );
  }
}

// ── Product tile ──────────────────────────────────────────────────────────────

class _ProductTile extends StatelessWidget {
  final Product product;

  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style:
                AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  'FCFA ${product.retailPrice.toStringAsFixed(0)}',
                  style: AppTextStyles.bodyS
                      .copyWith(color: AppColors.staffPrimary),
                ),
              ),
              StockBadge(
                stockQty: product.stockQty,
                lowStockThreshold: product.lowStockThreshold,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _AddBtn(
                label: 'Retail',
                onTap: () => context
                    .read<CartProvider>()
                    .addToCart(product, priceType: PriceType.retail),
              ),
              if (product.cartonQty > 1) ...[
                const SizedBox(width: 6),
                _AddBtn(
                  label: 'Carton',
                  color: AppColors.accent,
                  onTap: () => context
                      .read<CartProvider>()
                      .addToCart(product, priceType: PriceType.carton),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AddBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AddBtn({
    required this.label,
    this.color = AppColors.staffPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 14, color: color),
            const SizedBox(width: 3),
            Text(label,
                style:
                    AppTextStyles.labelL.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

// ── Cart panel ────────────────────────────────────────────────────────────────

class _CartPanel extends StatelessWidget {
  const _CartPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      color: Colors.grey[50],
      child: Consumer<CartProvider>(
        builder: (_, cart, __) => Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              color: AppColors.staffPrimary,
              child: Text(
                'Cart  •  ${cart.itemCount} item${cart.itemCount == 1 ? '' : 's'}',
                style:
                    AppTextStyles.headingM.copyWith(color: Colors.white),
              ),
            ),

            // Items
            Expanded(
              child: cart.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_outlined,
                              size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 10),
                          Text('Cart is empty',
                              style: AppTextStyles.bodyM.copyWith(
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: cart.items.length,
                      itemBuilder: (_, i) =>
                          _CartItemTile(item: cart.items[i]),
                    ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                    top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: AppTextStyles.headingM),
                      Text(
                        'FCFA ${cart.total.toStringAsFixed(0)}',
                        style: AppTextStyles.headingM.copyWith(
                            color: AppColors.staffPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AppButton.primary(
                    label: 'Proceed to Payment',
                    onPressed: cart.isEmpty
                        ? null
                        : () => context.push('/staff/sale/payment'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: AppTextStyles.bodyM
                          .copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${item.priceType == PriceType.retail ? 'Retail' : 'Carton'}  •  FCFA ${item.unitPrice.toStringAsFixed(0)}',
                      style: AppTextStyles.bodyS,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close,
                    size: 16, color: AppColors.danger),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => cart.removeItem(item.id),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _QtyBtn(
                icon: Icons.remove,
                onTap: () => cart.updateQuantity(
                    item.id, item.quantity - 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text('${item.quantity}',
                    style: AppTextStyles.bodyM
                        .copyWith(fontWeight: FontWeight.w700)),
              ),
              _QtyBtn(
                icon: Icons.add,
                onTap: () => cart.updateQuantity(
                    item.id, item.quantity + 1),
              ),
              const Spacer(),
              Text(
                'FCFA ${item.subtotal.toStringAsFixed(0)}',
                style: AppTextStyles.bodyM.copyWith(
                    color: AppColors.staffPrimary,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.staffPrimary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: AppColors.staffPrimary),
      ),
    );
  }
}
