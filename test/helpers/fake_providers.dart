import 'package:fpdart/fpdart.dart';
import 'package:shopkeeper/core/enums/user_role.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/auth/domain/entities/user.dart';
import 'package:shopkeeper/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:shopkeeper/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/get_shop_info_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/login_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/logout_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/register_shop_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/register_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/resend_verification_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/verify_email_usecase.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/products/domain/entities/product.dart';
import 'package:shopkeeper/features/products/domain/repositories/i_product_repository.dart';
import 'package:shopkeeper/features/products/domain/usecases/deactivate_product_usecase.dart';
import 'package:shopkeeper/features/products/domain/usecases/get_products_usecase.dart';
import 'package:shopkeeper/features/products/domain/usecases/save_product_usecase.dart';
import 'package:shopkeeper/features/products/domain/usecases/search_products_usecase.dart';
import 'package:shopkeeper/features/products/presentation/providers/product_provider.dart';

// ── Stub repository impls (methods that are never called throw UnimplementedError)

class _StubAuthRepo implements IAuthRepository {
  @override
  TaskEither<Failure, User> login(
          String email, String password, UserRole role) =>
      throw UnimplementedError();
  @override
  TaskEither<Failure, Unit> logout() => throw UnimplementedError();
  @override
  TaskEither<Failure, User> register(
          {required String name,
          required String email,
          required String password}) =>
      throw UnimplementedError();
  @override
  TaskEither<Failure, User> registerShop(
          {required String shopName, required String ownerId}) =>
      throw UnimplementedError();
  @override
  TaskEither<Failure, Unit> forgotPassword(String email) =>
      throw UnimplementedError();
  @override
  TaskEither<Failure, Unit> resetPassword(
          {required String email,
          required String code,
          required String newPassword}) =>
      throw UnimplementedError();
  @override
  TaskEither<Failure, User> restoreSession() => throw UnimplementedError();
  @override
  TaskEither<Failure, User> verifyEmail(String code) =>
      throw UnimplementedError();
  @override
  TaskEither<Failure, Unit> resendVerificationCode() =>
      throw UnimplementedError();
  @override
  TaskEither<Failure, User> fetchShopInfo() => throw UnimplementedError();
}

class _StubProductRepo implements IProductRepository {
  @override
  TaskEither<Failure, List<Product>> getProducts(
          {required String shopId, String? search, String? category}) =>
      throw UnimplementedError();
  @override
  TaskEither<Failure, Product> getProductById(String id) =>
      throw UnimplementedError();
  @override
  TaskEither<Failure, Product> saveProduct(Product product) =>
      throw UnimplementedError();
  @override
  TaskEither<Failure, Unit> deactivateProduct(String id) =>
      throw UnimplementedError();
  @override
  TaskEither<Failure, List<Product>> searchProducts(String query,
          {required String shopId}) =>
      throw UnimplementedError();
  @override
  TaskEither<Failure, Unit> decrementStock(String productId, int qty) =>
      throw UnimplementedError();
}

// ── FakeAuthProvider ──────────────────────────────────────────────────────────
//
// Subclasses AuthProvider so it can be provided as AuthProvider in the widget
// tree. Overrides isLoading / currentUser / errorMessage and all async methods
// so the stub repositories are never actually called.

class FakeAuthProvider extends AuthProvider {
  bool _loading;
  User? _user;
  String? _error;

  FakeAuthProvider({
    bool isLoading = false,
    User? currentUser,
    String? errorMessage,
  })  : _loading = isLoading,
        _user = currentUser,
        _error = errorMessage,
        super(
          LoginUseCase(_StubAuthRepo()),
          LogoutUseCase(_StubAuthRepo()),
          RegisterUseCase(_StubAuthRepo()),
          RegisterShopUseCase(_StubAuthRepo()),
          ForgotPasswordUseCase(_StubAuthRepo()),
          ResetPasswordUseCase(_StubAuthRepo()),
          RestoreSessionUseCase(_StubAuthRepo()),
          VerifyEmailUseCase(_StubAuthRepo()),
          ResendVerificationUseCase(_StubAuthRepo()),
          GetShopInfoUseCase(_StubAuthRepo()),
        );

  @override
  bool get isLoading => _loading;
  @override
  User? get currentUser => _user;
  @override
  String? get errorMessage => _error;

  void setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void setUser(User? u) {
    _user = u;
    notifyListeners();
  }

  void setError(String? e) {
    _error = e;
    notifyListeners();
  }

  @override
  Future<void> login(String email, String password, UserRole role) async {
    // No-op by default; tests can override behaviour via setUser / setError.
  }

  @override
  Future<void> logout() async {}

  @override
  Future<bool> tryRestoreSession() async => false;
}

// ── FakeProductProvider ───────────────────────────────────────────────────────

class FakeProductProvider extends ProductProvider {
  List<Product> _fakeProducts;
  bool _fakeLoading;

  FakeProductProvider({
    List<Product> products = const [],
    bool isLoading = false,
  })  : _fakeProducts = List.of(products),
        _fakeLoading = isLoading,
        super(
          GetProductsUseCase(_StubProductRepo()),
          SaveProductUseCase(_StubProductRepo()),
          DeactivateProductUseCase(_StubProductRepo()),
          SearchProductsUseCase(_StubProductRepo()),
        );

  @override
  List<Product> get products => _fakeProducts;
  @override
  bool get isLoading => _fakeLoading;

  @override
  Future<void> loadProducts(String shopId, {String? category}) async {
    // No-op — products are pre-set at construction.
  }

  void setProducts(List<Product> p) {
    _fakeProducts = List.of(p);
    notifyListeners();
  }

  void setLoading(bool v) {
    _fakeLoading = v;
    notifyListeners();
  }
}

// ── Test fixtures ─────────────────────────────────────────────────────────────

const testOwner = User(
  id: 'owner-1',
  shopId: 'shop-1',
  name: 'Test Owner',
  email: 'owner@test.com',
  role: UserRole.owner,
  isActive: true,
  emailVerified: true,
  shopName: 'Test Shop',
);

const testStaffUser = User(
  id: 'staff-1',
  shopId: 'shop-1',
  name: 'Test Staff',
  email: 'staff@test.com',
  role: UserRole.staff,
  isActive: true,
);

Product makeProduct({
  String id = 'prod-1',
  String name = 'Coca-Cola',
  String category = 'Drinks',
  int stock = 50,
  int lowStockThreshold = 5,
  bool isActive = true,
}) =>
    Product(
      id: id,
      shopId: 'shop-1',
      name: name,
      category: category,
      units: const [
        UnitDefinition(name: 'Bottle', quantityInBase: 1, price: 500),
        UnitDefinition(name: 'Carton', quantityInBase: 24, price: 10000),
      ],
      stockQty: stock,
      lowStockThreshold: lowStockThreshold,
      isActive: isActive,
    );
