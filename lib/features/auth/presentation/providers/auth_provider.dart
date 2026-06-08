import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/enums/user_role.dart';
import 'package:shopkeeper/features/auth/domain/entities/user.dart';
import 'package:shopkeeper/features/auth/domain/usecases/login_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/logout_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/register_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/register_shop_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/verify_email_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/resend_verification_usecase.dart';
import 'package:shopkeeper/features/auth/domain/entities/shop_summary.dart';
import 'package:shopkeeper/features/auth/domain/usecases/fetch_all_shops_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/get_shop_info_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/switch_active_shop_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/update_shop_usecase.dart';

@injectable
class AuthProvider extends ChangeNotifier {
  final LoginUseCase _login;
  final LogoutUseCase _logout;
  final RegisterUseCase _register;
  final RegisterShopUseCase _registerShop;
  final ForgotPasswordUseCase _forgotPassword;
  final ResetPasswordUseCase _resetPassword;
  final RestoreSessionUseCase _restoreSession;
  final VerifyEmailUseCase _verifyEmail;
  final ResendVerificationUseCase _resendVerification;
  final GetShopInfoUseCase _getShopInfo;
  final UpdateShopUseCase _updateShop;
  final FetchAllShopsUseCase _fetchAllShops;
  final SwitchActiveShopUseCase _switchActiveShop;

  User? _currentUser;
  List<ShopSummary> _shops = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _disposed = false;

  AuthProvider(
    this._login,
    this._logout,
    this._register,
    this._registerShop,
    this._forgotPassword,
    this._resetPassword,
    this._restoreSession,
    this._verifyEmail,
    this._resendVerification,
    this._getShopInfo,
    this._updateShop,
    this._fetchAllShops,
    this._switchActiveShop,
  );

  User? get currentUser => _currentUser;
  List<ShopSummary> get shops => _shops;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> login(String email, String password, UserRole role) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      debugPrint('[Auth] login → $email ${role.name}');
      final result = await _login(email, password, role).run();
      result.fold(
        (f) {
          _errorMessage = f.message;
          _currentUser = null;
        },
        (u) {
          _currentUser = u;
        },
      );
    } catch (e, st) {
      debugPrint('[Auth] login uncaught: $e\n$st');
      _errorMessage = 'Login failed: $e';
      _currentUser = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      final result = await _logout().run();
      result.fold(
        (f) => _errorMessage = f.message,
        (_) {
          _currentUser = null;
          _errorMessage = null;
        },
      );
    } catch (e) {
      debugPrint('[Auth] logout uncaught: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String name, String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final result =
          await _register(name: name, email: email, password: password).run();
      result.fold(
        (f) {
          _errorMessage = f.message;
          _currentUser = null;
        },
        (u) {
          _currentUser = u;
        },
      );
    } catch (e, st) {
      debugPrint('[Auth] register uncaught: $e\n$st');
      _errorMessage = 'Registration failed: $e';
      _currentUser = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> registerShop(String shopName) async {
    if (_currentUser == null) {
      _errorMessage = 'No authenticated owner found';
      notifyListeners();
      return;
    }
    _setLoading(true);
    _errorMessage = null;
    try {
      final result =
          await _registerShop(shopName: shopName, ownerId: _currentUser!.id)
              .run();
      result.fold(
        (f) => _errorMessage = f.message,
        (u) {
          _currentUser = u.copyWith(shopName: shopName);
          _errorMessage = null;
        },
      );
    } catch (e, st) {
      debugPrint('[Auth] registerShop uncaught: $e\n$st');
      _errorMessage = 'Shop registration failed: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Sends a reset code to [email]. Returns true on success.
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _errorMessage = null;
    bool success = false;
    try {
      final result = await _forgotPassword(email).run();
      result.fold(
        (f) => _errorMessage = f.message,
        (_) => success = true,
      );
    } catch (e) {
      _errorMessage = 'Request failed: $e';
    } finally {
      _setLoading(false);
    }
    return success;
  }

  /// Validates the OTP [code] and sets [newPassword]. Returns true on success.
  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    bool success = false;
    try {
      final result = await _resetPassword(
              email: email, code: code, newPassword: newPassword)
          .run();
      result.fold(
        (f) => _errorMessage = f.message,
        (_) => success = true,
      );
    } catch (e, st) {
      debugPrint('[Auth] resetPassword uncaught: $e\n$st');
      _errorMessage = 'Reset failed: $e';
    } finally {
      _setLoading(false);
    }
    return success;
  }

  Future<bool> tryRestoreSession() async {
    _setLoading(true);
    bool restored = false;
    try {
      final result = await _restoreSession().run();
      result.fold(
        (_) {
          _currentUser = null;
        },
        (u) {
          _currentUser = u;
          restored = true;
        },
      );
    } catch (e, st) {
      debugPrint('[Auth] restore uncaught: $e\n$st');
    } finally {
      _setLoading(false);
    }
    return restored;
  }

  Future<bool> verifyEmail(String code) async {
    _setLoading(true);
    _errorMessage = null;
    bool success = false;
    try {
      final result = await _verifyEmail(code).run();
      result.fold(
        (f) => _errorMessage = f.message,
        (u) {
          _currentUser = u;
          success = true;
        },
      );
    } catch (e, st) {
      debugPrint('[Auth] verifyEmail uncaught: $e\n$st');
      _errorMessage = 'Verification failed: $e';
    } finally {
      _setLoading(false);
    }
    return success;
  }

  Future<bool> resendVerificationCode() async {
    _setLoading(true);
    _errorMessage = null;
    bool success = false;
    try {
      final result = await _resendVerification().run();
      result.fold(
        (f) => _errorMessage = f.message,
        (_) => success = true,
      );
    } catch (e) {
      _errorMessage = 'Resend failed: $e';
    } finally {
      _setLoading(false);
    }
    return success;
  }

  Future<void> refreshShopInfo() async {
    if (_currentUser == null || _currentUser!.shopId.isEmpty) return;
    try {
      final result = await _getShopInfo().run();
      result.fold(
        (_) {},
        (u) {
          _currentUser = u;
        },
      );
    } catch (_) {}
    _notify();
  }

  Future<void> fetchAllShops() async {
    if (_currentUser == null) return;

    // Seed immediately from the cached user so the UI renders without waiting
    // for the network. The server response below will replace this with the
    // full list (which may include additional shops).
    if (_shops.isEmpty && _currentUser!.shopId.isNotEmpty) {
      _shops = [
        ShopSummary(
          id: _currentUser!.shopId,
          name: _currentUser!.shopName,
          description: _currentUser!.shopDescription,
          isActive: true,
        ),
      ];
      _notify();
    }

    try {
      final result = await _fetchAllShops().run();
      result.fold(
        (_) {},
        (list) => _shops = list,
      );
    } catch (_) {}
    _notify();
  }

  Future<void> switchShop(ShopSummary shop) async {
    if (_currentUser == null) return;
    try {
      final result = await _switchActiveShop(
        shopId: shop.id,
        shopName: shop.name,
        shopDescription: shop.description,
      ).run();
      result.fold(
        (_) {},
        (u) => _currentUser = u,
      );
    } catch (e, st) {
      debugPrint('[Auth] switchShop uncaught: $e\n$st');
    }
    _notify();
  }

  Future<bool> updateShop({
    required String name,
    required String description,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    bool success = false;
    try {
      final result =
          await _updateShop(name: name, description: description).run();
      result.fold(
        (f) => _errorMessage = f.message,
        (u) {
          _currentUser = u;
          success = true;
        },
      );
    } catch (e, st) {
      debugPrint('[Auth] updateShop uncaught: $e\n$st');
      _errorMessage = 'Failed to update shop: $e';
    } finally {
      _setLoading(false);
    }
    return success;
  }

  void resetAuth() {
    _currentUser = null;
    _errorMessage = null;
    _isLoading = false;
    _notify();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
