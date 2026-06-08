import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/cache/cache_metadata_service.dart';
import 'package:shopkeeper/core/cache/cache_service.dart';
import 'package:shopkeeper/core/network/dio_client.dart';
import 'package:shopkeeper/core/network/token_storage.dart';
import 'package:shopkeeper/core/offline/connectivity_service.dart';
import 'package:shopkeeper/core/services/fcm_service.dart';
import 'package:shopkeeper/features/dashboard/data/datasources/dashboard_local_datasource.dart';
import 'package:shopkeeper/features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';
import 'package:shopkeeper/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:shopkeeper/features/debts/data/datasources/debt_local_datasource.dart';
import 'package:shopkeeper/features/debts/data/datasources/i_debt_remote_datasource.dart';
import 'package:shopkeeper/features/debts/data/repositories/debt_repository_impl.dart';
import 'package:shopkeeper/features/debts/domain/repositories/i_debt_repository.dart';
import 'package:shopkeeper/features/debts/domain/usecases/create_customer_usecase.dart';
import 'package:shopkeeper/features/debts/domain/usecases/get_customer_by_id_usecase.dart';
import 'package:shopkeeper/features/debts/domain/usecases/get_customers_usecase.dart';
import 'package:shopkeeper/features/debts/domain/usecases/get_debt_history_usecase.dart';
import 'package:shopkeeper/features/debts/domain/usecases/record_payment_usecase.dart';
import 'package:shopkeeper/features/debts/presentation/providers/debt_provider.dart';
import 'package:shopkeeper/features/notifications/data/datasources/notification_local_datasource.dart';
import 'package:shopkeeper/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:shopkeeper/features/notifications/domain/usecases/mark_all_read_usecase.dart';
import 'package:shopkeeper/features/notifications/domain/usecases/mark_read_usecase.dart';
import 'package:shopkeeper/features/notifications/presentation/providers/notification_provider.dart';
import 'package:shopkeeper/features/products/data/datasources/i_product_remote_datasource.dart';
import 'package:shopkeeper/features/products/data/datasources/product_local_datasource.dart';
import 'package:shopkeeper/features/products/data/repositories/product_repository_impl.dart';
import 'package:shopkeeper/features/products/domain/repositories/i_product_repository.dart';
import 'package:shopkeeper/features/products/domain/usecases/deactivate_product_usecase.dart';
import 'package:shopkeeper/features/products/domain/usecases/get_products_usecase.dart';
import 'package:shopkeeper/features/products/domain/usecases/save_product_usecase.dart';
import 'package:shopkeeper/features/products/domain/usecases/search_products_usecase.dart';
import 'package:shopkeeper/features/products/presentation/providers/product_provider.dart';
import 'package:shopkeeper/features/sales/data/datasources/i_sale_remote_datasource.dart';
import 'package:shopkeeper/features/sales/data/datasources/sale_local_datasource.dart';
import 'package:shopkeeper/features/sales/data/repositories/sale_repository_impl.dart';
import 'package:shopkeeper/features/sales/domain/repositories/i_sale_repository.dart';
import 'package:shopkeeper/features/sales/domain/usecases/get_sale_detail_usecase.dart';
import 'package:shopkeeper/features/sales/domain/usecases/get_sales_usecase.dart';
import 'package:shopkeeper/features/sales/domain/usecases/record_sale_usecase.dart';
import 'package:shopkeeper/features/sales/presentation/providers/sales_provider.dart';
import 'package:shopkeeper/features/settings/presentation/providers/settings_provider.dart';

import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() {
  // ── Infrastructure singletons ─────────────────────────────────────────────
  getIt.registerLazySingleton<TokenStorage>(
    () => TokenStorage(
      const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      ),
    ),
  );
  getIt.registerLazySingleton<DioClient>(
    () => DioClient(getIt<TokenStorage>(), getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<FcmService>(
    () => FcmService(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<SettingsProvider>(
    () => SettingsProvider(getIt<DioClient>()),
  );

  // ── Offline + cache layer ─────────────────────────────────────────────────
  getIt.registerLazySingleton<ConnectivityService>(
    () => ConnectivityService(),
  );
  getIt.registerLazySingleton<CacheMetadataService>(
    () => CacheMetadataService(),
  );
  getIt.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSource(getIt<CacheMetadataService>()),
  );
  getIt.registerLazySingleton<SaleLocalDataSource>(
    () => SaleLocalDataSource(getIt<CacheMetadataService>()),
  );
  getIt.registerLazySingleton<DebtLocalDataSource>(
    () => DebtLocalDataSource(getIt<CacheMetadataService>()),
  );
  getIt.registerLazySingleton<NotificationLocalDataSource>(
    () => NotificationLocalDataSource(getIt<CacheMetadataService>()),
  );
  getIt.registerLazySingleton<DashboardLocalDataSource>(
    () => DashboardLocalDataSource(getIt<CacheMetadataService>()),
  );
  getIt.registerLazySingleton<CacheService>(
    () => CacheService(
      products: getIt<ProductLocalDataSource>(),
      sales: getIt<SaleLocalDataSource>(),
      debts: getIt<DebtLocalDataSource>(),
      notifications: getIt<NotificationLocalDataSource>(),
      metadata: getIt<CacheMetadataService>(),
    ),
  );

  // ── Repositories (manually registered — include offline deps) ────────────
  getIt.registerLazySingleton<IProductRepository>(
    () => ProductRepositoryImpl(
      getIt<IProductRemoteDataSource>(),
      getIt<ProductLocalDataSource>(),
      getIt<ConnectivityService>(),
    ),
  );
  getIt.registerLazySingleton<ISaleRepository>(
    () => SaleRepositoryImpl(
      getIt<ISaleRemoteDataSource>(),
      getIt<SaleLocalDataSource>(),
      getIt<ProductLocalDataSource>(),
      getIt<ConnectivityService>(),
    ),
  );
  getIt.registerLazySingleton<IDebtRepository>(
    () => DebtRepositoryImpl(
      getIt<IDebtRemoteDataSource>(),
      getIt<DebtLocalDataSource>(),
      getIt<ConnectivityService>(),
    ),
  );

  // ── Providers (manually registered — include cache deps) ─────────────────
  getIt.registerFactory<ProductProvider>(
    () => ProductProvider(
      getIt<GetProductsUseCase>(),
      getIt<SaveProductUseCase>(),
      getIt<DeactivateProductUseCase>(),
      getIt<SearchProductsUseCase>(),
      getIt<ProductLocalDataSource>(),
      getIt<CacheMetadataService>(),
      getIt<ConnectivityService>(),
    ),
  );
  getIt.registerFactory<SalesProvider>(
    () => SalesProvider(
      getIt<GetSalesUseCase>(),
      getIt<GetSaleDetailUseCase>(),
      getIt<RecordSaleUseCase>(),
      getIt<SaleLocalDataSource>(),
      getIt<CacheMetadataService>(),
      getIt<ConnectivityService>(),
    ),
  );
  getIt.registerFactory<DebtProvider>(
    () => DebtProvider(
      getIt<GetCustomersUseCase>(),
      getIt<GetCustomerByIdUseCase>(),
      getIt<CreateCustomerUseCase>(),
      getIt<GetDebtHistoryUseCase>(),
      getIt<RecordPaymentUseCase>(),
      getIt<DebtLocalDataSource>(),
      getIt<CacheMetadataService>(),
      getIt<ConnectivityService>(),
    ),
  );
  getIt.registerFactory<NotificationProvider>(
    () => NotificationProvider(
      getIt<GetNotificationsUseCase>(),
      getIt<MarkReadUseCase>(),
      getIt<MarkAllReadUseCase>(),
      getIt<NotificationLocalDataSource>(),
      getIt<CacheMetadataService>(),
      getIt<ConnectivityService>(),
    ),
  );
  getIt.registerFactory<DashboardProvider>(
    () => DashboardProvider(
      getIt<GetDashboardStatsUseCase>(),
      getIt<DashboardLocalDataSource>(),
      getIt<CacheMetadataService>(),
      getIt<ConnectivityService>(),
    ),
  );

  // ── Injectable-generated registrations (use cases, datasources, etc.) ────
  getIt.init();
}
