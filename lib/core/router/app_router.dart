import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopkeeper/features/ai_chat/presentation/screens/ai_chat_screen.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/auth/presentation/screens/login_screen.dart';
import 'package:shopkeeper/features/auth/presentation/screens/register_screen.dart';
import 'package:shopkeeper/features/auth/presentation/screens/register_shop_screen.dart';
import 'package:shopkeeper/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:shopkeeper/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:shopkeeper/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:shopkeeper/features/auth/presentation/screens/owner_profile_screen.dart';
import 'package:shopkeeper/features/auth/presentation/screens/splash_screen.dart';
import 'package:shopkeeper/features/auth/presentation/screens/staff_profile_screen.dart';
import 'package:shopkeeper/features/dashboard/presentation/screens/owner_dashboard_screen.dart';
import 'package:shopkeeper/features/debts/presentation/screens/customer_debts_screen.dart';
import 'package:shopkeeper/features/debts/presentation/screens/customer_detail_screen.dart';
import 'package:shopkeeper/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:shopkeeper/features/products/presentation/screens/edit_product_screen.dart';
import 'package:shopkeeper/features/products/presentation/screens/products_screen.dart';
import 'package:shopkeeper/core/widgets/role_shell.dart';
import 'package:shopkeeper/features/sales/presentation/screens/sale_detail_screen.dart';
import 'package:shopkeeper/features/sales/presentation/screens/sales_history_screen.dart';
import 'package:shopkeeper/features/staff/presentation/screens/sale_confirm_screen.dart';
import 'package:shopkeeper/features/staff/presentation/screens/staff_home_screen.dart';
import 'package:shopkeeper/features/staff/presentation/screens/price_list_screen.dart';
import 'package:shopkeeper/features/staff/presentation/screens/new_sale_screen.dart';
import 'package:shopkeeper/features/staff/presentation/screens/payment_screen.dart';
import 'package:shopkeeper/features/onboarding/presentation/screens/onboarding_page_view.dart';
import 'package:shopkeeper/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:shopkeeper/features/staff/presentation/screens/create_staff_screen.dart';

class AppRouter {
  static GoRouter create({
    required AuthProvider authProvider,
    required OnboardingProvider onboardingProvider,
  }) =>
      GoRouter(
        // Re-run the redirect whenever auth or onboarding state changes.
        refreshListenable: Listenable.merge([authProvider, onboardingProvider]),
        redirect: (context, state) {
          final isLoggedIn = authProvider.currentUser != null;
          final location = state.matchedLocation;

          final isGoingToPublic = location == '/login' ||
              location == '/splash' ||
              location == '/register' ||
              location == '/forgot-password';
          final isGoingToOnboarding = location == '/onboarding';
          final isGoingToVerifyEmail = location == '/verify-email';
          final isGoingToRegisterShop = location == '/register-shop';

          // 1. Unauthenticated users can only access public/onboarding screens.
          if (!isLoggedIn && !isGoingToPublic && !isGoingToOnboarding) {
            return '/splash';
          }

          // 2. Authenticated routing.
          if (isLoggedIn) {
            final user = authProvider.currentUser!;
            final isOwner = user.role.name == 'owner';

            // Step A — Owner must verify email before anything else.
            if (isOwner && !user.emailVerified) {
              return isGoingToVerifyEmail ? null : '/verify-email';
            }

            // Step B — Owner must register a shop before accessing the app.
            if (isOwner && user.shopId.isEmpty) {
              return isGoingToRegisterShop ? null : '/register-shop';
            }

            // Step C — Fully set-up user landing on a public/setup screen → home.
            if (isGoingToPublic ||
                isGoingToOnboarding ||
                isGoingToVerifyEmail ||
                isGoingToRegisterShop) {
              return isOwner ? '/owner/dashboard' : '/staff/home';
            }
          }

          return null;
        },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPageView(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/register-shop',
        builder: (context, state) => const RegisterShopScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => ResetPasswordScreen(
          email: state.extra as String? ?? '',
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => OwnerShell(location: state.uri.toString(), child: child),
        routes: [
          GoRoute(
            path: '/owner/dashboard',
            builder: (context, state) => const OwnerDashboardScreen(),
          ),
          GoRoute(
            path: '/owner/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/owner/profile',
            builder: (context, state) => const OwnerProfileScreen(),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => StaffShell(location: state.uri.toString(), child: child),
        routes: [
          GoRoute(
            path: '/staff/home',
            builder: (context, state) => const StaffHomeScreen(),
          ),
          GoRoute(
            path: '/staff/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/staff/profile',
            builder: (context, state) => const StaffProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/owner/products',
        builder: (context, state) => const ProductsScreen(),
      ),
      GoRoute(
        path: '/owner/products/add',
        builder: (context, state) => const EditProductScreen(),
      ),
      GoRoute(
        path: '/owner/products/:id/edit',
        builder: (context, state) {
          final productId = state.pathParameters['id'];
          return EditProductScreen(productId: productId);
        },
      ),
      GoRoute(
        path: '/owner/sales',
        builder: (context, state) => const SalesHistoryScreen(),
      ),
      GoRoute(
        path: '/owner/sales/:id',
        builder: (context, state) {
          final saleId = state.pathParameters['id'];
          return SaleDetailScreen(saleId: saleId!);
        },
      ),
      GoRoute(
        path: '/owner/debts',
        builder: (context, state) => const CustomerDebtsScreen(),
      ),
      GoRoute(
        path: '/owner/debts/:customerId',
        builder: (context, state) {
          final customerId = state.pathParameters['customerId'];
          return CustomerDetailScreen(customerId: customerId!);
        },
      ),
      GoRoute(
        path: '/owner/chat',
        builder: (context, state) => const AiChatScreen(),
      ),
      GoRoute(
        path: '/owner/staff/create',
        builder: (context, state) => const CreateStaffScreen(),
      ),
      GoRoute(
        path: '/staff/prices',
        builder: (context, state) => const PriceListScreen(),
      ),
      GoRoute(
        path: '/staff/sale/new',
        pageBuilder: (context, state) => const MaterialPage(
          fullscreenDialog: true,
          child: NewSaleScreen(),
        ),
      ),
      GoRoute(
        path: '/staff/sale/payment',
        pageBuilder: (context, state) => const MaterialPage(
          fullscreenDialog: true,
          child: PaymentScreen(),
        ),
      ),
      GoRoute(
        path: '/staff/sale/confirm',
        pageBuilder: (context, state) => const MaterialPage(
          fullscreenDialog: true,
          child: SaleConfirmScreen(),
        ),
      ),
    ],
    initialLocation: '/splash',
  );
}
