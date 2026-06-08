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
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:shopkeeper/core/network/dio_client.dart' as _i36;
import 'package:shopkeeper/core/network/token_storage.dart' as _i26;
import 'package:shopkeeper/features/ai_chat/data/datasources/chat_remote_datasource_impl.dart'
    as _i69;
import 'package:shopkeeper/features/ai_chat/data/datasources/i_chat_remote_datasource.dart'
    as _i448;
import 'package:shopkeeper/features/ai_chat/data/repositories/chat_repository_impl.dart'
    as _i659;
import 'package:shopkeeper/features/ai_chat/domain/repositories/i_chat_repository.dart'
    as _i331;
import 'package:shopkeeper/features/ai_chat/domain/usecases/clear_history_usecase.dart'
    as _i420;
import 'package:shopkeeper/features/ai_chat/domain/usecases/load_history_usecase.dart'
    as _i811;
import 'package:shopkeeper/features/ai_chat/domain/usecases/send_message_usecase.dart'
    as _i521;
import 'package:shopkeeper/features/ai_chat/presentation/providers/chat_provider.dart'
    as _i197;
import 'package:shopkeeper/features/auth/data/datasources/auth_local_datasource.dart'
    as _i211;
import 'package:shopkeeper/features/auth/data/datasources/auth_remote_datasource.dart'
    as _i503;
import 'package:shopkeeper/features/auth/data/datasources/i_auth_local_datasource.dart'
    as _i439;
import 'package:shopkeeper/features/auth/data/datasources/i_auth_remote_datasource.dart'
    as _i587;
import 'package:shopkeeper/features/auth/data/repositories/auth_repository_impl.dart'
    as _i375;
import 'package:shopkeeper/features/auth/domain/repositories/i_auth_repository.dart'
    as _i696;
import 'package:shopkeeper/features/auth/domain/usecases/forgot_password_usecase.dart'
    as _i751;
import 'package:shopkeeper/features/auth/domain/usecases/get_shop_info_usecase.dart'
    as _i723;
import 'package:shopkeeper/features/auth/domain/usecases/login_usecase.dart'
    as _i917;
import 'package:shopkeeper/features/auth/domain/usecases/logout_usecase.dart'
    as _i894;
import 'package:shopkeeper/features/auth/domain/usecases/register_shop_usecase.dart'
    as _i325;
import 'package:shopkeeper/features/auth/domain/usecases/register_usecase.dart'
    as _i221;
import 'package:shopkeeper/features/auth/domain/usecases/resend_verification_usecase.dart'
    as _i1025;
import 'package:shopkeeper/features/auth/domain/usecases/reset_password_usecase.dart'
    as _i1019;
import 'package:shopkeeper/features/auth/domain/usecases/restore_session_usecase.dart'
    as _i579;
import 'package:shopkeeper/features/auth/domain/usecases/fetch_all_shops_usecase.dart'
    as _i482;
import 'package:shopkeeper/features/auth/domain/usecases/switch_active_shop_usecase.dart'
    as _i774;
import 'package:shopkeeper/features/auth/domain/usecases/update_shop_usecase.dart'
    as _i631;
import 'package:shopkeeper/features/auth/domain/usecases/verify_email_usecase.dart'
    as _i414;
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart'
    as _i287;
import 'package:shopkeeper/features/dashboard/data/datasources/dashboard_remote_datasource_impl.dart'
    as _i586;
import 'package:shopkeeper/features/dashboard/data/datasources/i_dashboard_datasource.dart'
    as _i583;
import 'package:shopkeeper/features/dashboard/data/repositories/dashboard_repository_impl.dart'
    as _i855;
import 'package:shopkeeper/features/dashboard/domain/repositories/i_dashboard_repository.dart'
    as _i22;
import 'package:shopkeeper/features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart'
    as _i262;
import 'package:shopkeeper/features/dashboard/presentation/providers/dashboard_provider.dart'
    as _i70;
import 'package:shopkeeper/features/debts/data/datasources/debt_remote_datasource_impl.dart'
    as _i235;
import 'package:shopkeeper/features/debts/data/datasources/i_debt_remote_datasource.dart'
    as _i179;
import 'package:shopkeeper/features/debts/data/repositories/debt_repository_impl.dart'
    as _i143;
import 'package:shopkeeper/features/debts/domain/repositories/i_debt_repository.dart'
    as _i965;
import 'package:shopkeeper/features/debts/domain/usecases/create_customer_usecase.dart'
    as _i91;
import 'package:shopkeeper/features/debts/domain/usecases/get_customer_by_id_usecase.dart'
    as _i910;
import 'package:shopkeeper/features/debts/domain/usecases/get_customers_usecase.dart'
    as _i326;
import 'package:shopkeeper/features/debts/domain/usecases/get_debt_history_usecase.dart'
    as _i968;
import 'package:shopkeeper/features/debts/domain/usecases/record_payment_usecase.dart'
    as _i229;
import 'package:shopkeeper/features/debts/presentation/providers/debt_provider.dart'
    as _i635;
import 'package:shopkeeper/features/notifications/data/datasources/i_notification_remote_datasource.dart'
    as _i553;
import 'package:shopkeeper/features/notifications/data/datasources/notification_remote_datasource_impl.dart'
    as _i192;
import 'package:shopkeeper/features/notifications/data/repositories/notification_repository_impl.dart'
    as _i683;
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
import 'package:shopkeeper/features/products/data/datasources/i_product_remote_datasource.dart'
    as _i773;
import 'package:shopkeeper/features/products/data/datasources/product_remote_datasource_impl.dart'
    as _i760;
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
import 'package:shopkeeper/features/sales/data/datasources/i_sale_remote_datasource.dart'
    as _i36;
import 'package:shopkeeper/features/sales/data/datasources/sale_remote_datasource_impl.dart'
    as _i609;
import 'package:shopkeeper/features/sales/data/repositories/sale_repository_impl.dart'
    as _i937;
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
import 'package:shopkeeper/features/staff/data/datasources/staff_dashboard_datasource.dart'
    as _i862;
import 'package:shopkeeper/features/staff/data/repositories/staff_dashboard_repository_impl.dart'
    as _i368;
import 'package:shopkeeper/features/staff/domain/repositories/i_staff_dashboard_repository.dart'
    as _i916;
import 'package:shopkeeper/features/staff/domain/usecases/get_staff_dashboard_usecase.dart'
    as _i454;
import 'package:shopkeeper/features/staff/presentation/providers/staff_dashboard_provider.dart'
    as _i50;

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
    gh.factory<_i902.CartProvider>(() => _i902.CartProvider());
    gh.lazySingleton<_i448.IChatRemoteDataSource>(
        () => _i69.ChatRemoteDataSourceImpl(gh<_i36.DioClient>()));
    gh.lazySingleton<_i862.IStaffDashboardDataSource>(
        () => _i862.StaffDashboardDataSourceImpl(gh<_i36.DioClient>()));
    gh.lazySingleton<_i439.IAuthLocalDataSource>(
        () => _i211.AuthLocalDataSource());
    gh.lazySingleton<_i773.IProductRemoteDataSource>(
        () => _i760.ProductRemoteDataSourceImpl(gh<_i36.DioClient>()));
    gh.lazySingleton<_i583.IDashboardRemoteDataSource>(
        () => _i586.DashboardRemoteDataSourceImpl(gh<_i36.DioClient>()));
    // IProductRepository is registered manually in injection.dart.
    gh.lazySingleton<_i553.INotificationRemoteDataSource>(
        () => _i192.NotificationRemoteDataSourceImpl(gh<_i36.DioClient>()));
    gh.lazySingleton<_i36.ISaleRemoteDataSource>(
        () => _i609.SaleRemoteDataSourceImpl(gh<_i36.DioClient>()));
    gh.lazySingleton<_i22.IDashboardRepository>(() =>
        _i855.DashboardRepositoryImpl(gh<_i583.IDashboardRemoteDataSource>()));
    gh.lazySingleton<_i179.IDebtRemoteDataSource>(
        () => _i235.DebtRemoteDataSourceImpl(gh<_i36.DioClient>()));
    // ISaleRepository is registered manually in injection.dart.
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
    gh.lazySingleton<_i262.GetDashboardStatsUseCase>(
        () => _i262.GetDashboardStatsUseCase(gh<_i22.IDashboardRepository>()));
    gh.factory<_i379.OnboardingProvider>(
        () => _i379.OnboardingProvider(gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i916.IStaffDashboardRepository>(() =>
        _i368.StaffDashboardRepositoryImpl(
            gh<_i862.IStaffDashboardDataSource>()));
    // ProductProvider is registered manually in injection.dart.
    gh.lazySingleton<_i587.IAuthRemoteDataSource>(
        () => _i503.AuthRemoteDataSource(
              gh<_i36.DioClient>(),
              gh<_i26.TokenStorage>(),
            ));
    gh.lazySingleton<_i478.RecordSaleUseCase>(
        () => _i478.RecordSaleUseCase(gh<_i363.ISaleRepository>()));
    gh.lazySingleton<_i331.IChatRepository>(
        () => _i659.ChatRepositoryImpl(gh<_i448.IChatRemoteDataSource>()));
    gh.lazySingleton<_i159.INotificationRepository>(() =>
        _i683.NotificationRepositoryImpl(
            gh<_i553.INotificationRemoteDataSource>()));
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
    gh.lazySingleton<_i696.IAuthRepository>(() => _i375.AuthRepositoryImpl(
          gh<_i587.IAuthRemoteDataSource>(),
          gh<_i439.IAuthLocalDataSource>(),
        ));
    gh.lazySingleton<_i420.ClearHistoryUseCase>(
        () => _i420.ClearHistoryUseCase(gh<_i331.IChatRepository>()));
    gh.lazySingleton<_i811.LoadHistoryUseCase>(
        () => _i811.LoadHistoryUseCase(gh<_i331.IChatRepository>()));
    gh.lazySingleton<_i521.SendMessageUseCase>(
        () => _i521.SendMessageUseCase(gh<_i331.IChatRepository>()));
    // IDebtRepository is registered manually in injection.dart.
    // DashboardProvider is registered manually in injection.dart.
    // NotificationProvider is registered manually in injection.dart.
    gh.lazySingleton<_i454.GetStaffDashboardUseCase>(() =>
        _i454.GetStaffDashboardUseCase(gh<_i916.IStaffDashboardRepository>()));
    // SalesProvider is registered manually in injection.dart.
    gh.factory<_i197.ChatProvider>(() => _i197.ChatProvider(
          gh<_i521.SendMessageUseCase>(),
          gh<_i811.LoadHistoryUseCase>(),
          gh<_i420.ClearHistoryUseCase>(),
        ));
    gh.lazySingleton<_i751.ForgotPasswordUseCase>(
        () => _i751.ForgotPasswordUseCase(gh<_i696.IAuthRepository>()));
    gh.lazySingleton<_i723.GetShopInfoUseCase>(
        () => _i723.GetShopInfoUseCase(gh<_i696.IAuthRepository>()));
    gh.lazySingleton<_i631.UpdateShopUseCase>(
        () => _i631.UpdateShopUseCase(gh<_i696.IAuthRepository>()));
    gh.lazySingleton<_i482.FetchAllShopsUseCase>(
        () => _i482.FetchAllShopsUseCase(gh<_i696.IAuthRepository>()));
    gh.lazySingleton<_i774.SwitchActiveShopUseCase>(
        () => _i774.SwitchActiveShopUseCase(gh<_i696.IAuthRepository>()));
    gh.lazySingleton<_i917.LoginUseCase>(
        () => _i917.LoginUseCase(gh<_i696.IAuthRepository>()));
    gh.lazySingleton<_i894.LogoutUseCase>(
        () => _i894.LogoutUseCase(gh<_i696.IAuthRepository>()));
    gh.lazySingleton<_i325.RegisterShopUseCase>(
        () => _i325.RegisterShopUseCase(gh<_i696.IAuthRepository>()));
    gh.lazySingleton<_i221.RegisterUseCase>(
        () => _i221.RegisterUseCase(gh<_i696.IAuthRepository>()));
    gh.lazySingleton<_i1025.ResendVerificationUseCase>(
        () => _i1025.ResendVerificationUseCase(gh<_i696.IAuthRepository>()));
    gh.lazySingleton<_i1019.ResetPasswordUseCase>(
        () => _i1019.ResetPasswordUseCase(gh<_i696.IAuthRepository>()));
    gh.lazySingleton<_i579.RestoreSessionUseCase>(
        () => _i579.RestoreSessionUseCase(gh<_i696.IAuthRepository>()));
    gh.lazySingleton<_i414.VerifyEmailUseCase>(
        () => _i414.VerifyEmailUseCase(gh<_i696.IAuthRepository>()));
    gh.lazySingleton<_i91.CreateCustomerUseCase>(
        () => _i91.CreateCustomerUseCase(gh<_i965.IDebtRepository>()));
    gh.lazySingleton<_i910.GetCustomerByIdUseCase>(
        () => _i910.GetCustomerByIdUseCase(gh<_i965.IDebtRepository>()));
    gh.lazySingleton<_i326.GetCustomersUseCase>(
        () => _i326.GetCustomersUseCase(gh<_i965.IDebtRepository>()));
    gh.lazySingleton<_i968.GetDebtHistoryUseCase>(
        () => _i968.GetDebtHistoryUseCase(gh<_i965.IDebtRepository>()));
    gh.lazySingleton<_i229.RecordPaymentUseCase>(
        () => _i229.RecordPaymentUseCase(gh<_i965.IDebtRepository>()));
    gh.factory<_i287.AuthProvider>(() => _i287.AuthProvider(
          gh<_i917.LoginUseCase>(),
          gh<_i894.LogoutUseCase>(),
          gh<_i221.RegisterUseCase>(),
          gh<_i325.RegisterShopUseCase>(),
          gh<_i751.ForgotPasswordUseCase>(),
          gh<_i1019.ResetPasswordUseCase>(),
          gh<_i579.RestoreSessionUseCase>(),
          gh<_i414.VerifyEmailUseCase>(),
          gh<_i1025.ResendVerificationUseCase>(),
          gh<_i723.GetShopInfoUseCase>(),
          gh<_i631.UpdateShopUseCase>(),
          gh<_i482.FetchAllShopsUseCase>(),
          gh<_i774.SwitchActiveShopUseCase>(),
        ));
    gh.factory<_i50.StaffDashboardProvider>(() =>
        _i50.StaffDashboardProvider(gh<_i454.GetStaffDashboardUseCase>()));
    // DebtProvider is registered manually in injection.dart.
    return this;
  }
}
