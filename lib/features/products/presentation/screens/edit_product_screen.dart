import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_strings.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/widgets/app_button.dart';
import 'package:shopkeeper/core/widgets/app_text_field.dart';
import 'package:shopkeeper/di/injection.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/products/domain/entities/product.dart';
import 'package:shopkeeper/features/products/domain/usecases/get_product_by_id_usecase.dart';
import 'package:shopkeeper/features/products/domain/usecases/save_product_usecase.dart';

class EditProductScreen extends StatefulWidget {
  final String? productId;

  const EditProductScreen({this.productId, super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _retailPriceController;
  late final TextEditingController _cartonPriceController;
  late final TextEditingController _cartonQtyController;
  late final TextEditingController _stockQtyController;
  late final TextEditingController _thresholdController;

  String _selectedCategory = 'Beverages';
  bool _isSaving = false;
  bool _isLoading = false;
  String _shopId = '';

  late final GetProductByIdUseCase _getProductByIdUseCase;
  late final SaveProductUseCase _saveProductUseCase;

  static const List<String> _categories = [
    'Beverages',
    'Snacks',
    'Cleaning',
    'Dairy',
    'Household',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _retailPriceController = TextEditingController();
    _cartonPriceController = TextEditingController();
    _cartonQtyController = TextEditingController();
    _stockQtyController = TextEditingController();
    _thresholdController = TextEditingController();

    _getProductByIdUseCase = getIt<GetProductByIdUseCase>();
    _saveProductUseCase = getIt<SaveProductUseCase>();
    _shopId = context.read<AuthProvider>().currentUser?.shopId ?? 'unknown';

    if (widget.productId != null) {
      _loadProductDetails();
    }
  }

  Future<void> _loadProductDetails() async {
    setState(() => _isLoading = true);
    final result = await _getProductByIdUseCase.call(widget.productId!).run();

    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: Colors.redAccent,
          ),
        );
      },
      (product) {
        _nameController.text = product.name;
        _descriptionController.text = '';
        _selectedCategory = product.category;
        _retailPriceController.text = product.retailPrice.toStringAsFixed(0);
        _cartonPriceController.text = product.cartonPrice.toStringAsFixed(0);
        _cartonQtyController.text = product.cartonQty.toString();
        _stockQtyController.text = product.stockQty.toString();
        _thresholdController.text = product.lowStockThreshold.toString();
        _shopId = product.shopId;
        setState(() => _isLoading = false);
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _retailPriceController.dispose();
    _cartonPriceController.dispose();
    _cartonQtyController.dispose();
    _stockQtyController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final product = Product(
      id: widget.productId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      shopId: _shopId,
      name: _nameController.text.trim(),
      category: _selectedCategory,
      retailPrice:
          double.parse(_retailPriceController.text.replaceAll(',', '').trim()),
      cartonPrice:
          double.parse(_cartonPriceController.text.replaceAll(',', '').trim()),
      cartonQty:
          int.parse(_cartonQtyController.text.replaceAll(',', '').trim()),
      stockQty: int.parse(_stockQtyController.text.replaceAll(',', '').trim()),
      lowStockThreshold:
          int.parse(_thresholdController.text.replaceAll(',', '').trim()),
      isActive: true,
    );

    setState(() => _isSaving = true);
    final result = await _saveProductUseCase.call(product).run();

    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: Colors.redAccent,
          ),
        );
      },
      (_) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.productId == null
                ? 'Product created successfully'
                : 'Product updated successfully'),
            backgroundColor: AppColors.ownerPrimary,
          ),
        );
        Navigator.of(context).pop();
      },
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _numericValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    if (int.tryParse(value.replaceAll(',', '').trim()) == null) {
      return 'Enter a valid number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.productId == null
        ? AppStrings.addProduct
        : AppStrings.editProduct;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.ownerPrimary,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Container(
                    height: 180,
                    decoration: const BoxDecoration(
                      color: AppColors.ownerPrimary,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.08),
                                  blurRadius: 24,
                                  offset: Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: AppColors.accentLight,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.inventory_2,
                                    color: AppColors.accent,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: AppTextStyles.displayS.copyWith(
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Create or update your product details with stock, pricing and category information.',
                                        style: AppTextStyles.bodyM.copyWith(
                                          color: AppColors.textSecondary,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 50),
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader(AppStrings.productDetails,
                                    'Essential product information'),
                                const SizedBox(height: 16),
                                AppTextField(
                                  label: 'Product name',
                                  hintText: 'e.g. Fresh Milk 1L',
                                  controller: _nameController,
                                  validator: _requiredValidator,
                                ),
                                const SizedBox(height: 16),
                                _buildCategoryField(),
                                const SizedBox(height: 16),
                                AppTextField(
                                  label: 'Description',
                                  hintText: 'Optional description',
                                  controller: _descriptionController,
                                  maxLines: 3,
                                  minLines: 3,
                                ),
                                const SizedBox(height: 24),
                                _buildSectionHeader(AppStrings.pricing,
                                    'Retail and carton pricing'),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: AppTextField(
                                        label: AppStrings.retailPrice,
                                        hintText: 'e.g. 2500',
                                        controller: _retailPriceController,
                                        keyboardType: TextInputType.number,
                                        validator: _numericValidator,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: AppTextField(
                                        label: AppStrings.cartonPrice,
                                        hintText: 'e.g. 23000',
                                        controller: _cartonPriceController,
                                        keyboardType: TextInputType.number,
                                        validator: _numericValidator,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: AppTextField(
                                        label: AppStrings.cartonQty,
                                        hintText: 'e.g. 12',
                                        controller: _cartonQtyController,
                                        keyboardType: TextInputType.number,
                                        validator: _numericValidator,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: AppTextField(
                                        label: AppStrings.stockQty,
                                        hintText: 'e.g. 32',
                                        controller: _stockQtyController,
                                        keyboardType: TextInputType.number,
                                        validator: _numericValidator,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                _buildSectionHeader(AppStrings.stockManagement,
                                    'Keep inventory safe and visible'),
                                const SizedBox(height: 16),
                                AppTextField(
                                  label: AppStrings.lowStockThreshold,
                                  hintText: 'e.g. 10',
                                  controller: _thresholdController,
                                  keyboardType: TextInputType.number,
                                  validator: _numericValidator,
                                ),
                                const SizedBox(height: 30),
                                Row(
                                  children: [
                                    Expanded(
                                      child: AppButton.outlined(
                                        label: AppStrings.cancel,
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: AppButton.primary(
                                        label: AppStrings.save,
                                        onPressed: _saveProduct,
                                        isLoading: _isSaving,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style:
                AppTextStyles.headingM.copyWith(color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Text(subtitle,
            style:
                AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category',
            style:
                AppTextStyles.headingS.copyWith(color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: const InputDecoration(border: InputBorder.none),
            items: _categories
                .map(
                  (category) => DropdownMenuItem<String>(
                    value: category,
                    child: Text(category, style: AppTextStyles.bodyM),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _selectedCategory = value;
              });
            },
          ),
        ),
      ],
    );
  }
}
