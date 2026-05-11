import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/widgets/app_text_field.dart';
import 'package:shopkeeper/core/widgets/stock_badge.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late TextEditingController _searchController;
  String _selectedCategory = 'All';
  String _sortBy = 'Name';

  final List<String> categories = ['All', 'Beverages', 'Snacks', 'Cleaning', 'Dairy'];
  final List<Map<String, dynamic>> products = [
    {
      'id': '1',
      'name': 'Coca Cola 500ml',
      'category': 'Beverages',
      'price': 1500,
      'stock': 45,
      'minStock': 20,
      'risk': 'Low'
    },
    {
      'id': '2',
      'name': 'Sprite 500ml',
      'category': 'Beverages',
      'price': 1500,
      'stock': 12,
      'minStock': 20,
      'risk': 'Medium'
    },
    {
      'id': '3',
      'name': 'Fanta Orange 500ml',
      'category': 'Beverages',
      'price': 1500,
      'stock': 3,
      'minStock': 20,
      'risk': 'High'
    },
    {
      'id': '4',
      'name': 'Lay\'s Chips 50g',
      'category': 'Snacks',
      'price': 2000,
      'stock': 60,
      'minStock': 30,
      'risk': 'Low'
    },
    {
      'id': '5',
      'name': 'Doritos 50g',
      'category': 'Snacks',
      'price': 2000,
      'stock': 25,
      'minStock': 30,
      'risk': 'Medium'
    },
    {
      'id': '6',
      'name': 'Dettol Disinfectant 500ml',
      'category': 'Cleaning',
      'price': 3500,
      'stock': 15,
      'minStock': 10,
      'risk': 'Low'
    },
    {
      'id': '7',
      'name': 'Milk 1L',
      'category': 'Dairy',
      'price': 2500,
      'stock': 8,
      'minStock': 15,
      'risk': 'High'
    },
  ];

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
    return products.where((product) {
      final matchesSearch =
          product['name'].toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'All' || product['category'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: AppColors.ownerPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/owner/products/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppTextField(
              label: 'Search products...',
              controller: _searchController,
              prefixIcon: const Icon(Icons.search),
              onChanged: (_) => setState(() {}),
            ),
          ),

          // Category Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = category);
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: AppColors.ownerPrimary,
                    labelStyle: AppTextStyles.bodyM.copyWith(
                      color: isSelected ? Colors.white : Colors.grey[700],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Sort Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredProducts.length} products',
                  style: AppTextStyles.bodyM.copyWith(color: Colors.grey[600]),
                ),
                DropdownButton<String>(
                  value: _sortBy,
                  underline: const SizedBox(),
                  items: ['Name', 'Price', 'Stock'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _sortBy = value ?? 'Name');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Products List
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: AppTextStyles.bodyM.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _buildProductCard(context, product);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () => context.push('/owner/products/${product['id']}/edit'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            // Product Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shopping_bag, color: AppColors.accent),
            ),
            const SizedBox(width: 12),

            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'FCFA ${product['price']}',
                        style: AppTextStyles.bodyM.copyWith(
                          color: AppColors.ownerPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      StockBadge(
                        stockQty: product['stock'],
                        lowStockThreshold: product['minStock'],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action Buttons
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Text('Edit'),
                  onTap: () => context.push('/owner/products/${product['id']}/edit'),
                ),
                PopupMenuItem(
                  child: const Text('Delete'),
                  onTap: () => _showDeleteDialog(context, product['name']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "$productName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$productName deleted successfully')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
