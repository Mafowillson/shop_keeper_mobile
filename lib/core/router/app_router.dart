import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/features/ai_chat/presentation/screens/ai_chat_screen.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/auth/presentation/screens/login_screen.dart';
import 'package:shopkeeper/features/auth/presentation/screens/register_screen.dart';
import 'package:shopkeeper/features/auth/presentation/screens/register_shop_screen.dart';
import 'package:shopkeeper/features/auth/presentation/screens/forgot_password_screen.dart';
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

class AppRouter {
  static final router = GoRouter(
    redirect: (context, state) {
      final authProvider = context.read<AuthProvider>();
      final onboardingProvider = context.read<OnboardingProvider>();
      final isLoggedIn = authProvider.currentUser != null;
      final location = state.matchedLocation;
      
      final isGoingToPublic = location == '/login' ||
          location == '/splash' ||
          location == '/register' ||
          location == '/forgot-password';
      final isGoingToOnboarding = location == '/onboarding';
      final isGoingToRegisterShop = location == '/register-shop';
      final hasSeenOnboarding = onboardingProvider.hasSeenOnboarding;

      // 1. Onboarding redirection
      if (!hasSeenOnboarding && !isGoingToOnboarding && !isLoggedIn) {
        return '/onboarding';
      }

      // 2. Anonymous redirection
      if (!isLoggedIn && !isGoingToPublic && !isGoingToOnboarding) {
        return '/splash';
      }

      // 3. Authenticated redirection
      if (isLoggedIn) {
        final user = authProvider.currentUser!;
        final isOwner = user.role.toString().contains('owner');
        
        // If owner has no registered shop, force shop onboarding
        if (isOwner && (user.shopId.isEmpty || user.shopId == 'pending')) {
          if (!isGoingToRegisterShop) {
            return '/register-shop';
          }
          return null; // Stay on register-shop
        }

        // If going to login/register or onboarding while fully registered, go to home
        if (isGoingToPublic || isGoingToOnboarding || isGoingToRegisterShop) {
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
