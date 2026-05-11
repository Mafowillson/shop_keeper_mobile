import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/router/app_router.dart';
import 'package:shopkeeper/core/theme/app_theme.dart';
import 'package:shopkeeper/di/injection.dart';
import 'package:shopkeeper/features/ai_chat/presentation/providers/chat_provider.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:shopkeeper/features/debts/presentation/providers/debt_provider.dart';
import 'package:shopkeeper/features/notifications/presentation/providers/notification_provider.dart';
import 'package:shopkeeper/features/products/presentation/providers/product_provider.dart';
import 'package:shopkeeper/features/sales/presentation/providers/cart_provider.dart';
import 'package:shopkeeper/features/sales/presentation/providers/sales_provider.dart';
import 'package:shopkeeper/features/sales/presentation/providers/sync_provider.dart';
import 'package:shopkeeper/features/onboarding/presentation/providers/onboarding_provider.dart';

class ShopKeeperApp extends StatelessWidget {
  const ShopKeeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<OnboardingProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<DashboardProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<ProductProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<SalesProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<CartProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<DebtProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<NotificationProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<ChatProvider>()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
      ],
      child: MaterialApp.router(
        title: 'ShopKeeper',
        theme: AppTheme.ownerTheme(),
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
        restorationScopeId: 'app',
      ),
    );
  }
}
