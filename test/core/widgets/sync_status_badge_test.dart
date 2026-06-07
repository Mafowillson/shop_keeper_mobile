import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopkeeper/core/enums/sync_state.dart';
import 'package:shopkeeper/core/widgets/sync_status_badge.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  group('SyncStatusBadge', () {
    testWidgets('synced state shows Synced label', (tester) async {
      await tester.pumpWidget(_wrap(const SyncStatusBadge(SyncState.synced)));

      expect(find.text('Synced'), findsOneWidget);
    });

    testWidgets('synced state shows check_circle icon', (tester) async {
      await tester.pumpWidget(_wrap(const SyncStatusBadge(SyncState.synced)));

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('pending state shows Syncing... label', (tester) async {
      await tester.pumpWidget(_wrap(const SyncStatusBadge(SyncState.pending)));

      expect(find.text('Syncing...'), findsOneWidget);
    });

    testWidgets('pending state shows sync icon', (tester) async {
      await tester.pumpWidget(_wrap(const SyncStatusBadge(SyncState.pending)));

      expect(find.byIcon(Icons.sync), findsOneWidget);
    });

    testWidgets('error state shows Sync Error label', (tester) async {
      await tester.pumpWidget(_wrap(const SyncStatusBadge(SyncState.error)));

      expect(find.text('Sync Error'), findsOneWidget);
    });

    testWidgets('error state shows error icon', (tester) async {
      await tester.pumpWidget(_wrap(const SyncStatusBadge(SyncState.error)));

      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('each state renders exactly one icon', (tester) async {
      for (final state in SyncState.values) {
        await tester.pumpWidget(_wrap(SyncStatusBadge(state)));
        expect(find.byType(Icon), findsOneWidget,
            reason: 'Expected exactly one icon for state $state');
      }
    });

    testWidgets('each state renders exactly one text label', (tester) async {
      for (final state in SyncState.values) {
        await tester.pumpWidget(_wrap(SyncStatusBadge(state)));
        expect(find.byType(Text), findsOneWidget,
            reason: 'Expected exactly one Text for state $state');
      }
    });
  });
}
