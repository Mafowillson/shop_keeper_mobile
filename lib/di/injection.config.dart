// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shopkeeper/features/ai_chat/domain/repositories/i_chat_repository.dart'
    as _i331;
import 'package:shopkeeper/features/ai_chat/domain/usecases/load_history_usecase.dart'
    as _i811;
import 'package:shopkeeper/features/ai_chat/domain/usecases/send_message_usecase.dart'
    as _i521;
import 'package:shopkeeper/features/ai_chat/presentation/providers/chat_provider.dart'
    as _i197;
import 'package:shopkeeper/features/auth/data/datasources/i_auth_local_datasource.dart'
    as _i439;
import 'package:shopkeeper/features/auth/data/datasources/i_auth_remote_datasource.dart'
    as _i587;
import 'package:shopkeeper/features/auth/data/datasources/mock_auth_local_datasource.dart'
    as _i543;
import 'package:shopkeeper/features/auth/data/datasources/mock_auth_remote_datasource.dart'
    as _i274;
import 'package:shopkeeper/features/auth/data/repositories/auth_repository_impl.dart'
    as _i375;
import 'package:shopkeeper/features/auth/domain/repositories/i_auth_repository.dart'
    as _i696;
import 'package:shopkeeper/features/auth/domain/usecases/forgot_password_usecase.dart'
    as _i751;
import 'package:shopkeeper/features/auth/domain/usecases/login_usecase.dart'
    as _i917;
import 'package:shopkeeper/features/auth/domain/usecases/logout_usecase.dart'
    as _i894;
import 'package:shopkeeper/features/auth/domain/usecases/register_shop_usecase.dart'
    as _i325;
import 'package:shopkeeper/features/auth/domain/usecases/register_usecase.dart'
    as _i221;
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart'
    as _i287;
import 'package:shopkeeper/features/dashboard/data/datasources/i_dashboard_datasource.dart'
    as _i583;
import 'package:shopkeeper/features/dashboard/data/datasources/mock_dashboard_datasource.dart'
    as _i206;
import 'package:shopkeeper/features/dashboard/data/repositories/dashboard_repository_impl.dart'
    as _i855;
import 'package:shopkeeper/features/dashboard/domain/repositories/i_dashboard_repository.dart'
    as _i22;
import 'package:shopkeeper/features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart'
    as _i262;
import 'package:shopkeeper/features/dashboard/presentation/providers/dashboard_provider.dart'
    as _i70;
import 'package:shopkeeper/features/debts/domain/repositories/i_debt_repository.dart'
    as _i965;
import 'package:shopkeeper/features/debts/domain/usecases/get_customers_usecase.dart'
    as _i326;
import 'package:shopkeeper/features/debts/domain/usecases/get_debt_history_usecase.dart'
    as _i968;
import 'package:shopkeeper/features/debts/domain/usecases/record_payment_usecase.dart'
    as _i229;
import 'package:shopkeeper/features/debts/presentation/providers/debt_provider.dart'
    as _i635;
import 'package:shopkeeper/features/notifications/domain/repositories/i_notification_repository.dart'
    as _i159;
import 'package:shopkeeper/features/notifications/domain/usecases/get_notifications_usecase.dart'
    as _i217;
import 'package:shopkeeper/features/notifications/domain/usecases/mark_all_read_usecase.dart'
    as _i62;
import 'package:shopkeeper/features/notifications/domain/usecases/mark_read_usecase.dart'
    as _i609;
import 'package:shopkeeper/features/notifications/presentation/providers/notification_provider.dart'
    as _i995;
import 'package:shopkeeper/features/onboarding/presentation/providers/onboarding_provider.dart'
    as _i379;
import 'package:shopkeeper/features/products/data/datasources/i_product_local_datasource.dart'
    as _i987;
import 'package:shopkeeper/features/products/data/datasources/i_product_remote_datasource.dart'
    as _i773;
import 'package:shopkeeper/features/products/data/datasources/mock_product_local_datasource.dart'
    as _i285;
import 'package:shopkeeper/features/products/data/datasources/mock_product_remote_datasource.dart'
    as _i637;
import 'package:shopkeeper/features/products/data/repositories/product_repository_impl.dart'
    as _i367;
import 'package:shopkeeper/features/products/domain/repositories/i_product_repository.dart'
    as _i289;
import 'package:shopkeeper/features/products/domain/usecases/deactivate_product_usecase.dart'
    as _i678;
import 'package:shopkeeper/features/products/domain/usecases/get_product_by_id_usecase.dart'
    as _i1022;
import 'package:shopkeeper/features/products/domain/usecases/get_products_usecase.dart'
    as _i835;
import 'package:shopkeeper/features/products/domain/usecases/save_product_usecase.dart'
    as _i559;
import 'package:shopkeeper/features/products/domain/usecases/search_products_usecase.dart'
    as _i621;
import 'package:shopkeeper/features/products/presentation/providers/product_provider.dart'
    as _i964;
import 'package:shopkeeper/features/sales/domain/repositories/i_sale_repository.dart'
    as _i363;
import 'package:shopkeeper/features/sales/domain/usecases/get_sale_detail_usecase.dart'
    as _i329;
import 'package:shopkeeper/features/sales/domain/usecases/get_sales_usecase.dart'
    as _i262;
import 'package:shopkeeper/features/sales/domain/usecases/record_sale_usecase.dart'
    as _i478;
import 'package:shopkeeper/features/sales/presentation/providers/cart_provider.dart'
    as _i902;
import 'package:shopkeeper/features/sales/presentation/providers/sales_provider.dart'
    as _i852;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<_i379.OnboardingProvider>(() => _i379.OnboardingProvider());
    gh.factory<_i902.CartProvider>(() => _i902.CartProvider());
    gh.lazySingleton<_i987.IProductLocalDataSource>(
        () => _i285.MockProductLocalDataSource());
    gh.lazySingleton<_i583.IDashboardLocalDataSource>(
        () => _i206.MockDashboardLocalDataSource());
    gh.lazySingleton<_i326.GetCustomersUseCase>(
        () => _i326.GetCustomersUseCase(gh<_i965.IDebtRepository>()));
    gh.lazySingleton<_i968.GetDebtHistoryUseCase>(
        () => _i968.GetDebtHistoryUseCase(gh<_i965.IDebtRepository>()));
    gh.lazySingleton<_i229.RecordPaymentUseCase>(
        () => _i229.RecordPaymentUseCase(gh<_i965.IDebtRepository>()));
    gh.lazySingleton<_i217.GetNotificationsUseCase>(() =>
        _i217.GetNotificationsUseCase(gh<_i159.INotificationRepository>()));
    gh.lazySingleton<_i62.MarkAllReadUseCase>(
        () => _i62.MarkAllReadUseCase(gh<_i159.INotificationRepository>()));
    gh.lazySingleton<_i609.MarkReadUseCase>(
        () => _i609.MarkReadUseCase(gh<_i159.INotificationRepository>()));
    gh.lazySingleton<_i329.GetSaleDetailUseCase>(
        () => _i329.GetSaleDetailUseCase(gh<_i363.ISaleRepository>()));
    gh.lazySingleton<_i262.GetSalesUseCase>(
        () => _i262.GetSalesUseCase(gh<_i363.ISaleRepository>()));
    gh.lazySingleton<_i583.IDashboardRemoteDataSource>(
        () => _i206.MockDashboardRemoteDataSource());
    gh.lazySingleton<_i439.IAuthLocalDataSource>(
        () => _i543.MockAuthLocalDataSource());
    gh.lazySingleton<_i811.LoadHistoryUseCase>(
        () => _i811.LoadHistoryUseCase(gh<_i331.IChatRepository>()));
    gh.lazySingleton<_i521.SendMessageUseCase>(
        () => _i521.SendMessageUseCase(gh<_i331.IChatRepository>()));
    gh.lazySingleton<_i773.IProductRemoteDataSource>(
        () => _i637.MockProductRemoteDataSource());
    gh.lazySingleton<_i289.IProductRepository>(
        () => _i367.ProductRepositoryImpl(
              gh<_i773.IProductRemoteDataSource>(),
              gh<_i987.IProductLocalDataSource>(),
            ));
    gh.lazySingleton<_i587.IAuthRemoteDataSource>(
        () => _i274.MockAuthRemoteDataSource());
    gh.factory<_i995.NotificationProvider>(() => _i995.NotificationProvider(
          gh<_i217.GetNotificationsUseCase>(),
          gh<_i609.MarkReadUseCase>(),
          gh<_i62.MarkAllReadUseCase>(),
        ));
    gh.factory<_i197.ChatProvider>(() => _i197.ChatProvider(
          gh<_i521.SendMessageUseCase>(),
          gh<_i811.LoadHistoryUseCase>(),
        ));
    gh.lazySingleton<_i678.DeactivateProductUseCase>(
        () => _i678.DeactivateProductUseCase(gh<_i289.IProductRepository>()));
    gh.lazySingleton<_i1022.GetProductByIdUseCase>(
        () => _i1022.GetProductByIdUseCase(gh<_i289.IProductRepository>()));
    gh.lazySingleton<_i835.GetProductsUseCase>(
        () => _i835.GetProductsUseCase(gh<_i289.IProductRepository>()));
    gh.lazySingleton<_i559.SaveProductUseCase>(
        () => _i559.SaveProductUseCase(gh<_i289.IProductRepository>()));
    gh.lazySingleton<_i621.SearchProductsUseCase>(
        () => _i621.SearchProductsUseCase(gh<_i289.IProductRepository>()));
    gh.lazySingleton<_i478.RecordSaleUseCase>(() => _i478.RecordSaleUseCase(
          gh<_i363.ISaleRepository>(),
          gh<_i289.IProductRepository>(),
        ));
    gh.factory<_i964.ProductProvider>(() => _i964.ProductProvider(
          gh<_i835.GetProductsUseCase>(),
          gh<_i559.SaveProductUseCase>(),
          gh<_i678.DeactivateProductUseCase>(),
          gh<_i621.SearchProductsUseCase>(),
        ));
    gh.lazySingleton<_i22.IDashboardRepository>(
        () => _i855.DashboardRepositoryImpl(
              gh<_i583.IDashboardRemoteDataSource>(),
              gh<_i583.IDashboardLocalDataSource>(),
            ));
    gh.factory<_i635.DebtProvider>(() => _i635.DebtProvider(
          gh<_i326.GetCustomersUseCase>(),
          gh<_i968.GetDebtHistoryUseCase>(),
          gh<_i229.RecordPaymentUseCase>(),
        ));
    gh.lazySingleton<_i696.IAuthRepository>(() => _i375.AuthRepositoryImpl(
          gh<_i587.IAuthRemoteDataSource>(),
          gh<_i439.IAuthLocalDataSource>(),
        ));
    gh.lazySingleton<_i262.GetDashboardStatsUseCase>(
        () => _i262.GetDashboardStatsUseCase(gh<_i22.IDashboardRepository>()));
    gh.factory<_i852.SalesProvider>(() => _i852.SalesProvider(
          gh<_i262.GetSalesUseCase>(),
          gh<_i329.GetSaleDetailUseCase>(),
          gh<_i478.RecordSaleUseCase>(),
        ));
    gh.lazySingleton<_i751.ForgotPasswordUseCase>(
        () => _i751.ForgotPasswordUseCase(gh<_i696.IAuthRepository>()));
    gh.lazySingleton<_i917.LoginUseCase>(
        () => _i917.LoginUseCase(gh<_i696.IAuthRepository>()));
    gh.lazySingleton<_i894.LogoutUseCase>(
        () => _i894.LogoutUseCase(gh<_i696.IAuthRepository>()));
    gh.lazySingleton<_i325.RegisterShopUseCase>(
        () => _i325.RegisterShopUseCase(gh<_i696.IAuthRepository>()));
    gh.lazySingleton<_i221.RegisterUseCase>(
        () => _i221.RegisterUseCase(gh<_i696.IAuthRepository>()));
    gh.factory<_i70.DashboardProvider>(
        () => _i70.DashboardProvider(gh<_i262.GetDashboardStatsUseCase>()));
    gh.factory<_i287.AuthProvider>(() => _i287.AuthProvider(
          gh<_i917.LoginUseCase>(),
          gh<_i894.LogoutUseCase>(),
          gh<_i221.RegisterUseCase>(),
          gh<_i325.RegisterShopUseCase>(),
          gh<_i751.ForgotPasswordUseCase>(),
        ));
    return this;
  }
}
