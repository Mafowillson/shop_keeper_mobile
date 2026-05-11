import 'package:flutter/material.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/enums/risk_category.dart';
import 'package:shopkeeper/core/widgets/app_button.dart';
import 'package:shopkeeper/core/widgets/risk_badge.dart';

class CustomerDetailScreen extends StatefulWidget {
  final String customerId;

  const CustomerDetailScreen({required this.customerId, super.key});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  late TextEditingController _paymentController;

  // Mock customer data
  final Map<String, dynamic> customerData = {
    'id': '1',
    'name': 'John Doe',
    'phone': '+237 6XX XXX XXX',
    'email': 'john@example.com',
    'address': 'Douala, Cameroon',
    'debt': 45000,
    'risk': 'High',
    'totalPurchases': 12,
    'totalSpent': 125000,
    'joinDate': '2023-06-15',
    'lastPurchase': '2024-05-08',
    'paymentHistory': [
      {'date': '2024-05-01', 'amount': 10000, 'status': 'Paid', 'method': 'Cash'},
      {'date': '2024-04-24', 'amount': 15000, 'status': 'Paid', 'method': 'Cash'},
      {'date': '2024-04-10', 'amount': 8000, 'status': 'Paid', 'method': 'Cash'},
      {'date': '2024-03-28', 'amount': 12000, 'status': 'Paid', 'method': 'Cash'},
    ],
    'purchases': [
      {'date': '2024-05-08', 'items': 3, 'amount': 8500, 'status': 'Completed'},
      {'date': '2024-05-01', 'items': 2, 'amount': 5200, 'status': 'Completed'},
      {'date': '2024-04-24', 'items': 4, 'amount': 12300, 'status': 'Completed'},
    ]
  };

  @override
  void initState() {
    super.initState();
    _paymentController = TextEditingController();
  }

  @override
  void dispose() {
    _paymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(customerData['name']),
        backgroundColor: AppColors.ownerPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Header
            _buildCustomerHeader(),
            const SizedBox(height: 24),

            // Key Stats
            _buildKeyStats(),
            const SizedBox(height: 24),

            // Contact Information
            _buildContactInfo(),
            const SizedBox(height: 24),

            // Record Payment Section
            _buildPaymentSection(),
            const SizedBox(height: 24),

            // Payment History
            Text(
              'Payment History',
              style: AppTextStyles.headingM,
            ),
            const SizedBox(height: 12),
            _buildPaymentHistory(),
            const SizedBox(height: 24),

            // Recent Purchases
            Text(
              'Recent Purchases',
              style: AppTextStyles.headingM,
            ),
            const SizedBox(height: 12),
            _buildPurchaseHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.ownerPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.ownerPrimary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                customerData['name'][0],
                style: AppTextStyles.displayM.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerData['name'],
                  style: AppTextStyles.headingL,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    RiskBadge(_riskCategoryFromString(customerData['risk'] as String)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Member since ${customerData['joinDate']}',
                        style: AppTextStyles.bodyM.copyWith(
                          color: AppColors.success,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'Outstanding Debt',
            value: 'FCFA ${customerData['debt']}',
            color: AppColors.danger,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: 'Total Spent',
            value: 'FCFA ${customerData['totalSpent']}',
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
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
          Text(
            label,
            style: AppTextStyles.bodyM.copyWith(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.bodyM.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: AppTextStyles.headingM,
          ),
          const SizedBox(height: 16),
          _buildContactRow('Phone', customerData['phone']),
          const SizedBox(height: 12),
          _buildContactRow('Email', customerData['email']),
          const SizedBox(height: 12),
          _buildContactRow('Address', customerData['address']),
          const SizedBox(height: 12),
          _buildContactRow('Last Purchase', customerData['lastPurchase']),
          const SizedBox(height: 12),
          _buildContactRow('Total Purchases', '${customerData['totalPurchases']} transactions'),
        ],
      ),
    );
  }

  Widget _buildContactRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyM.copyWith(color: Colors.grey[600]),
        ),
        Text(
          value,
          style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Record Payment',
            style: AppTextStyles.headingM,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _paymentController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter payment amount',
              prefixText: 'FCFA ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          AppButton.primary(
            label: 'Record Payment',
            onPressed: () {
              if (_paymentController.text.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Payment of FCFA ${_paymentController.text} recorded successfully',
                    ),
                  ),
                );
                _paymentController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistory() {
    return Column(
      children: (customerData['paymentHistory'] as List).map((payment) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment['date'],
                    style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Via ${payment['method']}',
                    style: AppTextStyles.bodyM.copyWith(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'FCFA ${payment['amount']}',
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      payment['status'],
                      style: AppTextStyles.bodyM.copyWith(
                        color: AppColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPurchaseHistory() {
    return Column(
      children: (customerData['purchases'] as List).map((purchase) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Purchase on ${purchase['date']}',
                    style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${purchase['items']} items',
                    style: AppTextStyles.bodyM.copyWith(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'FCFA ${purchase['amount']}',
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.ownerPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      purchase['status'],
                      style: AppTextStyles.bodyM.copyWith(
                        color: AppColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
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


