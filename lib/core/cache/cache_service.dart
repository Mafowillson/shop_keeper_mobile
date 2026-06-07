import 'package:shopkeeper/core/cache/cache_metadata_service.dart';
import 'package:shopkeeper/core/cache/cache_status.dart';
import 'package:shopkeeper/core/offline/hive_boxes.dart';
import 'package:shopkeeper/features/debts/data/datasources/debt_local_datasource.dart';
import 'package:shopkeeper/features/notifications/data/datasources/notification_local_datasource.dart';
import 'package:shopkeeper/features/products/data/datasources/product_local_datasource.dart';
import 'package:shopkeeper/features/sales/data/datasources/sale_local_datasource.dart';

/// Central coordinator for all Hive cache operations.
///
/// Use the domain-specific [invalidateForXxx] methods after write operations
/// to keep related boxes consistent.  Call [invalidateAll] on logout to clear
/// sensitive data.
class CacheService {
  final ProductLocalDataSource products;
  final SaleLocalDataSource sales;
  final DebtLocalDataSource debts;
  final NotificationLocalDataSource notifications;
  final CacheMetadataService metadata;

  CacheService({
    required this.products,
    required this.sales,
    required this.debts,
    required this.notifications,
    required this.metadata,
  });

  // ── Status queries ────────────────────────────────────────────────────────

  CacheStatus getStatus(String boxName, {required bool hasData}) =>
      metadata.statusFor(boxName, hasData: hasData);

  // ── Domain invalidation ───────────────────────────────────────────────────

  /// After recording a sale: sales list changes, product stock changes,
  /// dashboard totals change.
  Future<void> invalidateForSale() async {
    await Future.wait([
      sales.invalidate(),
      products.invalidate(),
      metadata.clearTimestamp(HiveBoxes.dashboard),
    ]);
  }

  /// After creating or updating a product.
  Future<void> invalidateForProduct() async {
    await products.invalidate();
  }

  /// After creating a customer.
  Future<void> invalidateForCustomer() async {
    await debts.invalidateCustomers();
  }

  /// After recording a payment: customer balance changes, debt records change,
  /// dashboard debt total changes.
  Future<void> invalidateForPayment() async {
    await Future.wait([
      debts.invalidateCustomers(),
      debts.invalidateDebtRecords(),
      metadata.clearTimestamp(HiveBoxes.dashboard),
    ]);
  }

  /// After any notification change.
  Future<void> invalidateForNotification() async {
    await notifications.invalidate();
  }

  // ── Full wipe (logout) ────────────────────────────────────────────────────

  /// Clears all cached data.  Must be called on logout for security.
  Future<void> invalidateAll() async {
    await Future.wait([
      products.invalidate(),
      sales.invalidate(),
      debts.invalidateCustomers(),
      debts.invalidateDebtRecords(),
      notifications.invalidate(),
      metadata.clearAll(),
    ]);
  }
}
