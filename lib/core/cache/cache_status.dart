import 'package:shopkeeper/core/offline/hive_boxes.dart';

/// The freshness state of a single Hive box.
enum CacheStatus {
  /// Data exists and is within the staleness threshold.
  fresh,

  /// Data exists but is older than the staleness threshold.
  stale,

  /// No data in the box at all (first launch or after logout).
  empty,
}

/// Per-box staleness thresholds used by [CacheMetadataService.isStale].
abstract final class StaleThresholds {
  static const products = Duration(minutes: 5);
  static const sales = Duration(minutes: 10);
  static const customers = Duration(minutes: 5);
  static const debtRecords = Duration(minutes: 5);
  static const notifications = Duration(minutes: 1);
  static const dashboard = Duration(minutes: 2);
  static const staff = Duration(hours: 1);

  static Duration forBox(String boxName) {
    switch (boxName) {
      case HiveBoxes.products:
        return products;
      case HiveBoxes.sales:
        return sales;
      case HiveBoxes.customers:
        return customers;
      case HiveBoxes.debtRecords:
        return debtRecords;
      case HiveBoxes.notifications:
        return notifications;
      case HiveBoxes.dashboard:
        return dashboard;
      case HiveBoxes.staff:
        return staff;
      default:
        return const Duration(minutes: 5);
    }
  }
}
