import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/core/widgets/app_button.dart';
import 'package:shopkeeper/core/widgets/app_text_field.dart';
import 'package:shopkeeper/core/widgets/snack_bar_helper.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/products/domain/entities/product.dart';
import 'package:shopkeeper/features/products/presentation/providers/product_provider.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';
import 'package:shopkeeper/l10n/app_localizations_ext.dart';

class _UnitEntry {
  final TextEditingController name;
  final TextEditingController qty;
  final TextEditingController price;
  final TextEditingController stock;

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
    'Beverages',
    'Snacks & Sweets',
    'Grains & Staples',
    'Dairy & Eggs',
    'Cleaning & Hygiene',
    'Household',
    'Toiletries',
    'Other',
  ];

  bool get _isNew => widget.productId == null;

  String _getBaseUnitName(AppLocalizations l10n) {
    for (final e in _units) {
      if (e.isBase && e.name.text.trim().isNotEmpty) {
        return e.name.text.trim();
      }
    }
    return l10n.unitsFallback;
  }

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;

    final baseCount = _units.where((e) => e.isBase).length;
    if (baseCount == 0) {
      SnackBarHelper.showError(context, l10n.errorOneUnitMustBeBase);
      return;
    }
    if (baseCount > 1) {
      SnackBarHelper.showError(context, l10n.errorOnlyOneBase);
      return;
    }

    final names = _units.map((e) => e.name.text.trim().toLowerCase()).toList();
    if (names.toSet().length != names.length) {
      SnackBarHelper.showError(context, l10n.errorUnitNamesUnique);
      return;
    }

    FocusScope.of(context).unfocus();

    final units = _units
        .map((e) => UnitDefinition(
              name: e.name.text.trim().toLowerCase(),
              quantityInBase: int.parse(e.qty.text.trim()),
              price: double.parse(e.price.text.replaceAll(',', '').trim()),
            ))
        .toList();

    final baseUnitName = units.firstWhere((u) => u.quantityInBase == 1).name;

    Map<String, int>? initialStock;
    if (_isNew) {
      initialStock = {};
      for (final e in _units) {
        final name = e.name.text.trim().toLowerCase();
        final qty = int.tryParse(e.stock.text.trim()) ?? 0;
        if (name.isNotEmpty && qty > 0) initialStock[name] = qty;
      }
    }

    final shopId = context.read<AuthProvider>().currentUser?.shopId ?? '';

    final product = Product(
      id: widget.productId ?? '',
      shopId: shopId,
      name: _nameController.text.trim(),
      category: _selectedCategory,
      baseUnit: baseUnitName,
      units: units,
      stockQty: 0,
      lowStockThreshold: int.tryParse(_thresholdController.text.trim()) ?? 0,
      isActive: true,
      initialStock: initialStock,
    );

    final saved = await context.read<ProductProvider>().saveProduct(product);

    if (!mounted) return;

    if (saved != null) {
      SnackBarHelper.showSuccess(
        context,
        _isNew ? l10n.productCreatedSuccessfully : l10n.productUpdated,
      );
      Navigator.of(context).pop();
    } else {
      final err = context.read<ProductProvider>().errorMessage ?? l10n.error;
      SnackBarHelper.showError(context, err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final baseUnitName = _getBaseUnitName(l10n);
    final title = _isNew ? l10n.addProduct : l10n.editProduct;

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
                  _SectionHeader(
                    icon: Icons.label_outline,
                    title: l10n.productInfo,
                    subtitle: l10n.nameAndCategory,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: l10n.productName,
                    hintText: l10n.hintExProductName,
                    controller: _nameController,
                    prefixIcon: const Icon(Icons.storefront_outlined, size: 20),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? l10n.required : null,
                  ),
                  const SizedBox(height: 12),
                  _CategoryDropdown(
                    selected: _selectedCategory,
                    categories: _categories,
                    label: l10n.category,
                    onChanged: (v) => setState(() => _selectedCategory = v),
                    l10n: l10n,
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(
                    icon: Icons.layers_outlined,
                    title: l10n.units,
                    subtitle: l10n.howManyBaseUnits,
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
                          l10n: l10n,
                        ),
                      ),
                  if (_units.length < 5)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: TextButton.icon(
                        onPressed: _addUnit,
                        icon: const Icon(Icons.add_circle_outline, size: 18),
                        label: Text(l10n.addAnotherUnit,
                            style: AppTextStyles.labelL),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.ownerPrimary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (_isNew) ...[
                    _SectionHeader(
                      icon: Icons.warehouse_outlined,
                      title: l10n.openingStock,
                      subtitle: l10n.openingStockSubtitle,
                    ),
                    const SizedBox(height: 12),
                    _OpeningStockSection(
                      units: _units,
                      baseUnitName: baseUnitName,
                      onChanged: () => setState(() {}),
                      l10n: l10n,
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (!_isNew) ...[
                    _SectionHeader(
                      icon: Icons.inventory_2_outlined,
                      title: l10n.currentStock,
                      subtitle: l10n.currentStockSubtitle,
                    ),
                    const SizedBox(height: 12),
                    _CurrentStockSection(
                      productId: widget.productId!,
                      l10n: l10n,
                    ),
                    const SizedBox(height: 24),
                  ],
                  _SectionHeader(
                    icon: Icons.warning_amber_outlined,
                    title: l10n.lowStockAlert,
                    subtitle: l10n.lowStockAlertSubtitle(baseUnitName),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: l10n.thresholdLabel(baseUnitName),
                    hintText: l10n.hintExThreshold,
                    controller: _thresholdController,
                    keyboardType: TextInputType.number,
                    prefixIcon:
                        const Icon(Icons.notifications_outlined, size: 20),
                    validator: (v) => int.tryParse(v?.trim() ?? '') == null
                        ? l10n.enterWholeNumber
                        : null,
                  ),
                  const SizedBox(height: 32),
                  Consumer<ProductProvider>(
                    builder: (_, provider, __) => Row(
                      children: [
                        Expanded(
                          child: AppButton.outlined(
                            label: l10n.cancel,
                            onPressed: provider.isSaving
                                ? null
                                : () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton.primary(
                            label: l10n.save,
                            isLoading: provider.isSaving,
                            onPressed: provider.isSaving ? null : _submit,
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
                  child:
                      CircularProgressIndicator(color: AppColors.ownerPrimary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  final int index;
  final _UnitEntry entry;
  final bool canRemove;
  final bool isNew;
  final VoidCallback onRemove;
  final VoidCallback onChanged;
  final AppLocalizations l10n;

  const _UnitCard({
    required this.index,
    required this.entry,
    required this.canRemove,
    required this.isNew,
    required this.onRemove,
    required this.onChanged,
    required this.l10n,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                  l10n.unitNumber(index + 1),
                  style: AppTextStyles.headingS
                      .copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(width: 8),
                if (isBase)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.ownerPrimary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      l10n.baseUnitBadge,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: AppTextField(
                        label: l10n.unitName,
                        hintText: l10n.hintExUnitName,
                        controller: entry.name,
                        onChanged: (_) => onChanged(),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? l10n.required
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: AppTextField(
                        label: l10n.qtyInBase,
                        hintText: l10n.hintExQtyInBase,
                        controller: entry.qty,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => onChanged(),
                        validator: (v) {
                          final n = int.tryParse(v?.trim() ?? '');
                          if (n == null || n < 1) return l10n.minOne;
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AppTextField(
                  label: l10n.priceFCFA,
                  hintText: l10n.hintExPrice,
                  controller: entry.price,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.sell_outlined, size: 18),
                  validator: (v) {
                    final n =
                        double.tryParse(v?.replaceAll(',', '').trim() ?? '');
                    if (n == null || n <= 0) return l10n.mustBePositive;
                    return null;
                  },
                ),
                const SizedBox(height: 6),
                Text(
                  isBase ? l10n.baseUnitHint : l10n.howManyBaseUnits,
                  style:
                      AppTextStyles.labelS.copyWith(color: AppColors.textHint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OpeningStockSection extends StatefulWidget {
  final List<_UnitEntry> units;
  final String baseUnitName;
  final VoidCallback onChanged;
  final AppLocalizations l10n;

  const _OpeningStockSection({
    required this.units,
    required this.baseUnitName,
    required this.onChanged,
    required this.l10n,
  });

  @override
  State<_OpeningStockSection> createState() => _OpeningStockSectionState();
}

class _OpeningStockSectionState extends State<_OpeningStockSection> {
  int _selectedIdx = 0;
  bool _userSelected = false;

  @override
  void initState() {
    super.initState();
    _selectedIdx = _highestUnitIdx(widget.units);
  }

  @override
  void didUpdateWidget(_OpeningStockSection old) {
    super.didUpdateWidget(old);
    if (_selectedIdx >= widget.units.length) {
      _selectedIdx = _highestUnitIdx(widget.units);
      _userSelected = false;
    } else if (!_userSelected) {
      _selectedIdx = _highestUnitIdx(widget.units);
    }
  }

  int _highestUnitIdx(List<_UnitEntry> entries) {
    if (entries.isEmpty) return 0;
    int best = 0;
    int bestQty = int.tryParse(entries[0].qty.text.trim()) ?? 0;
    for (int i = 1; i < entries.length; i++) {
      final q = int.tryParse(entries[i].qty.text.trim()) ?? 0;
      if (q > bestQty) {
        bestQty = q;
        best = i;
      }
    }
    return best;
  }

  void _selectUnit(int idx) {
    if (idx == _selectedIdx) return;
    widget.units[_selectedIdx].stock.text = '';
    setState(() {
      _selectedIdx = idx;
      _userSelected = true;
    });
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final units = widget.units;
    if (units.isEmpty) return const SizedBox.shrink();

    final idx = _selectedIdx.clamp(0, units.length - 1);
    final selected = units[idx];
    final unitName = selected.name.text.trim().isEmpty
        ? widget.l10n.unitNumber(idx + 1)
        : selected.name.text.trim();
    final stockQty = int.tryParse(selected.stock.text.trim()) ?? 0;
    final qib = int.tryParse(selected.qty.text.trim()) ?? 1;
    final totalBase = stockQty * qib;

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
          if (units.length > 1) ...[
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: List.generate(units.length, (i) {
                final name = units[i].name.text.trim().isEmpty
                    ? widget.l10n.unitNumber(i + 1)
                    : units[i].name.text.trim();
                final isSelected = i == idx;
                return GestureDetector(
                  onTap: () => _selectUnit(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.ownerPrimary
                          : AppColors.ownerPrimary.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.ownerPrimary
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      name,
                      style: AppTextStyles.labelM.copyWith(
                        color:
                            isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 14),
          ],
          AppTextField(
            label: unitName,
            hintText: '0',
            controller: selected.stock,
            keyboardType: TextInputType.number,
            onChanged: (_) {
              setState(() {});
              widget.onChanged();
            },
          ),
          if (totalBase > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.calculate_outlined,
                    size: 16, color: AppColors.ownerPrimary),
                const SizedBox(width: 6),
                Text(
                  widget.l10n.stockTotal(totalBase, widget.baseUnitName),
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

class _CurrentStockSection extends StatelessWidget {
  final String productId;
  final AppLocalizations l10n;
  const _CurrentStockSection({required this.productId, required this.l10n});

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
                    color: AppColors.ownerPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      u.name.substring(0, 1).toUpperCase(),
                      style: AppTextStyles.headingS
                          .copyWith(color: AppColors.ownerPrimary),
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
                  '$available ${l10n.available}',
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
              color: AppColors.ownerPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 17, color: AppColors.ownerPrimary),
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
  final String label;
  final ValueChanged<String> onChanged;
  final AppLocalizations l10n;

  const _CategoryDropdown({
    required this.selected,
    required this.categories,
    required this.label,
    required this.onChanged,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
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
                        child: Text(l10n.translateCategory(c),
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
