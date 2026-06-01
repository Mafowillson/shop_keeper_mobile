import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
import 'package:shopkeeper/core/network/dio_client.dart';
import 'package:shopkeeper/features/staff/data/datasources/staff_remote_datasource.dart';
import 'package:shopkeeper/features/staff/data/repositories/staff_repository_impl.dart';
import 'package:shopkeeper/features/staff/domain/usecases/create_staff_usecase.dart';
import 'package:shopkeeper/features/staff/presentation/providers/staff_provider.dart';

class ShopKeeperApp extends StatefulWidget {
  const ShopKeeperApp({super.key});

  @override
  State<ShopKeeperApp> createState() => _ShopKeeperAppState();
}

class _ShopKeeperAppState extends State<ShopKeeperApp> {
  late final AuthProvider _authProvider;
  late final OnboardingProvider _onboardingProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authProvider = getIt<AuthProvider>();
    _onboardingProvider = getIt<OnboardingProvider>();
    _router = AppRouter.create(
      authProvider: _authProvider,
      onboardingProvider: _onboardingProvider,
    );
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _onboardingProvider),
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider(create: (_) => getIt<DashboardProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<ProductProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<SalesProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<CartProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<DebtProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<NotificationProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<ChatProvider>()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
        ChangeNotifierProvider(
          create: (_) => StaffProvider(
            CreateStaffUseCase(
              StaffRepositoryImpl(
                StaffRemoteDataSource(getIt<DioClient>()),
              ),
            ),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'ShopKeeper',
        theme: AppTheme.ownerTheme(),
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
        restorationScopeId: 'app',
      ),
    );
  }
}
