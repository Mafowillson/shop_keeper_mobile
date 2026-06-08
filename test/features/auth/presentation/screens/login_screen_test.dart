import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/auth/presentation/screens/login_screen.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';

import '../../../../helpers/fake_providers.dart';

GoRouter _router() => GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(
            path: '/register',
            builder: (_, __) => const Scaffold(body: Text('Register'))),
        GoRoute(
            path: '/forgot-password',
            builder: (_, __) => const Scaffold(body: Text('Forgot'))),
        GoRoute(
            path: '/owner/dashboard',
            builder: (_, __) => const Scaffold(body: Text('Dashboard'))),
        GoRoute(
            path: '/staff/home',
            builder: (_, __) => const Scaffold(body: Text('Staff Home'))),
      ],
    );

Widget _buildTestApp(FakeAuthProvider auth) =>
    ChangeNotifierProvider<AuthProvider>.value(
      value: auth,
      child: MaterialApp.router(
        routerConfig: _router(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );

void main() {
  group('LoginScreen — static content', () {
    testWidgets('shows app name ShopKeeper in hero panel', (tester) async {
      await tester.pumpWidget(_buildTestApp(FakeAuthProvider()));
      await tester.pumpAndSettle();

      expect(find.text('ShopKeeper'), findsOneWidget);
    });

    testWidgets('shows storefront icon in hero panel', (tester) async {
      await tester.pumpWidget(_buildTestApp(FakeAuthProvider()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.storefront_rounded), findsOneWidget);
    });

    testWidgets('shows Welcome back heading', (tester) async {
      await tester.pumpWidget(_buildTestApp(FakeAuthProvider()));
      await tester.pumpAndSettle();

      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('shows sign-in subtitle', (tester) async {
      await tester.pumpWidget(_buildTestApp(FakeAuthProvider()));
      await tester.pumpAndSettle();

      expect(find.text('Sign in to continue'), findsOneWidget);
    });

    testWidgets('shows Owner and Staff role tabs', (tester) async {
      await tester.pumpWidget(_buildTestApp(FakeAuthProvider()));
      await tester.pumpAndSettle();

      expect(find.text('Owner'), findsOneWidget);
      expect(find.text('Staff'), findsOneWidget);
    });

    testWidgets('shows Sign In button', (tester) async {
      await tester.pumpWidget(_buildTestApp(FakeAuthProvider()));
      await tester.pumpAndSettle();

      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('shows Create an account link', (tester) async {
      await tester.pumpWidget(_buildTestApp(FakeAuthProvider()));
      await tester.pumpAndSettle();

      expect(find.text('Create an account'), findsOneWidget);
    });
  });

  group('LoginScreen — Owner role (default)', () {
    testWidgets('shows Email field label', (tester) async {
      await tester.pumpWidget(_buildTestApp(FakeAuthProvider()));
      await tester.pumpAndSettle();

      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('shows Password field label', (tester) async {
      await tester.pumpWidget(_buildTestApp(FakeAuthProvider()));
      await tester.pumpAndSettle();

      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('shows Forgot password? link', (tester) async {
      await tester.pumpWidget(_buildTestApp(FakeAuthProvider()));
      await tester.pumpAndSettle();

      expect(find.text('Forgot password?'), findsOneWidget);
    });

    testWidgets('shows email icon', (tester) async {
      await tester.pumpWidget(_buildTestApp(FakeAuthProvider()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    testWidgets('shows password visibility toggle icon', (tester) async {
      await tester.pumpWidget(_buildTestApp(FakeAuthProvider()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });
  });

  group('LoginScreen — Staff role', () {
    testWidgets('switching to Staff tab hides Forgot password?',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(FakeAuthProvider()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Staff'));
      await tester.pumpAndSettle();

      expect(find.text('Forgot password?'), findsNothing);
    });

    testWidgets('switching to Staff tab shows Phone Number label',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(FakeAuthProvider()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Staff'));
      await tester.pumpAndSettle();

      expect(find.text('Phone Number'), findsOneWidget);
    });

    testWidgets('switching to Staff tab shows phone icon', (tester) async {
      await tester.pumpWidget(_buildTestApp(FakeAuthProvider()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Staff'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.phone_outlined), findsOneWidget);
    });

    testWidgets('switching to Staff tab hides password visibility icon',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(FakeAuthProvider()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Staff'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_outlined), findsNothing);
    });
  });

  group('LoginScreen — loading state', () {
    testWidgets('Sign In button shows spinner when isLoading is true',
        (tester) async {
      final auth = FakeAuthProvider(isLoading: true);
      await tester.pumpWidget(_buildTestApp(auth));
      await tester
          .pump(); // don't settle — CircularProgressIndicator never stops

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('ElevatedButton is disabled when isLoading is true',
        (tester) async {
      final auth = FakeAuthProvider(isLoading: true);
      await tester.pumpWidget(_buildTestApp(auth));
      await tester.pump();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });
  });
}
