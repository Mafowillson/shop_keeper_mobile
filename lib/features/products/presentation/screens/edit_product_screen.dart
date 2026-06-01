import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_strings.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/widgets/app_button.dart';
import 'package:shopkeeper/core/widgets/app_text_field.dart';
import 'package:shopkeeper/core/widgets/snack_bar_helper.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/products/domain/entities/product.dart';
import 'package:shopkeeper/features/products/presentation/providers/product_provider.dart';

class EditProductScreen extends StatefulWidget {
  final String? productId;

  const EditProductScreen({this.productId, super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _retailPriceController;
  late final TextEditingController _cartonPriceController;
  late final TextEditingController _cartonQtyController;
  late final TextEditingController _stockQtyController;
  late final TextEditingController _thresholdController;

  String _selectedCategory = 'Beverages';
  bool _hasCarton = true;
  bool _isLoadingProduct = false;

  static const List<String> _categories = [
    'Beverages', 'Snacks', 'Cleaning', 'Dairy', 'Household', 'Other',
  ];

  bool get _isNew => widget.productId == null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _retailPriceController = TextEditingController();
    _cartonPriceController = TextEditingController();
    _cartonQtyController = TextEditingController(text: '24');
    _stockQtyController = TextEditingController(text: '0');
    _thresholdController = TextEditingController(text: '10');

    if (!_isNew) _loadProduct();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _retailPriceController.dispose();
    _cartonPriceController.dispose();
    _cartonQtyController.dispose();
    _stockQtyController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    setState(() => _isLoadingProduct = true);

    // The product list is already loaded by ProductsScreen before navigating
    // here, so look it up by ID.
    final product = context
        .read<ProductProvider>()
        .products
        .where((p) => p.id == widget.productId)
        .firstOrNull;

    if (!mounted) return;
    if (product != null) _populateForm(product);
    setState(() => _isLoadingProduct = false);
  }

  void _populateForm(Product p) {
    _nameController.text = p.name;
    _selectedCategory = p.category;
    _retailPriceController.text = p.retailPrice.toStringAsFixed(0);
    _hasCarton = p.cartonQty > 1;
    if (_hasCarton) {
      _cartonPriceController.text = p.cartonPrice.toStringAsFixed(0);
      _cartonQtyController.text = p.cartonQty.toString();
    }
    _stockQtyController.text = p.stockQty.toString();
    _thresholdController.text = p.lowStockThreshold.toString();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final shopId = context.read<AuthProvider>().currentUser?.shopId ?? '';
    final retailPrice = double.tryParse(
            _retailPriceController.text.replaceAll(',', '').trim()) ??
        0;
    final cartonPrice = _hasCarton
        ? (double.tryParse(
                _cartonPriceController.text.replaceAll(',', '').trim()) ??
            retailPrice)
        : retailPrice;
    final cartonQty = _hasCarton
        ? (int.tryParse(
                _cartonQtyController.text.replaceAll(',', '').trim()) ??
            1)
        : 1;

    final product = Product(
      id: widget.productId ?? '',
      shopId: shopId,
      name: _nameController.text.trim(),
      category: _selectedCategory,
      retailPrice: retailPrice,
      cartonPrice: cartonPrice,
      cartonQty: cartonQty,
      stockQty:
          int.tryParse(_stockQtyController.text.replaceAll(',', '').trim()) ??
              0,
      lowStockThreshold: int.tryParse(
              _thresholdController.text.replaceAll(',', '').trim()) ??
          0,
      isActive: true,
    );

    final saved =
        await context.read<ProductProvider>().saveProduct(product);

    if (!mounted) return;

    if (saved != null) {
      SnackBarHelper.showSuccess(
        context,
        _isNew ? 'Product created successfully' : 'Product updated',
      );
      Navigator.of(context).pop();
    } else {
      final err = context.read<ProductProvider>().errorMessage ?? 'Save failed';
      SnackBarHelper.showError(context, err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isNew ? AppStrings.addProduct : AppStrings.editProduct;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title,
            style: AppTextStyles.headingL.copyWith(color: Colors.white)),
        backgroundColor: AppColors.ownerPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.accentLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.inventory_2_outlined,
                              color: AppColors.accent, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: AppTextStyles.headingM),
                              const SizedBox(height: 2),
                              Text(
                                _isNew
                                    ? 'Fill in the details to add a new product.'
                                    : 'Update the product details below.',
                                style: AppTextStyles.bodyS,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Product details ─────────────────────────────────────
                  const _SectionHeader('Product details', 'Name and category'),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Product name',
                    hintText: 'e.g. Fresh Milk 1L',
                    controller: _nameController,
                    prefixIcon: const Icon(Icons.label_outline),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  _CategoryDropdown(
                    selected: _selectedCategory,
                    categories: _categories,
                    onChanged: (v) => setState(() => _selectedCategory = v),
                  ),
                  const SizedBox(height: 22),

                  // ── Pricing ────────────────────────────────────────────
                  const _SectionHeader('Pricing', 'Retail price per unit'),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Retail price (FCFA)',
                    hintText: 'e.g. 1000',
                    controller: _retailPriceController,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.sell_outlined),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if ((double.tryParse(v.replaceAll(',', '')) ?? 0) <= 0) {
                        return 'Must be > 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Carton toggle
                  Row(
                    children: [
                      Switch(
                        value: _hasCarton,
                        onChanged: (v) => setState(() => _hasCarton = v),
                        activeThumbColor: AppColors.ownerPrimary,
                        activeTrackColor: AppColors.ownerPrimary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 8),
                      Text('Has carton / bulk unit',
                          style: AppTextStyles.bodyM),
                    ],
                  ),

                  if (_hasCarton) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Carton price (FCFA)',
                            hintText: 'e.g. 22000',
                            controller: _cartonPriceController,
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            label: 'Units per carton',
                            hintText: 'e.g. 24',
                            controller: _cartonQtyController,
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              final n = int.tryParse(
                                  v?.replaceAll(',', '') ?? '');
                              if (n == null || n < 2) {
                                return 'Min 2';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 22),

                  // ── Stock ──────────────────────────────────────────────
                  const _SectionHeader(AppStrings.stockManagement,
                      'Initial stock and low-stock alert'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: _isNew ? 'Opening stock (units)' : 'Stock qty',
                          hintText: 'e.g. 48',
                          controller: _stockQtyController,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.warehouse_outlined),
                          validator: (v) =>
                              int.tryParse(v?.replaceAll(',', '') ?? '') == null
                                  ? 'Enter a number'
                                  : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: AppStrings.lowStockThreshold,
                          hintText: 'e.g. 10',
                          controller: _thresholdController,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.warning_amber_outlined),
                          validator: (v) =>
                              int.tryParse(v?.replaceAll(',', '') ?? '') == null
                                  ? 'Enter a number'
                                  : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // ── Actions ────────────────────────────────────────────
                  Consumer<ProductProvider>(
                    builder: (_, provider, __) => Row(
                      children: [
                        Expanded(
                          child: AppButton.outlined(
                            label: AppStrings.cancel,
                            onPressed:
                                provider.isSaving ? null : () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton.primary(
                            label: AppStrings.save,
                            isLoading: provider.isSaving,
                            onPressed: provider.isSaving ? null : _submit,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (_isLoadingProduct)
            Positioned.fill(
              child: Container(
                color: Colors.black12,
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.ownerPrimary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader(this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.headingM),
        const SizedBox(height: 2),
        Text(subtitle,
            style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final String selected;
  final List<String> categories;
  final ValueChanged<String> onChanged;

  const _CategoryDropdown({
    required this.selected,
    required this.categories,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: AppTextStyles.headingS),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selected,
              isExpanded: true,
              items: categories
                  .map((c) => DropdownMenuItem(
                      value: c, child: Text(c, style: AppTextStyles.bodyM)))
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}
