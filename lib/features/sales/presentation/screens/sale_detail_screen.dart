import 'package:flutter/material.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';

class SaleDetailScreen extends StatelessWidget {
  final String saleId;

  const SaleDetailScreen({required this.saleId, super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for the sale
    final saleData = {
      'id': saleId,
      'date': '2024-05-10 14:30',
      'time': '2:30 PM',
      'type': 'Cash',
      'customer': 'Walk-in Customer',
      'status': 'Completed',
      'items': [
        {'name': 'Coca Cola 500ml', 'qty': 2, 'price': 1500, 'total': 3000},
        {'name': 'Lay\'s Chips 50g', 'qty': 3, 'price': 2000, 'total': 6000},
        {'name': 'Dettol Disinfectant 500ml', 'qty': 1, 'price': 3500, 'total': 3500},
      ],
      'subtotal': 12500,
      'tax': 1250,
      'discount': 1250,
      'total': 12500,
      'paymentMethod': 'Cash',
      'notes': 'Regular customer'
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('Sale #${saleData['id']}'),
        backgroundColor: AppColors.ownerPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sale Header
            _buildSaleHeader(saleData),
            const SizedBox(height: 24),

            // Items Section
            Text(
              'Items',
              style: AppTextStyles.headingM,
            ),
            const SizedBox(height: 12),
            _buildItemsList(saleData['items'] as List<dynamic>),
            const SizedBox(height: 24),

            // Summary Section
            _buildSummarySection(saleData),
            const SizedBox(height: 24),

            // Payment Info
            _buildPaymentInfo(saleData),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Receipt printed')),
                      );
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('Print'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Receipt shared')),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ownerPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleHeader(Map<String, dynamic> sale) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.ownerPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.ownerPrimary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sale['date'],
                    style: AppTextStyles.bodyM.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sale['customer'],
                    style: AppTextStyles.headingM,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  sale['status'],
                  style: AppTextStyles.bodyM.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildHeaderInfo('Type', sale['type']),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHeaderInfo('Payment', sale['paymentMethod']),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyM.copyWith(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildItemsList(List<dynamic> items) {
    return Column(
      children: items.asMap().entries.map((entry) {
        final item = entry.value;
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'],
                      style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Qty: ${item['qty']} × FCFA ${item['price']}',
                      style: AppTextStyles.bodyM.copyWith(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'FCFA ${item['total']}',
                style: AppTextStyles.bodyM.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.ownerPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummarySection(Map<String, dynamic> sale) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', 'FCFA ${sale['subtotal']}'),
          const SizedBox(height: 12),
          _buildSummaryRow('Tax', 'FCFA ${sale['tax']}', color: AppColors.warning),
          const SizedBox(height: 12),
          _buildSummaryRow('Discount', '-FCFA ${sale['discount']}', color: AppColors.success),
          const Divider(height: 24),
          _buildSummaryRow(
            'Total',
            'FCFA ${sale['total']}',
            isBold: true,
            color: AppColors.ownerPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyM.copyWith(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyM.copyWith(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: color ?? Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentInfo(Map<String, dynamic> sale) {
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
            'Additional Information',
            style: AppTextStyles.headingM,
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Payment Method', sale['paymentMethod']),
          const SizedBox(height: 12),
          _buildInfoRow('Notes', sale['notes']),
          const SizedBox(height: 12),
          _buildInfoRow('Transaction ID', 'TXN-${sale['id']}-2024'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
}
