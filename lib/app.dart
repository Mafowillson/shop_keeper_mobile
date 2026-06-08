import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shopkeeper/core/enums/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shopkeeper/core/cache/cache_metadata_service.dart';
import 'package:shopkeeper/core/cache/cache_service.dart';
import 'package:shopkeeper/core/enums/notification_type.dart';
import 'package:shopkeeper/l10n/app_localizations.dart';
import 'package:shopkeeper/core/router/app_router.dart';
import 'package:shopkeeper/core/services/fcm_service.dart';
import 'package:shopkeeper/core/theme/app_theme.dart';
import 'package:shopkeeper/di/injection.dart';
import 'package:shopkeeper/features/ai_chat/presentation/providers/chat_provider.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:shopkeeper/features/debts/data/datasources/debt_local_datasource.dart';
import 'package:shopkeeper/features/debts/presentation/providers/debt_provider.dart';
import 'package:shopkeeper/features/notifications/data/datasources/notification_local_datasource.dart';
import 'package:shopkeeper/features/notifications/presentation/providers/notification_provider.dart';
import 'package:shopkeeper/features/products/data/datasources/product_local_datasource.dart';
import 'package:shopkeeper/features/sales/data/datasources/sale_local_datasource.dart';
import 'package:shopkeeper/features/products/presentation/providers/product_provider.dart';
import 'package:shopkeeper/features/sales/presentation/providers/cart_provider.dart';
import 'package:shopkeeper/features/sales/presentation/providers/sales_provider.dart';
import 'package:shopkeeper/features/sales/presentation/providers/sync_provider.dart';
import 'package:shopkeeper/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:shopkeeper/core/network/dio_client.dart';
import 'package:shopkeeper/core/offline/connectivity_service.dart';
import 'package:shopkeeper/features/staff/data/datasources/staff_remote_datasource.dart';
import 'package:shopkeeper/features/staff/data/repositories/staff_repository_impl.dart';
import 'package:shopkeeper/features/staff/domain/usecases/create_staff_usecase.dart';
import 'package:shopkeeper/features/staff/presentation/providers/staff_dashboard_provider.dart';
import 'package:shopkeeper/features/settings/presentation/providers/settings_provider.dart';
import 'package:shopkeeper/features/staff/presentation/providers/staff_provider.dart';

class ShopKeeperApp extends StatefulWidget {
  const ShopKeeperApp({super.key});

  @override
  State<ShopKeeperApp> createState() => _ShopKeeperAppState();
}

class _ShopKeeperAppState extends State<ShopKeeperApp> {
  late final AuthProvider _authProvider;
  late final OnboardingProvider _onboardingProvider;
  late final NotificationProvider _notificationProvider;
  late final ProductProvider _productProvider;
  late final SyncProvider _syncProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authProvider = getIt<AuthProvider>();
    _onboardingProvider = getIt<OnboardingProvider>();
    _notificationProvider = getIt<NotificationProvider>();
    _productProvider = getIt<ProductProvider>();
    getIt<SettingsProvider>().init();

    _syncProvider = SyncProvider(
      connectivity: getIt<ConnectivityService>(),
      dioClient: getIt<DioClient>(),
      productLocal: getIt<ProductLocalDataSource>(),
      saleLocal: getIt<SaleLocalDataSource>(),
      debtLocal: getIt<DebtLocalDataSource>(),
      notifLocal: getIt<NotificationLocalDataSource>(),
      metadata: getIt<CacheMetadataService>(),
    );

    _router = AppRouter.create(
      authProvider: _authProvider,
      onboardingProvider: _onboardingProvider,
    );

    final fcm = getIt<FcmService>();

    // Upload FCM token on every auth state change (login, token refresh, etc.).
    _authProvider.addListener(() {
      final user = _authProvider.currentUser;
      if (user != null) {
        fcm.uploadTokenForRole(user.role);
        _syncProvider.initialize(user.shopId, role: user.role);
      } else {
        _syncProvider.stop();
        // Clear all cached data for security when the user logs out.
        getIt<CacheService>().invalidateAll();
      }
    });

    // Also upload immediately if the user is already logged in on cold start
    // (the listener above won't fire if the auth state was restored silently).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = _authProvider.currentUser;
      if (user != null) {
        fcm.uploadTokenForRole(user.role);
        _syncProvider.initialize(user.shopId, role: user.role);
      }
    });

    // Show banner + refresh data when a message arrives in the foreground.
    fcm.setupForegroundHandler(_onForegroundMessage);
  }

  void _onForegroundMessage(RemoteMessage message) {
    // Show a visible banner — Android suppresses FCM banners when the app is open.
    getIt<FcmService>().showForegroundNotification(message);

    final typeStr = message.data['type'] as String? ?? '';
    final type = _notifTypeFromString(typeStr);

    final user = _authProvider.currentUser;
    final isStaff = user?.role == UserRole.staff;

    if (type == NotificationType.productAdded ||
        type == NotificationType.productUpdated ||
        type == NotificationType.productDeleted) {
      if (user != null && user.shopId.isNotEmpty) {
        _productProvider.loadProducts(user.shopId);
      }
      // Refresh staff notification inbox badge for product events.
      if (isStaff) _notificationProvider.loadNotifications(isStaff: true);
    } else {
      _notificationProvider.loadNotifications(
        isStaff: isStaff,
        shopId: isStaff ? null : user?.shopId,
      );
    }
  }

  NotificationType _notifTypeFromString(String s) {
    switch (s) {
      case 'product_added':
        return NotificationType.productAdded;
      case 'product_updated':
        return NotificationType.productUpdated;
      case 'product_deleted':
        return NotificationType.productDeleted;
      default:
        return NotificationType.lowStock;
    }
  }

  @override
  void dispose() {
    _syncProvider.dispose();
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
        ChangeNotifierProvider.value(value: _productProvider),
        ChangeNotifierProvider(create: (_) => getIt<SalesProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<CartProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<DebtProvider>()),
        ChangeNotifierProvider.value(value: _notificationProvider),
        ChangeNotifierProvider(create: (_) => getIt<StaffDashboardProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<ChatProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<SettingsProvider>()),
        ChangeNotifierProvider.value(value: _syncProvider),
        ChangeNotifierProvider.value(value: getIt<ConnectivityService>()),
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
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) => MaterialApp.router(
          title: 'ShopKeeper',
          theme: AppTheme.ownerTheme(),
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
          restorationScopeId: 'app',
          locale: settings.language != null ? Locale(settings.language!) : null,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('fr'),
            Locale('en'),
          ],
        ),
      ),
    );
  }
}
