import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:shopkeeper/features/dashboard/domain/repositories/i_dashboard_repository.dart';

import '../../../../helpers/fake_providers.dart';

// ── Test repositories ─────────────────────────────────────────────────────────

final _testStats = DashboardStats(
  todaySales: 15000,
  transactionCount: 12,
  lowStockCount: 3,
  totalDebts: 8500,
  weeklyRevenue: [1000, 2000, 3000, 4000, 5000, 6000, 7000],
  activityFeed: [],
);

class _SuccessDashboardRepo implements IDashboardRepository {
  @override
  TaskEither<Failure, DashboardStats> getStats(String shopId) =>
      TaskEither.right(_testStats);
}

class _FailingDashboardRepo implements IDashboardRepository {
  final String message;
  _FailingDashboardRepo([this.message = 'Server error']);

  @override
  TaskEither<Failure, DashboardStats> getStats(String shopId) =>
      TaskEither.left(ServerFailure(message));
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── loadStats offline ─────────────────────────────────────────────────────

  group('DashboardProvider — loadStats offline', () {
    test('stats stays null with no cache and no network', () async {
      final p = buildDashboardProvider(_SuccessDashboardRepo(), online: false);
      await p.loadStats('shop-1');
      expect(p.stats, isNull);
      expect(p.isLoading, isFalse);
    });
  });

  // ── loadStats online ──────────────────────────────────────────────────────

  group('DashboardProvider — loadStats online success', () {
    test('populates stats from repo', () async {
      final p = buildDashboardProvider(_SuccessDashboardRepo(), online: true);
      await p.loadStats('shop-1');
      expect(p.stats, isNotNull);
      expect(p.stats!.todaySales, 15000);
      expect(p.stats!.transactionCount, 12);
      expect(p.isLoading, isFalse);
      expect(p.isRefreshing, isFalse);
    });

    test('weeklyRevenue and totalDebts are populated', () async {
      final p = buildDashboardProvider(_SuccessDashboardRepo(), online: true);
      await p.loadStats('shop-1');
      expect(p.stats!.weeklyRevenue, hasLength(7));
      expect(p.stats!.totalDebts, 8500);
    });
  });

  group('DashboardProvider — loadStats online failure', () {
    test('sets errorMessage when stats is null', () async {
      final p = buildDashboardProvider(_FailingDashboardRepo('No data'),
          online: true);
      await p.loadStats('shop-1');
      expect(p.errorMessage, 'No data');
      expect(p.stats, isNull);
      expect(p.isLoading, isFalse);
    });
  });

  // ── invalidateCache ───────────────────────────────────────────────────────

  group('DashboardProvider — invalidateCache', () {
    test('clears stats', () async {
      final p = buildDashboardProvider(_SuccessDashboardRepo(), online: true);
      await p.loadStats('shop-1');
      expect(p.stats, isNotNull);

      await p.invalidateCache(shopId: 'shop-1');
      expect(p.stats, isNull);
    });
  });
}
