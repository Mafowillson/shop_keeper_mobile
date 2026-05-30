import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shopkeeper/core/enums/user_role.dart';
import 'package:shopkeeper/features/auth/domain/entities/user.dart';
import 'package:shopkeeper/features/auth/domain/usecases/login_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/logout_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/register_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/register_shop_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/forgot_password_usecase.dart';

@injectable
class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final RegisterUseCase _registerUseCase;
  final RegisterShopUseCase _registerShopUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _disposed = false;

  AuthProvider(
    this._loginUseCase,
    this._logoutUseCase,
    this._registerUseCase,
    this._registerShopUseCase,
    this._forgotPasswordUseCase,
  );

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> login(String email, String password, UserRole role) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _loginUseCase(email, password, role).run();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _currentUser = null;
      },
      (user) {
        _currentUser = user;
        _errorMessage = null;
      },
    );

    _setLoading(false);
  }

  Future<void> logout() async {
    _setLoading(true);

    final result = await _logoutUseCase().run();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (_) {
        _currentUser = null;
        _errorMessage = null;
      },
    );

    _setLoading(false);
  }

  Future<void> register(String name, String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _registerUseCase(
      name: name,
      email: email,
      password: password,
    ).run();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _currentUser = null;
      },
      (user) {
        _currentUser = user;
        _errorMessage = null;
      },
    );

    _setLoading(false);
  }

  Future<void> registerShop(String shopName) async {
    if (_currentUser == null) {
      _errorMessage = 'No authenticated owner found';
      notifyListeners();
      return;
    }
    _setLoading(true);
    _errorMessage = null;

    final result = await _registerShopUseCase(
      shopName: shopName,
      ownerId: _currentUser!.id,
    ).run();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (user) {
        _currentUser = user;
        _errorMessage = null;
      },
    );

    _setLoading(false);
  }

  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _forgotPasswordUseCase(email).run();

    bool success = false;
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        success = false;
      },
      (_) {
        _errorMessage = null;
        success = true;
      },
    );

    _setLoading(false);
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
