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

// ── Unit entry (form state for one unit row) ───────────────────────────────────

class _UnitEntry {
  final TextEditingController name;
  final TextEditingController qty;
  final TextEditingController price;
  final TextEditingController stock; // opening stock, create-mode only

  _UnitEntry({String n = '', String q = '', String p = '', String s = '0'})
      : name = TextEditingController(text: n),
        qty = TextEditingController(text: q),
        price = TextEditingController(text: p),
        stock = TextEditingController(text: s);

  bool get isBase => (int.tryParse(qty.text.trim()) ?? 0) == 1;

  void dispose() {
    name.dispose();
    qty.dispose();
    price.dispose();
    stock.dispose();
  }
}

// ── Screen ─────────────────────────────────────────────────────────────────────

class EditProductScreen extends StatefulWidget {
  final String? productId;
  const EditProductScreen({this.productId, super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _thresholdController;
  String _selectedCategory = 'Beverages';
  List<_UnitEntry> _units = [];
  bool _isLoadingProduct = false;

  static const _categories = [
    'Beverages', 'Snacks & Sweets', 'Grains & Staples',
    'Dairy & Eggs', 'Cleaning & Hygiene', 'Household', 'Toiletries', 'Other',
  ];

  bool get _isNew => widget.productId == null;

  // ── Computed helpers ────────────────────────────────────────────────────────

  String get _baseUnitName {
    for (final e in _units) {
      if (e.isBase && e.name.text.trim().isNotEmpty) {
        return e.name.text.trim();
      }
    }
    return 'units';
  }

  int get _computedStockTotal {
    int total = 0;
    for (final e in _units) {
      final qty = int.tryParse(e.stock.text.trim()) ?? 0;
      final qib = int.tryParse(e.qty.text.trim()) ?? 0;
      total += qty * qib;
    }
    return total;
  }

  // ── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _thresholdController = TextEditingController(text: '5');
    if (_isNew) {
      _addEntry(_UnitEntry(q: '1'));
    } else {
      _loadProduct();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _thresholdController.dispose();
    for (final e in _units) {
      e.dispose();
    }
    super.dispose();
  }

  void _addEntry(_UnitEntry entry) {
    entry.qty.addListener(() => setState(() {}));
    entry.name.addListener(() => setState(() {}));
    entry.stock.addListener(() => setState(() {}));
    _units.add(entry);
  }

  // ── Data loading ────────────────────────────────────────────────────────────

  Future<void> _loadProduct() async {
    setState(() => _isLoadingProduct = true);
    final product = context
        .read<ProductProvider>()
        .products
        .where((p) => p.id == widget.productId)
        .firstOrNull;
    if (mounted && product != null) _populateForm(product);
    setState(() => _isLoadingProduct = false);
  }

  void _populateForm(Product p) {
    _nameController.text = p.name;
    _selectedCategory = p.category;
    _thresholdController.text = p.lowStockThreshold.toString();
    for (final e in _units) {
      e.dispose();
    }
    _units = [];
    for (final u in p.units) {
      _addEntry(_UnitEntry(
        n: u.name,
        q: u.quantityInBase.toString(),
        p: u.price.toStringAsFixed(0),
      ));
    }
    if (_units.isEmpty) _addEntry(_UnitEntry(q: '1'));
  }

  // ── Unit management ─────────────────────────────────────────────────────────

  void _addUnit() {
    if (_units.length >= 5) return;
    setState(() => _addEntry(_UnitEntry()));
  }

  void _removeUnit(int index) {
    if (_units.length <= 1) return;
    setState(() {
      _units[index].dispose();
      _units.removeAt(index);
    });
  }

  // ── Submission ──────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Cross-field: exactly one base unit
    final baseCount = _units.where((e) => e.isBase).length;
    if (baseCount == 0) {
      SnackBarHelper.showError(
          context, 'One unit must have quantity-in-base = 1 (the base unit).');
      return;
    }
    if (baseCount > 1) {
      SnackBarHelper.showError(
          context, 'Only one unit can have quantity-in-base = 1.');
      return;
    }

    // Check duplicate names
    final names =
        _units.map((e) => e.name.text.trim().toLowerCase()).toList();
    if (names.toSet().length != names.length) {
      SnackBarHelper.showError(context, 'Unit names must be unique.');
      return;
    }

    FocusScope.of(context).unfocus();

    final units = _units
        .map((e) => UnitDefinition(
              name: e.name.text.trim().toLowerCase(),
              quantityInBase: int.parse(e.qty.text.trim()),
              price: double.parse(
                  e.price.text.replaceAll(',', '').trim()),
            ))
        .toList();

    final baseUnitName =
        units.firstWhere((u) => u.quantityInBase == 1).name;

    Map<String, int>? initialStock;
    if (_isNew) {
      initialStock = {};
      for (final e in _units) {
        final name = e.name.text.trim().toLowerCase();
        final qty = int.tryParse(e.stock.text.trim()) ?? 0;
        if (name.isNotEmpty && qty > 0) initialStock[name] = qty;
      }
    }

    final shopId =
        context.read<AuthProvider>().currentUser?.shopId ?? '';

    final product = Product(
      id: widget.productId ?? '',
      shopId: shopId,
      name: _nameController.text.trim(),
      category: _selectedCategory,
      baseUnit: baseUnitName,
      units: units,
      stockQty: 0,
      lowStockThreshold:
          int.tryParse(_thresholdController.text.trim()) ?? 0,
      isActive: true,
      initialStock: initialStock,
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
      final err = context.read<ProductProvider>().errorMessage ??
          'Save failed';
      SnackBarHelper.showError(context, err);
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final title =
        _isNew ? AppStrings.addProduct : AppStrings.editProduct;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title,
            style:
                AppTextStyles.headingL.copyWith(color: Colors.white)),
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
                  // ── Product info ───────────────────────────────────
                  const _SectionHeader(
                    icon: Icons.label_outline,
                    title: 'Product Info',
                    subtitle: 'Name and category',
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Product name',
                    hintText: 'e.g. Top Cube Sugar',
                    controller: _nameController,
                    prefixIcon: const Icon(Icons.storefront_outlined,
                        size: 20),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _CategoryDropdown(
                    selected: _selectedCategory,
                    categories: _categories,
                    onChanged: (v) =>
                        setState(() => _selectedCategory = v),
                  ),
                  const SizedBox(height: 24),

                  // ── Units ──────────────────────────────────────────
                  const _SectionHeader(
                    icon: Icons.layers_outlined,
                    title: 'Units',
                    subtitle:
                        'Define how this product is sold — exactly one unit must have qty-in-base = 1',
                  ),
                  const SizedBox(height: 12),

                  ..._units.asMap().entries.map(
                        (e) => _UnitCard(
                          index: e.key,
                          entry: e.value,
                          canRemove: _units.length > 1,
                          isNew: _isNew,
                          onRemove: () => _removeUnit(e.key),
                          onChanged: () => setState(() {}),
                        ),
                      ),

                  if (_units.length < 5)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: TextButton.icon(
                        onPressed: _addUnit,
                        icon: const Icon(Icons.add_circle_outline,
                            size: 18),
                        label: Text('Add another unit',
                            style: AppTextStyles.labelL),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.ownerPrimary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),

                  // ── Opening stock (create only) ────────────────────
                  if (_isNew) ...[
                    const _SectionHeader(
                      icon: Icons.warehouse_outlined,
                      title: 'Opening Stock',
                      subtitle:
                          'Enter how much you have now — leave blank if starting at zero',
                    ),
                    const SizedBox(height: 12),
                    _OpeningStockSection(
                      units: _units,
                      computedTotal: _computedStockTotal,
                      baseUnitName: _baseUnitName,
                      onChanged: () => setState(() {}),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Stock info (edit only) ─────────────────────────
                  if (!_isNew) ...[
                    const _SectionHeader(
                      icon: Icons.inventory_2_outlined,
                      title: 'Current Stock',
                      subtitle:
                          'Stock is updated automatically when sales are recorded',
                    ),
                    const SizedBox(height: 12),
                    _CurrentStockSection(
                      productId: widget.productId!,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Threshold ──────────────────────────────────────
                  _SectionHeader(
                    icon: Icons.warning_amber_outlined,
                    title: 'Low Stock Alert',
                    subtitle:
                        'Alert when stock falls below this many $_baseUnitName',
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label:
                        'Threshold (in $_baseUnitName)',
                    hintText: 'e.g. 5',
                    controller: _thresholdController,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.notifications_outlined,
                        size: 20),
                    validator: (v) =>
                        int.tryParse(v?.trim() ?? '') == null
                            ? 'Enter a whole number'
                            : null,
                  ),
                  const SizedBox(height: 32),

                  // ── Actions ────────────────────────────────────────
                  Consumer<ProductProvider>(
                    builder: (_, provider, __) => Row(
                      children: [
                        Expanded(
                          child: AppButton.outlined(
                            label: AppStrings.cancel,
                            onPressed: provider.isSaving
                                ? null
                                : () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton.primary(
                            label: AppStrings.save,
                            isLoading: provider.isSaving,
                            onPressed:
                                provider.isSaving ? null : _submit,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          if (_isLoadingProduct)
            Positioned.fill(
              child: Container(
                color: Colors.black12,
                child: const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.ownerPrimary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Unit card ──────────────────────────────────────────────────────────────────

class _UnitCard extends StatelessWidget {
  final int index;
  final _UnitEntry entry;
  final bool canRemove;
  final bool isNew;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const _UnitCard({
    required this.index,
    required this.entry,
    required this.canRemove,
    required this.isNew,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isBase = entry.isBase;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isBase
              ? AppColors.ownerPrimary.withValues(alpha: 0.4)
              : AppColors.border,
          width: isBase ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isBase
                  ? AppColors.ownerPrimary.withValues(alpha: 0.06)
                  : AppColors.background,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Row(
              children: [
                Text(
                  'Unit ${index + 1}',
                  style: AppTextStyles.headingS
                      .copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(width: 8),
                if (isBase)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.ownerPrimary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'BASE',
                      style: AppTextStyles.labelS.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                const Spacer(),
                if (canRemove)
                  GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.dangerLight,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Icon(Icons.close,
                          color: AppColors.danger, size: 16),
                    ),
                  ),
              ],
            ),
          ),

          // Fields
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: AppTextField(
                        label: 'Unit name',
                        hintText: 'e.g. carton',
                        controller: entry.name,
                        onChanged: (_) => onChanged(),
                        validator: (v) =>
                            v == null || v.trim().isEmpty
                                ? 'Required'
                                : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: AppTextField(
                        label: 'Qty in base',
                        hintText: 'e.g. 25',
                        controller: entry.qty,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => onChanged(),
                        validator: (v) {
                          final n =
                              int.tryParse(v?.trim() ?? '');
                          if (n == null || n < 1) {
                            return 'Min 1';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AppTextField(
                  label: 'Price (FCFA)',
                  hintText: 'e.g. 21000',
                  controller: entry.price,
                  keyboardType: TextInputType.number,
                  prefixIcon:
                      const Icon(Icons.sell_outlined, size: 18),
                  validator: (v) {
                    final n = double.tryParse(
                        v?.replaceAll(',', '').trim() ?? '');
                    if (n == null || n <= 0) return 'Must be > 0';
                    return null;
                  },
                ),
                // Hint: what qty-in-base means
                const SizedBox(height: 6),
                Text(
                  isBase
                      ? 'This is the base unit — stock is tracked in this unit'
                      : 'How many base units fit in this unit',
                  style: AppTextStyles.labelS
                      .copyWith(color: AppColors.textHint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Opening stock section ──────────────────────────────────────────────────────

class _OpeningStockSection extends StatelessWidget {
  final List<_UnitEntry> units;
  final int computedTotal;
  final String baseUnitName;
  final VoidCallback onChanged;

  const _OpeningStockSection({
    required this.units,
    required this.computedTotal,
    required this.baseUnitName,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...units.asMap().entries.map((e) {
            final unitName = e.value.name.text.trim();
            final label = unitName.isEmpty
                ? 'Unit ${e.key + 1}'
                : unitName;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Text(
                      label,
                      style: AppTextStyles.labelL.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: e.value.isBase
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: AppTextField(
                      label: '',
                      hintText: '0',
                      controller: e.value.stock,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => onChanged(),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (computedTotal > 0) ...[
            const Divider(height: 16, color: AppColors.border),
            Row(
              children: [
                const Icon(Icons.calculate_outlined,
                    size: 16, color: AppColors.ownerPrimary),
                const SizedBox(width: 6),
                Text(
                  'Total: $computedTotal $baseUnitName',
                  style: AppTextStyles.labelL.copyWith(
                    color: AppColors.ownerPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Current stock section (edit mode) ─────────────────────────────────────────

class _CurrentStockSection extends StatelessWidget {
  final String productId;
  const _CurrentStockSection({required this.productId});

  @override
  Widget build(BuildContext context) {
    final product = context
        .read<ProductProvider>()
        .products
        .where((p) => p.id == productId)
        .firstOrNull;

    if (product == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: product.units.map((u) {
          final available = product.stockQty ~/ u.quantityInBase;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.ownerPrimary
                        .withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      u.name.substring(0, 1).toUpperCase(),
                      style: AppTextStyles.headingS.copyWith(
                          color: AppColors.ownerPrimary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    u.name,
                    style: AppTextStyles.labelL
                        .copyWith(color: AppColors.textPrimary),
                  ),
                ),
                Text(
                  '$available available',
                  style: AppTextStyles.labelL.copyWith(
                    color: available == 0
                        ? AppColors.danger
                        : available <= 3
                            ? AppColors.warning
                            : AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color:
                  AppColors.ownerPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon,
                size: 17, color: AppColors.ownerPrimary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.headingS),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyS
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      );
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
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Category',
              style: AppTextStyles.headingS
                  .copyWith(color: AppColors.textPrimary)),
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
                        value: c,
                        child: Text(c,
                            style: AppTextStyles.bodyM)))
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
