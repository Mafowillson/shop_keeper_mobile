import 'package:flutter/material.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';

class EditProductScreen extends StatelessWidget {
  final String? productId;

  const EditProductScreen({this.productId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(productId == null ? 'Add Product' : 'Edit Product'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.edit, size: 64, color: AppColors.ownerPrimary),
            const SizedBox(height: 16),
            Text('Edit Product Screen', style: AppTextStyles.headingL),
          ],
        ),
      ),
    );
  }
}
