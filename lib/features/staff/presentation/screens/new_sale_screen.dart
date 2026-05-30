import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/widgets/app_button.dart';

class NewSaleScreen extends StatefulWidget {
  const NewSaleScreen({super.key});

  @override
  State<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends State<NewSaleScreen> {
  late TextEditingController _searchController;

  final List<Map<String, dynamic>> availableProducts = [
    {'id': '1', 'name': 'Coca Cola 500ml', 'price': 1500, 'stock': 45},
    {'id': '2', 'name': 'Sprite 500ml', 'price': 1500, 'stock': 12},
    {'id': '3', 'name': 'Fanta Orange 500ml', 'price': 1500, 'stock': 3},
    {'id': '4', 'name': 'Lay\'s Chips 50g', 'price': 2000, 'stock': 60},
    {'id': '5', 'name': 'Doritos 50g', 'price': 2000, 'stock': 25},
    {
      'id': '6',
      'name': 'Dettol Disinfectant 500ml',
      'price': 3500,
      'stock': 15
    },
    {'id': '7', 'name': 'Milk 1L', 'price': 2500, 'stock': 8},
  ];

  List<Map<String, dynamic>> cart = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredProducts {
    return availableProducts
        .where((p) => p['name']
            .toLowerCase()
            .contains(_searchController.text.toLowerCase()))
        .toList();
  }

  double get cartTotal =>
      cart.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));

  void _addToCart(Map<String, dynamic> product) {
    final existingItem = cart.firstWhere(
      (item) => item['id'] == product['id'],
      orElse: () => {},
    );

    if (existingItem.isNotEmpty) {
      setState(() {
        existingItem['quantity']++;
      });
    } else {
      setState(() {
        cart.add({
          'id': product['id'],
          'name': product['name'],
          'price': product['price'],
          'quantity': 1,
        });
      });
    }
  }

  void _removeFromCart(String productId) {
    setState(() {
      cart.removeWhere((item) => item['id'] == productId);
    });
  }

  void _updateQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      _removeFromCart(productId);
    } else {
      setState(() {
        final item = cart.firstWhere((item) => item['id'] == productId);
        item['quantity'] = newQuantity;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Sale'),
        backgroundColor: AppColors.staffPrimary,
        elevation: 0,
      ),
      body: Row(
        children: [
          // Products List
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return GestureDetector(
                        onTap: () => _addToCart(product),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'],
                                style: AppTextStyles.bodyM
                                    .copyWith(fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'FCFA ${product['price']}',
                                      style: AppTextStyles.bodyM.copyWith(
                                        color: AppColors.staffPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      'Stock: ${product['stock']}',
                                      style: AppTextStyles.bodyM.copyWith(
                                        color: Colors.grey[600],
                                        fontSize: 11,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Cart Summary
          Container(
            width: 300,
            color: Colors.grey[50],
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.staffPrimary,
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(8)),
                  ),
                  child: Text(
                    'Cart (${cart.length} items)',
                    style: AppTextStyles.headingM.copyWith(color: Colors.white),
                  ),
                ),
                Expanded(
                  child: cart.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_cart_outlined,
                                  size: 48, color: Colors.grey[300]),
                              const SizedBox(height: 12),
                              Text(
                                'Cart is empty',
                                style: AppTextStyles.bodyM
                                    .copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: cart.length,
                          itemBuilder: (context, index) {
                            final item = cart[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'],
                                    style: AppTextStyles.bodyM
                                        .copyWith(fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'FCFA ${item['price']}',
                                        style: AppTextStyles.bodyM
                                            .copyWith(fontSize: 12),
                                      ),
                                      Text(
                                        'FCFA ${item['price'] * item['quantity']}',
                                        style: AppTextStyles.bodyM.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.staffPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        iconSize: 18,
                                        padding: EdgeInsets.zero,
                                        onPressed: () => _updateQuantity(
                                            item['id'], item['quantity'] - 1),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            '${item['quantity']}',
                                            style: AppTextStyles.bodyM.copyWith(
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        iconSize: 18,
                                        padding: EdgeInsets.zero,
                                        onPressed: () => _updateQuantity(
                                            item['id'], item['quantity'] + 1),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        iconSize: 18,
                                        padding: EdgeInsets.zero,
                                        color: Colors.red,
                                        onPressed: () =>
                                            _removeFromCart(item['id']),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal:', style: AppTextStyles.bodyM),
                          Text('FCFA ${cartTotal.toStringAsFixed(0)}',
                              style: AppTextStyles.bodyM
                                  .copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total:', style: AppTextStyles.headingM),
                          Text('FCFA ${cartTotal.toStringAsFixed(0)}',
                              style: AppTextStyles.headingM.copyWith(
                                  color: AppColors.staffPrimary,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AppButton.primary(
                        label: 'Proceed to Payment',
                        onPressed: () => cart.isEmpty
                            ? null
                            : () => context.push('/staff/sale/payment'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
