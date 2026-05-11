import 'package:flutter/material.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/widgets/app_text_field.dart';

class PriceListScreen extends StatefulWidget {
  const PriceListScreen({super.key});

  @override
  State<PriceListScreen> createState() => _PriceListScreenState();
}

class _PriceListScreenState extends State<PriceListScreen> {
  late TextEditingController _searchController;
  String _selectedCategory = 'All';

  final List<String> categories = ['All', 'Beverages', 'Snacks', 'Cleaning', 'Dairy'];
  final List<Map<String, dynamic>> products = [
    {
      'name': 'Coca Cola 500ml',
      'category': 'Beverages',
      'price': 1500,
      'stock': 45,
      'minPrice': 1400,
      'maxPrice': 1600
    },
    {
      'name': 'Sprite 500ml',
      'category': 'Beverages',
      'price': 1500,
      'stock': 12,
      'minPrice': 1400,
      'maxPrice': 1600
    },
    {
      'name': 'Fanta Orange 500ml',
      'category': 'Beverages',
      'price': 1500,
      'stock': 3,
      'minPrice': 1400,
      'maxPrice': 1600
    },
    {
      'name': 'Lay\'s Chips 50g',
      'category': 'Snacks',
      'price': 2000,
      'stock': 60,
      'minPrice': 1800,
      'maxPrice': 2200
    },
    {
      'name': 'Doritos 50g',
      'category': 'Snacks',
      'price': 2000,
      'stock': 25,
      'minPrice': 1800,
      'maxPrice': 2200
    },
    {
      'name': 'Dettol Disinfectant 500ml',
      'category': 'Cleaning',
      'price': 3500,
      'stock': 15,
      'minPrice': 3300,
      'maxPrice': 3700
    },
    {
      'name': 'Milk 1L',
      'category': 'Dairy',
      'price': 2500,
      'stock': 8,
      'minPrice': 2400,
      'maxPrice': 2600
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
        title: const Text('Price List'),
        backgroundColor: AppColors.staffPrimary,
        elevation: 0,
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
                    selectedColor: AppColors.staffPrimary,
                    labelStyle: AppTextStyles.bodyM.copyWith(
                      color: isSelected ? Colors.white : Colors.grey[700],
                    ),
                  ),
                );
              }).toList(),
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
                      return _buildProductCard(product);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final stockStatus = product['stock'] > 20
        ? 'In Stock'
        : product['stock'] > 5
            ? 'Low Stock'
            : 'Critical';
    final stockColor = product['stock'] > 20
        ? AppColors.success
        : product['stock'] > 5
            ? AppColors.warning
            : AppColors.danger;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                    Text(
                      product['category'],
                      style: AppTextStyles.bodyM.copyWith(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: stockColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  stockStatus,
                  style: AppTextStyles.bodyM.copyWith(
                    color: stockColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selling Price',
                    style: AppTextStyles.bodyM.copyWith(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'FCFA ${product['price']}',
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.staffPrimary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Stock',
                    style: AppTextStyles.bodyM.copyWith(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product['stock']} units',
                    style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Price Range',
                    style: AppTextStyles.bodyM.copyWith(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'FCFA ${product['minPrice']}-${product['maxPrice']}',
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
