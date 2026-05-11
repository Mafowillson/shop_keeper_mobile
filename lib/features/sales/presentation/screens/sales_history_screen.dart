import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  String _selectedFilter = 'All';
  String _selectedSort = 'Recent';

  final List<Map<String, dynamic>> sales = [
    {
      'id': '1',
      'date': '2024-05-10 14:30',
      'amount': 15500,
      'items': 3,
      'type': 'Cash',
      'customer': 'Walk-in',
      'status': 'Completed'
    },
    {
      'id': '2',
      'date': '2024-05-10 13:15',
      'amount': 8750,
      'items': 2,
      'type': 'Credit',
      'customer': 'John Doe',
      'status': 'Pending'
    },
    {
      'id': '3',
      'date': '2024-05-10 11:45',
      'amount': 22300,
      'items': 5,
      'type': 'Cash',
      'customer': 'Walk-in',
      'status': 'Completed'
    },
    {
      'id': '4',
      'date': '2024-05-09 16:20',
      'amount': 5600,
      'items': 1,
      'type': 'Cash',
      'customer': 'Walk-in',
      'status': 'Completed'
    },
    {
      'id': '5',
      'date': '2024-05-09 14:00',
      'amount': 18900,
      'items': 4,
      'type': 'Credit',
      'customer': 'Jane Smith',
      'status': 'Pending'
    },
    {
      'id': '6',
      'date': '2024-05-09 10:30',
      'amount': 12450,
      'items': 3,
      'type': 'Cash',
      'customer': 'Walk-in',
      'status': 'Completed'
    },
  ];

  List<Map<String, dynamic>> get filteredSales {
    var filtered = sales;

    if (_selectedFilter != 'All') {
      filtered = filtered.where((sale) => sale['type'] == _selectedFilter).toList();
    }

    if (_selectedSort == 'Recent') {
      filtered.sort((a, b) => b['date'].compareTo(a['date']));
    } else if (_selectedSort == 'Highest') {
      filtered.sort((a, b) => b['amount'].compareTo(a['amount']));
    } else if (_selectedSort == 'Lowest') {
      filtered.sort((a, b) => a['amount'].compareTo(b['amount']));
    }

    return filtered;
  }

  double get totalSales => sales.fold(0, (sum, sale) => sum + sale['amount']);
  double get averageSale => totalSales / sales.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales History'),
        backgroundColor: AppColors.ownerPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Summary Cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    label: 'Total Sales',
                    value: 'FCFA ${totalSales.toStringAsFixed(0)}',
                    icon: Icons.trending_up,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    label: 'Average',
                    value: 'FCFA ${averageSale.toStringAsFixed(0)}',
                    icon: Icons.bar_chart,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterChip('Cash', 'Cash'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterChip('Credit', 'Credit'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterChip('All', 'All'),
                ),
              ],
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
                  '${filteredSales.length} transactions',
                  style: AppTextStyles.bodyM.copyWith(color: Colors.grey[600]),
                ),
                DropdownButton<String>(
                  value: _selectedSort,
                  underline: const SizedBox(),
                  items: ['Recent', 'Highest', 'Lowest'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedSort = value ?? 'Recent');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Sales List
          Expanded(
            child: filteredSales.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No sales found',
                          style: AppTextStyles.bodyM.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredSales.length,
                    itemBuilder: (context, index) {
                      final sale = filteredSales[index];
                      return _buildSaleCard(context, sale);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodyM.copyWith(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyM.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedFilter = value);
      },
      backgroundColor: Colors.grey[200],
      selectedColor: AppColors.ownerPrimary,
      labelStyle: AppTextStyles.bodyM.copyWith(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontSize: 12,
      ),
    );
  }

  Widget _buildSaleCard(BuildContext context, Map<String, dynamic> sale) {
    return GestureDetector(
      onTap: () => context.push('/owner/sales/${sale['id']}'),
      child: Container(
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
                        'Sale #${sale['id']}',
                        style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sale['date'],
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
                    color: sale['type'] == 'Cash'
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    sale['type'],
                    style: AppTextStyles.bodyM.copyWith(
                      color: sale['type'] == 'Cash' ? AppColors.success : AppColors.warning,
                      fontSize: 12,
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
                      'Amount',
                      style: AppTextStyles.bodyM.copyWith(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'FCFA ${sale['amount']}',
                      style: AppTextStyles.bodyM.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.ownerPrimary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Items',
                      style: AppTextStyles.bodyM.copyWith(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${sale['items']} items',
                      style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Status',
                      style: AppTextStyles.bodyM.copyWith(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: sale['status'] == 'Completed'
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        sale['status'],
                        style: AppTextStyles.bodyM.copyWith(
                          color: sale['status'] == 'Completed'
                              ? AppColors.success
                              : AppColors.warning,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
