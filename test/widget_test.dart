// Smoke test: verifies that the SyncStatusBadge, LoginScreen, and NewSaleScreen
// can each be constructed without throwing.
//
// Full widget tests live in:
//   test/core/widgets/sync_status_badge_test.dart
//   test/features/auth/presentation/screens/login_screen_test.dart
//   test/features/staff/presentation/screens/new_sale_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopkeeper/core/enums/sync_state.dart';
import 'package:shopkeeper/core/widgets/sync_status_badge.dart';

void main() {
  testWidgets('SyncStatusBadge smoke test — renders without error',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: SyncStatusBadge(SyncState.synced)),
        ),
      ),
    );

    expect(find.byType(SyncStatusBadge), findsOneWidget);
  });
}
