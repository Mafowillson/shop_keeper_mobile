import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/enums/risk_category.dart';
import 'package:shopkeeper/core/widgets/risk_badge.dart';

class CustomerDebtsScreen extends StatefulWidget {
  const CustomerDebtsScreen({super.key});

  @override
  State<CustomerDebtsScreen> createState() => _CustomerDebtsScreenState();
}

class _CustomerDebtsScreenState extends State<CustomerDebtsScreen> {
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> customers = [
    {
      'id': '1',
      'name': 'John Doe',
      'debt': 45000,
      'lastPurchase': '2024-05-08',
      'risk': 'High',
      'phone': '+237 6XX XXX XXX',
      'address': 'Douala, Cameroon',
      'purchases': 12,
      'paymentHistory': [
        {'date': '2024-05-01', 'amount': 10000, 'status': 'Paid'},
        {'date': '2024-04-24', 'amount': 15000, 'status': 'Paid'},
      ]
    },
    {
      'id': '2',
      'name': 'Jane Smith',
      'debt': 22500,
      'lastPurchase': '2024-05-09',
      'risk': 'Medium',
      'phone': '+237 6XX XXX XXX',
      'address': 'Yaounde, Cameroon',
      'purchases': 8,
      'paymentHistory': [
        {'date': '2024-05-05', 'amount': 7500, 'status': 'Paid'},
      ]
    },
    {
      'id': '3',
      'name': 'Mike Johnson',
      'debt': 8500,
      'lastPurchase': '2024-05-10',
      'risk': 'Low',
      'phone': '+237 6XX XXX XXX',
      'address': 'Buea, Cameroon',
      'purchases': 5,
      'paymentHistory': [
        {'date': '2024-05-08', 'amount': 5000, 'status': 'Paid'},
      ]
    },
    {
      'id': '4',
      'name': 'Sarah Williams',
      'debt': 0,
      'lastPurchase': '2024-05-07',
      'risk': 'New',
      'phone': '+237 6XX XXX XXX',
      'address': 'Bamenda, Cameroon',
      'purchases': 2,
      'paymentHistory': []
    },
    {
      'id': '5',
      'name': 'David Brown',
      'debt': 35000,
      'lastPurchase': '2024-05-06',
      'risk': 'High',
      'phone': '+237 6XX XXX XXX',
      'address': 'Kumba, Cameroon',
      'purchases': 15,
      'paymentHistory': [
        {'date': '2024-04-30', 'amount': 20000, 'status': 'Paid'},
      ]
    },
  ];

  List<Map<String, dynamic>> get filteredCustomers {
    if (_selectedFilter == 'All') return customers;
    if (_selectedFilter == 'With Debt') return customers.where((c) => c['debt'] > 0).toList();
    return customers.where((c) => c['risk'] == _selectedFilter).toList();
  }

  double get totalDebt => customers.fold(0, (sum, customer) => sum + customer['debt']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Debts'),
        backgroundColor: AppColors.ownerPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Total Debt Card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.danger, AppColors.danger.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Outstanding Debt',
                    style: AppTextStyles.bodyM.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'FCFA ${totalDebt.toStringAsFixed(0)}',
                    style: AppTextStyles.displayM.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'From ${customers.where((c) => c['debt'] > 0).length} customers',
                    style: AppTextStyles.bodyM.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['All', 'With Debt', 'High', 'Medium', 'Low', 'New'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedFilter = filter);
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: AppColors.ownerPrimary,
                    labelStyle: AppTextStyles.bodyM.copyWith(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Customers List
          Expanded(
            child: filteredCustomers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No customers found',
                          style: AppTextStyles.bodyM.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = filteredCustomers[index];
                      return _buildCustomerCard(context, customer);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, Map<String, dynamic> customer) {
    return GestureDetector(
      onTap: () => context.push('/owner/debts/${customer['id']}'),
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
                        customer['name'],
                        style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        customer['phone'],
                        style: AppTextStyles.bodyM.copyWith(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                RiskBadge(_riskCategoryFromString(customer['risk'] as String?)),
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
                      'Outstanding Debt',
                      style: AppTextStyles.bodyM.copyWith(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'FCFA ${customer['debt']}',
                      style: AppTextStyles.bodyM.copyWith(
                        fontWeight: FontWeight.w600,
                        color: customer['debt'] > 0 ? AppColors.danger : AppColors.success,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Last Purchase',
                      style: AppTextStyles.bodyM.copyWith(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer['lastPurchase'],
                      style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Purchases',
                      style: AppTextStyles.bodyM.copyWith(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${customer['purchases']}',
                      style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
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

  RiskCategory _riskCategoryFromString(String? risk) {
    switch (risk?.toLowerCase()) {
      case 'high':
        return RiskCategory.high;
      case 'medium':
        return RiskCategory.medium;
      case 'low':
        return RiskCategory.low;
      case 'new':
      case 'new customer':
        return RiskCategory.newCustomer;
      default:
        return RiskCategory.newCustomer;
    }
  }
}
