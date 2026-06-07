import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/products/domain/entities/product.dart';
import 'package:shopkeeper/features/products/presentation/providers/product_provider.dart';
import 'package:shopkeeper/features/sales/domain/entities/cart_item.dart';
import 'package:shopkeeper/features/sales/presentation/providers/cart_provider.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';

class NewSaleScreen extends StatefulWidget {
  const NewSaleScreen({super.key});

  @override
  State<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends State<NewSaleScreen> {
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

  void _showCart(CartProvider cart, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CartSheet(
        l10n: l10n,
        onCheckout: () {
          Navigator.pop(context);
          context.push('/staff/sale/payment');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.staffPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(l10n.newSale,
            style: AppTextStyles.headingL.copyWith(color: Colors.white)),
        actions: [
          Consumer<CartProvider>(
            builder: (_, cart, __) => Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: cart.isEmpty ? null : () => _showCart(cart, l10n),
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${cart.itemCount}',
                          style: AppTextStyles.labelS.copyWith(
                              color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            color: AppColors.staffPrimary,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: l10n.searchProductsHint,
                hintStyle:
                    TextStyle(color: Colors.white.withValues(alpha: 0.55)),
                prefixIcon: Icon(Icons.search,
                    color: Colors.white.withValues(alpha: 0.8), size: 20),
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
      ),
      body: Consumer<ProductProvider>(
        builder: (context, pp, _) {
          if (pp.isLoading && pp.products.isEmpty) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.staffPrimary));
          }

          final categories = _categories(pp.products);
          final products = _filtered(pp.products);

          return Column(
            children: [
              _CategoryBar(
                categories: categories,
                selected: _selectedCategory,
                onSelect: (c) => setState(() => _selectedCategory = c),
              ),
              Expanded(
                child: products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 56, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? l10n.noProductsMatchSearch
                                  : l10n.noProductsInCategory,
                              style: AppTextStyles.bodyM
                                  .copyWith(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 120),
                        itemCount: products.length,
                        itemBuilder: (_, i) =>
                            _ProductCard(product: products[i], l10n: l10n),
                      ),
              ),
            ],
          );
        },
      ),
      bottomSheet: Consumer<CartProvider>(
        builder: (_, cart, __) {
          if (cart.isEmpty) return const SizedBox.shrink();
          return _CheckoutBar(
              cart: cart, l10n: l10n, onTap: () => _showCart(cart, l10n));
        },
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelect;

  const _CategoryBar({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        height: 44,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
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

class _ProductCard extends StatelessWidget {
  final Product product;
  final AppLocalizations l10n;
  const _ProductCard({required this.product, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final sortedUnits = [...product.units]
      ..sort((a, b) => a.quantityInBase.compareTo(b.quantityInBase));

    return Consumer<CartProvider>(
      builder: (_, cart, __) {
        final productCartItems =
            cart.items.where((i) => i.product.id == product.id).toList();
        final inCart = productCartItems.isNotEmpty;
        final isOutOfStock = product.isOutOfStock;

        return Opacity(
          opacity: isOutOfStock ? 0.45 : 1.0,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: inCart
                    ? AppColors.staffPrimary.withValues(alpha: 0.45)
                    : AppColors.border,
                width: inCart ? 1.5 : 1,
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
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: AppTextStyles.headingS.copyWith(
                                color: isOutOfStock
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _CategoryPill(product.category),
                                const SizedBox(width: 6),
                                _StockChip(product, l10n: l10n),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(
                      height: 1, thickness: 1, color: AppColors.border),
                  const SizedBox(height: 10),
                  for (int i = 0; i < sortedUnits.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    Builder(builder: (_) {
                      final unit = sortedUnits[i];
                      final isBase = unit.quantityInBase == 1;
                      final color =
                          isBase ? AppColors.staffPrimary : AppColors.accent;
                      final cartItem = productCartItems
                          .where((ci) => ci.unit.name == unit.name)
                          .firstOrNull;
                      final label = isBase
                          ? unit.name
                          : '${unit.name} ×${unit.quantityInBase}';
                      return _PriceRow(
                        label: label,
                        price: unit.price,
                        item: cartItem,
                        disabled: isOutOfStock,
                        accentColor: color,
                        l10n: l10n,
                        onAdd: () => cart.addToCart(product, unit: unit),
                        onInc: () => cartItem != null
                            ? cart.updateQuantity(
                                cartItem.id, cartItem.quantity + 1)
                            : null,
                        onDec: () => cartItem != null
                            ? cart.updateQuantity(
                                cartItem.id, cartItem.quantity - 1)
                            : null,
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double price;
  final CartItem? item;
  final bool disabled;
  final Color accentColor;
  final AppLocalizations l10n;
  final VoidCallback onAdd;
  final VoidCallback? onInc;
  final VoidCallback? onDec;

  const _PriceRow({
    required this.label,
    required this.price,
    required this.item,
    required this.disabled,
    required this.accentColor,
    required this.l10n,
    required this.onAdd,
    required this.onInc,
    required this.onDec,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.labelL
                        .copyWith(color: AppColors.textSecondary)),
                Text(
                  '${l10n.fcfa} ${price.toStringAsFixed(0)}',
                  style: AppTextStyles.headingS
                      .copyWith(color: accentColor, fontSize: 15),
                ),
              ],
            ),
          ),
          if (item == null)
            GestureDetector(
              onTap: disabled ? null : onAdd,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: disabled
                      ? Colors.grey.shade100
                      : accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: disabled ? Colors.grey.shade300 : accentColor,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add,
                        size: 16, color: disabled ? Colors.grey : accentColor),
                    const SizedBox(width: 4),
                    Text(l10n.add,
                        style: AppTextStyles.labelL.copyWith(
                          color: disabled ? Colors.grey : accentColor,
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
              ),
            )
          else
            Row(
              children: [
                _QtyBtn(
                  icon:
                      item!.quantity == 1 ? Icons.delete_outline : Icons.remove,
                  color: item!.quantity == 1 ? AppColors.danger : accentColor,
                  onTap: onDec ?? () {},
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    '${item!.quantity}',
                    style: AppTextStyles.headingS,
                    textAlign: TextAlign.center,
                  ),
                ),
                _QtyBtn(
                    icon: Icons.add, color: accentColor, onTap: onInc ?? () {}),
              ],
            ),
        ],
      );
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      );
}

class _CategoryPill extends StatelessWidget {
  final String category;
  const _CategoryPill(this.category);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.accentLight,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(category,
            style: AppTextStyles.labelS.copyWith(color: AppColors.accent)),
      );
}

class _StockChip extends StatelessWidget {
  final Product product;
  final AppLocalizations l10n;
  const _StockChip(this.product, {required this.l10n});

  @override
  Widget build(BuildContext context) {
    if (product.isOutOfStock) {
      return _pill(l10n.outOfStock, AppColors.danger, AppColors.dangerLight);
    }
    if (product.isLowStock) {
      return _pill(l10n.lowStockLabel(product.stockQty), AppColors.warning,
          AppColors.warningLight);
    }
    return _pill(l10n.inStock, AppColors.success, AppColors.successLight);
  }

  Widget _pill(String label, Color fg, Color bg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
        child: Text(label,
            style: AppTextStyles.labelS
                .copyWith(color: fg, fontWeight: FontWeight.w600)),
      );
}

class _CheckoutBar extends StatelessWidget {
  final CartProvider cart;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  const _CheckoutBar(
      {required this.cart, required this.l10n, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.fromLTRB(
              16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: AppColors.staffPrimary,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('${cart.itemCount}',
                      style: AppTextStyles.labelL.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 10),
              Text('${cart.itemCount} item${cart.itemCount == 1 ? '' : 's'}',
                  style: AppTextStyles.bodyM.copyWith(color: Colors.white70)),
              const Spacer(),
              Text('${l10n.fcfa} ${cart.total.toStringAsFixed(0)}',
                  style: AppTextStyles.headingM.copyWith(color: Colors.white)),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Text(l10n.checkout,
                        style: AppTextStyles.labelL.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward,
                        color: Colors.white, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _CartSheet extends StatelessWidget {
  final VoidCallback onCheckout;
  final AppLocalizations l10n;
  const _CartSheet({required this.onCheckout, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (_, cart, __) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Text(l10n.cart, style: AppTextStyles.headingL),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: cart.isEmpty ? null : cart.clear,
                    icon: const Icon(Icons.delete_outline,
                        size: 16, color: AppColors.danger),
                    label: Text(l10n.clearAll,
                        style: AppTextStyles.bodyM
                            .copyWith(color: AppColors.danger)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: cart.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.shopping_cart_outlined,
                              size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 10),
                          Text(l10n.cartIsEmpty,
                              style: AppTextStyles.bodyM
                                  .copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: cart.items.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (_, i) =>
                          _CartLineItem(item: cart.items[i], l10n: l10n),
                    ),
            ),
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  16, 14, 16, 14 + MediaQuery.of(context).padding.bottom),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.total, style: AppTextStyles.headingM),
                      Text('${l10n.fcfa} ${cart.total.toStringAsFixed(0)}',
                          style: AppTextStyles.headingM
                              .copyWith(color: AppColors.staffPrimary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: cart.isEmpty ? null : onCheckout,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.staffPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(l10n.proceedToPayment,
                          style: AppTextStyles.headingS
                              .copyWith(color: Colors.white)),
                    ),
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

class _CartLineItem extends StatelessWidget {
  final CartItem item;
  final AppLocalizations l10n;
  const _CartLineItem({required this.item, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final isBase = item.unit.quantityInBase == 1;
    final color = isBase ? AppColors.staffPrimary : AppColors.accent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name,
                    style: AppTextStyles.bodyM
                        .copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.unit.quantityInBase == 1
                            ? item.unit.name
                            : '${item.unit.name} ×${item.unit.quantityInBase}',
                        style: AppTextStyles.labelS.copyWith(
                            color: color, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${l10n.fcfa} ${item.unitPrice.toStringAsFixed(0)} each',
                      style: AppTextStyles.bodyS,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Row(
            children: [
              _SmallQtyBtn(
                icon: item.quantity == 1 ? Icons.delete_outline : Icons.remove,
                color: item.quantity == 1 ? AppColors.danger : color,
                onTap: () => cart.updateQuantity(item.id, item.quantity - 1),
              ),
              SizedBox(
                width: 32,
                child: Text('${item.quantity}',
                    style: AppTextStyles.headingS, textAlign: TextAlign.center),
              ),
              _SmallQtyBtn(
                icon: Icons.add,
                color: color,
                onTap: () => cart.updateQuantity(item.id, item.quantity + 1),
              ),
            ],
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 68,
            child: Text(
              '${l10n.fcfa}\n${item.subtotal.toStringAsFixed(0)}',
              style: AppTextStyles.bodyM
                  .copyWith(fontWeight: FontWeight.w600, color: color),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallQtyBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SmallQtyBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
      );
}
