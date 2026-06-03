import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/network/dio_client.dart';
import 'package:shopkeeper/core/network/token_storage.dart';
import 'package:shopkeeper/core/services/fcm_service.dart';
import 'package:shopkeeper/features/settings/presentation/providers/settings_provider.dart';

import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() {
  // Infrastructure singletons registered manually — they live in core/ and
  // have no injectable annotations to avoid coupling core to injectable.
  getIt.registerLazySingleton<TokenStorage>(
    () => TokenStorage(
      const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      ),
    ),
  );
  getIt.registerLazySingleton<DioClient>(
    () => DioClient(getIt<TokenStorage>()),
  );
  getIt.registerLazySingleton<FcmService>(
    () => FcmService(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<SettingsProvider>(
    () => SettingsProvider(getIt<DioClient>()),
  );

  // injectable-generated registrations (feature-layer classes).
  getIt.init();
}
