import 'package:flutter/material.dart';
import 'package:shopkeeper/core/constants/app_colors.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';
import 'package:shopkeeper/features/products/domain/entities/product.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';
import 'package:shopkeeper/l10n/app_localizations_ext.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  final Color primaryColor;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sortedUnits = [...product.units]
      ..sort((a, b) => a.quantityInBase.compareTo(b.quantityInBase));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _AppBar(product: product, l10n: l10n, primaryColor: primaryColor),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StockCard(
                      product: product, l10n: l10n, primaryColor: primaryColor),
                  const SizedBox(height: 14),
                  _PricingCard(
                      units: sortedUnits,
                      baseUnit: product.baseUnit,
                      l10n: l10n,
                      primaryColor: primaryColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Collapsing app bar ────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final Product product;
  final AppLocalizations l10n;
  final Color primaryColor;

  const _AppBar(
      {required this.product, required this.l10n, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusFg, statusBg) = product.isOutOfStock
        ? (l10n.outOfStock, AppColors.danger, AppColors.dangerLight)
        : product.isLowStock
            ? (l10n.lowStockAlert, AppColors.warning, AppColors.warningLight)
            : (l10n.availableLabel, AppColors.success, AppColors.successLight);

    return SliverAppBar(
      pinned: true,
      expandedHeight: 148,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      // Compact title shown once the header collapses.
      title: Text(
        product.name,
        style: AppTextStyles.headingS.copyWith(color: Colors.white),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      flexibleSpace: FlexibleSpaceBar(
        // Suppress the default title so we control it ourselves above.
        title: const SizedBox.shrink(),
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppTextStyles.headingL
                      .copyWith(color: Colors.white, height: 1.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _Chip(
                      label: l10n.translateCategory(product.category),
                      fg: Colors.white.withValues(alpha: 0.95),
                      bg: Colors.white.withValues(alpha: 0.18),
                    ),
                    const SizedBox(width: 8),
                    _Chip(
                      label: statusLabel,
                      fg: statusFg,
                      bg: statusBg,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color fg;
  final Color bg;
  const _Chip({required this.label, required this.fg, required this.bg});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelM
              .copyWith(color: fg, fontWeight: FontWeight.w600),
        ),
      );
}

// ── Stock card ────────────────────────────────────────────────────────────────

class _StockCard extends StatelessWidget {
  final Product product;
  final AppLocalizations l10n;
  final Color primaryColor;
  const _StockCard(
      {required this.product, required this.l10n, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final stockColor = product.isOutOfStock
        ? AppColors.danger
        : product.isLowStock
            ? AppColors.warning
            : AppColors.success;

    final threshold = product.lowStockThreshold.toDouble();
    final stock = product.stockQty.toDouble();
    final max = (threshold * 3).clamp(1.0, double.infinity);
    final ratio = (stock / max).clamp(0.0, 1.0);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section heading
          _SectionHeader(
            icon: Icons.layers_outlined,
            label: l10n.inStock,
            color: primaryColor,
          ),
          const SizedBox(height: 18),
          // Large stock number
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${product.stockQty}',
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w700,
                  color: stockColor,
                  height: 1,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  product.baseUnit,
                  style: AppTextStyles.headingS
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(stockColor),
            ),
          ),
          // Threshold label
          if (product.lowStockThreshold > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.notifications_outlined,
                    size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 5),
                Text(
                  '${l10n.lowStockAlert}: ${product.lowStockThreshold} ${product.baseUnit}',
                  style: AppTextStyles.bodyS
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Pricing card ──────────────────────────────────────────────────────────────

class _PricingCard extends StatelessWidget {
  final List<UnitDefinition> units;
  final String baseUnit;
  final AppLocalizations l10n;
  final Color primaryColor;
  const _PricingCard(
      {required this.units,
      required this.baseUnit,
      required this.l10n,
      required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.sell_outlined,
            label: l10n.priceList,
            color: primaryColor,
          ),
          const SizedBox(height: 4),
          for (int i = 0; i < units.length; i++) ...[
            const Divider(height: 20, color: AppColors.border),
            _PriceRow(
              unit: units[i],
              l10n: l10n,
              primaryColor: primaryColor,
            ),
          ],
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final UnitDefinition unit;
  final AppLocalizations l10n;
  final Color primaryColor;
  const _PriceRow(
      {required this.unit, required this.l10n, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final isBase = unit.quantityInBase == 1;
    final color = isBase ? primaryColor : AppColors.accent;
    final label = isBase ? unit.name : '${unit.name} ×${unit.quantityInBase}';

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isBase ? Icons.sell_outlined : Icons.inventory_2_outlined,
            size: 18,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style:
                    AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w500),
              ),
              if (isBase)
                Text(
                  l10n.baseUnitBadge,
                  style: AppTextStyles.labelS
                      .copyWith(color: AppColors.textSecondary),
                ),
            ],
          ),
        ),
        Text(
          '${l10n.fcfa} ${unit.price.toStringAsFixed(0)}',
          style: AppTextStyles.headingM.copyWith(color: color),
        ),
      ],
    );
  }
}

// ── Shared atoms ──────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      );
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SectionHeader(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 7),
          Text(
            label,
            style: AppTextStyles.labelL
                .copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      );
}
