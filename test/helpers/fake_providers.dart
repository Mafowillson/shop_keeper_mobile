import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:shopkeeper/core/cache/cache_metadata_service.dart';
import 'package:shopkeeper/core/cache/cache_status.dart';
import 'package:shopkeeper/core/enums/user_role.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/core/offline/connectivity_service.dart';
import 'package:shopkeeper/features/auth/domain/entities/shop_summary.dart';
import 'package:shopkeeper/features/auth/domain/entities/user.dart';
import 'package:shopkeeper/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:shopkeeper/features/auth/domain/usecases/fetch_all_shops_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/get_shop_info_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/login_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/logout_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/register_shop_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/register_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/resend_verification_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/switch_active_shop_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/update_shop_usecase.dart';
import 'package:shopkeeper/features/auth/domain/usecases/verify_email_usecase.dart';
import 'package:shopkeeper/features/auth/presentation/providers/auth_provider.dart';
import 'package:shopkeeper/features/dashboard/data/datasources/dashboard_local_datasource.dart';
import 'package:shopkeeper/features/dashboard/data/models/dashboard_stats_model.dart';
import 'package:shopkeeper/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:shopkeeper/features/dashboard/domain/repositories/i_dashboard_repository.dart';
import 'package:shopkeeper/features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';
import 'package:shopkeeper/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:shopkeeper/features/debts/data/datasources/debt_local_datasource.dart';
import 'package:shopkeeper/features/debts/data/models/customer_model.dart';
import 'package:shopkeeper/features/debts/data/models/debt_record_model.dart';
import 'package:shopkeeper/features/debts/domain/entities/customer.dart';
import 'package:shopkeeper/features/debts/domain/entities/debt_record.dart';
import 'package:shopkeeper/features/debts/domain/repositories/i_debt_repository.dart';
import 'package:shopkeeper/features/debts/domain/usecases/create_customer_usecase.dart';
import 'package:shopkeeper/features/debts/domain/usecases/get_customer_by_id_usecase.dart';
import 'package:shopkeeper/features/debts/domain/usecases/get_customers_usecase.dart';
import 'package:shopkeeper/features/debts/domain/usecases/get_debt_history_usecase.dart';
import 'package:shopkeeper/features/debts/domain/usecases/record_payment_usecase.dart';
import 'package:shopkeeper/features/debts/presentation/providers/debt_provider.dart';
import 'package:shopkeeper/features/products/data/datasources/product_local_datasource.dart';
import 'package:shopkeeper/features/products/data/models/product_model.dart';
import 'package:shopkeeper/features/products/domain/entities/product.dart';
import 'package:shopkeeper/features/products/domain/repositories/i_product_repository.dart';
import 'package:shopkeeper/features/products/domain/usecases/deactivate_product_usecase.dart';
import 'package:shopkeeper/features/products/domain/usecases/get_products_usecase.dart';
import 'package:shopkeeper/features/products/domain/usecases/save_product_usecase.dart';
import 'package:shopkeeper/features/products/domain/usecases/search_products_usecase.dart';
import 'package:shopkeeper/features/products/presentation/providers/product_provider.dart';
import 'package:shopkeeper/features/sales/data/datasources/sale_local_datasource.dart';
import 'package:shopkeeper/features/sales/data/models/sale_model.dart';
import 'package:shopkeeper/features/sales/domain/entities/cart_item.dart';
import 'package:shopkeeper/features/sales/domain/entities/sale.dart';
import 'package:shopkeeper/features/sales/domain/entities/sale_item.dart';
import 'package:shopkeeper/features/sales/domain/repositories/i_sale_repository.dart';
import 'package:shopkeeper/features/sales/domain/usecases/get_sale_detail_usecase.dart';
import 'package:shopkeeper/features/sales/domain/usecases/get_sales_usecase.dart';
import 'package:shopkeeper/features/sales/domain/usecases/record_sale_usecase.dart';
import 'package:shopkeeper/features/sales/presentation/providers/sales_provider.dart';

// ── Stub CacheMetadataService ─────────────────────────────────────────────────

class _StubCacheMetadataService extends CacheMetadataService {
  @override
  Future<void> saveTimestamp(String boxName) async {}
  @override
  Future<void> clearTimestamp(String boxName) async {}
  @override
  DateTime? getTimestamp(String boxName) => null;
  @override
  Duration? getAge(String boxName) => null;
  @override
  bool isStale(String boxName) => false;
  @override
  CacheStatus statusFor(String boxName, {required bool hasData}) =>
      CacheStatus.empty;
  @override
  Future<void> clearAll() async {}
}

// ── Stub auth ─────────────────────────────────────────────────────────────────

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
  @override
  TaskEither<Failure, User> updateShop(
          {required String name, required String description}) =>
      throw UnimplementedError();
  @override
  TaskEither<Failure, List<ShopSummary>> fetchAllShops() =>
      throw UnimplementedError();
  @override
  TaskEither<Failure, User> setActiveShop(
          {required String shopId,
          required String shopName,
          required String shopDescription}) =>
      throw UnimplementedError();
}

// ── Stub products ─────────────────────────────────────────────────────────────

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

class _StubProductLocalDS extends ProductLocalDataSource {
  _StubProductLocalDS() : super(_StubCacheMetadataService());

  @override
  List<ProductModel> getProducts({required String shopId}) => [];
  @override
  ProductModel? getProductById(String id) => null;
  @override
  Future<void> cacheProducts(List<ProductModel> products) async {}
  @override
  Future<void> saveProduct(ProductModel product) async {}
  @override
  Future<void> decrementStock(String productId, int totalBaseUnits) async {}
  @override
  Future<void> markInactive(String productId) async {}
  @override
  Future<void> invalidate() async {}
  @override
  bool get isEmpty => true;
}

// ── Stub debts ────────────────────────────────────────────────────────────────

class _StubDebtRepo implements IDebtRepository {
  @override
  TaskEither<Failure, List<Customer>> getCustomers(
          {required String shopId, bool? hasDebt}) =>
      throw UnimplementedError();
  @override
  TaskEither<Failure, Customer> getCustomerById(String id) =>
      throw UnimplementedError();
  @override
  TaskEither<Failure, Customer> createCustomer(
          {required String shopId, required String name, String? phone}) =>
      throw UnimplementedError();
  @override
  TaskEither<Failure, List<DebtRecord>> getDebtHistory(String customerId) =>
      throw UnimplementedError();
  @override
  TaskEither<Failure, Unit> recordPayment(
          String customerId, double amount, String? note) =>
      throw UnimplementedError();
}

class _StubDebtLocalDS extends DebtLocalDataSource {
  _StubDebtLocalDS() : super(_StubCacheMetadataService());

  @override
  List<CustomerModel> getCustomers({required String shopId, bool? hasDebt}) =>
      [];
  @override
  CustomerModel? getCustomerById(String id) => null;
  @override
  Future<void> saveCustomer(CustomerModel customer) async {}
  @override
  Future<void> cacheCustomers(List<CustomerModel> customers) async {}
  @override
  Future<void> removeTempCustomer(String tempId) async {}
  @override
  List<DebtRecordModel> getDebtHistory(String customerId) => [];
  @override
  Future<void> saveDebtRecord(DebtRecordModel record) async {}
  @override
  Future<void> invalidateCustomers() async {}
  @override
  Future<void> invalidateDebtRecords() async {}
  @override
  bool get isCustomersEmpty => true;
}

// ── Stub sales ────────────────────────────────────────────────────────────────

class _StubSaleRepo implements ISaleRepository {
  @override
  TaskEither<Failure, List<Sale>> getSales({required String shopId}) =>
      throw UnimplementedError();
  @override
  TaskEither<Failure, Sale> getSaleById(String id) =>
      throw UnimplementedError();
  @override
  TaskEither<Failure, Sale> recordSale({
    required String shopId,
    required List<CartItem> cartItems,
    required double paidAmount,
    required bool isCredit,
    String? customerId,
  }) =>
      throw UnimplementedError();
}

class _StubSaleLocalDS extends SaleLocalDataSource {
  _StubSaleLocalDS() : super(_StubCacheMetadataService());

  @override
  List<SaleModel> getSales({required String shopId}) => [];
  @override
  SaleModel? getSaleById(String id) => null;
  @override
  Future<void> saveSale(SaleModel sale) async {}
  @override
  Future<void> cacheSales(List<SaleModel> sales) async {}
  @override
  Future<void> removeTempEntry(String tempId) async {}
  @override
  Future<void> invalidate() async {}
  @override
  bool get isEmpty => true;
}

// ── Stub dashboard ────────────────────────────────────────────────────────────

class _StubDashboardRepo implements IDashboardRepository {
  @override
  TaskEither<Failure, DashboardStats> getStats(String shopId) =>
      throw UnimplementedError();
}

class _StubDashboardLocalDS extends DashboardLocalDataSource {
  _StubDashboardLocalDS() : super(_StubCacheMetadataService());

  @override
  DashboardStatsModel? getStats(String shopId) => null;
  @override
  Future<void> saveStats(DashboardStatsModel model, String shopId) async {}
  @override
  Future<void> invalidate({String? shopId}) async {}
  @override
  bool get isEmpty => true;
}

// ── FakeAuthProvider ──────────────────────────────────────────────────────────

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
          UpdateShopUseCase(_StubAuthRepo()),
          FetchAllShopsUseCase(_StubAuthRepo()),
          SwitchActiveShopUseCase(_StubAuthRepo()),
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
  Future<void> login(String email, String password, UserRole role) async {}

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
          _StubProductLocalDS(),
          _StubCacheMetadataService(),
          ConnectivityService.stub(),
        );

  @override
  List<Product> get products => _fakeProducts;
  @override
  bool get isLoading => _fakeLoading;

  @override
  Future<void> loadProducts(String shopId, {String? category}) async {}

  void setProducts(List<Product> p) {
    _fakeProducts = List.of(p);
    notifyListeners();
  }

  void setLoading(bool v) {
    _fakeLoading = v;
    notifyListeners();
  }
}

// ── FakeDebtProvider ──────────────────────────────────────────────────────────

class FakeDebtProvider extends DebtProvider {
  List<Customer> _fakeCustomers;
  bool _fakeLoading;
  bool _fakeSaving;
  Customer? _customerToCreate;

  FakeDebtProvider({
    List<Customer> customers = const [],
    bool isLoading = false,
    bool isSaving = false,
    Customer? customerToCreate,
  })  : _fakeCustomers = List.of(customers),
        _fakeLoading = isLoading,
        _fakeSaving = isSaving,
        _customerToCreate = customerToCreate,
        super(
          GetCustomersUseCase(_StubDebtRepo()),
          GetCustomerByIdUseCase(_StubDebtRepo()),
          CreateCustomerUseCase(_StubDebtRepo()),
          GetDebtHistoryUseCase(_StubDebtRepo()),
          RecordPaymentUseCase(_StubDebtRepo()),
          _StubDebtLocalDS(),
          _StubCacheMetadataService(),
          ConnectivityService.stub(),
        );

  @override
  List<Customer> get customers => _fakeCustomers;
  @override
  bool get isLoading => _fakeLoading;
  @override
  bool get isSaving => _fakeSaving;

  @override
  Future<void> loadCustomers(String shopId, {bool? hasDebt}) async {}

  @override
  Future<Customer?> createCustomer({
    required String shopId,
    required String name,
    String? phone,
  }) async =>
      _customerToCreate;

  void setCustomers(List<Customer> c) {
    _fakeCustomers = List.of(c);
    notifyListeners();
  }
}

// ── FakeSalesProvider ─────────────────────────────────────────────────────────

class FakeSalesProvider extends SalesProvider {
  Sale? _saleToReturn;
  String? _fakeError;

  FakeSalesProvider({
    Sale? saleToReturn,
    String? errorMessage,
  })  : _saleToReturn = saleToReturn,
        _fakeError = errorMessage,
        super(
          GetSalesUseCase(_StubSaleRepo()),
          GetSaleDetailUseCase(_StubSaleRepo()),
          RecordSaleUseCase(_StubSaleRepo()),
          _StubSaleLocalDS(),
          _StubCacheMetadataService(),
          ConnectivityService.stub(),
        );

  @override
  String? get errorMessage => _fakeError;

  @override
  Future<Sale?> recordSale({
    required String shopId,
    required List<CartItem> cartItems,
    required double paidAmount,
    required bool isCredit,
    String? customerId,
  }) async =>
      _saleToReturn;
}

// Sales provider that never resolves — keeps widget in _isSubmitting state for loading-state tests.
class FakeSalesProviderPending extends SalesProvider {
  FakeSalesProviderPending()
      : super(
          GetSalesUseCase(_StubSaleRepo()),
          GetSaleDetailUseCase(_StubSaleRepo()),
          RecordSaleUseCase(_StubSaleRepo()),
          _StubSaleLocalDS(),
          _StubCacheMetadataService(),
          ConnectivityService.stub(),
        );

  @override
  Future<Sale?> recordSale({
    required String shopId,
    required List<CartItem> cartItems,
    required double paidAmount,
    required bool isCredit,
    String? customerId,
  }) =>
      Completer<Sale?>().future;
}

// ── FakeDashboardProvider ─────────────────────────────────────────────────────

class FakeDashboardProvider extends DashboardProvider {
  FakeDashboardProvider()
      : super(
          GetDashboardStatsUseCase(_StubDashboardRepo()),
          _StubDashboardLocalDS(),
          _StubCacheMetadataService(),
          ConnectivityService.stub(),
        );

  @override
  Future<void> loadStats(String shopId) async {}
}

// ── Provider builder helpers (for unit tests) ────────────────────────────────

SalesProvider buildSalesProvider(
  ISaleRepository repo, {
  bool online = false,
}) =>
    SalesProvider(
      GetSalesUseCase(repo),
      GetSaleDetailUseCase(repo),
      RecordSaleUseCase(repo),
      _StubSaleLocalDS(),
      _StubCacheMetadataService(),
      ConnectivityService.stub(isOnline: online),
    );

DebtProvider buildDebtProvider(
  IDebtRepository repo, {
  bool online = false,
}) =>
    DebtProvider(
      GetCustomersUseCase(repo),
      GetCustomerByIdUseCase(repo),
      CreateCustomerUseCase(repo),
      GetDebtHistoryUseCase(repo),
      RecordPaymentUseCase(repo),
      _StubDebtLocalDS(),
      _StubCacheMetadataService(),
      ConnectivityService.stub(isOnline: online),
    );

ProductProvider buildProductProvider(
  IProductRepository repo, {
  bool online = false,
}) =>
    ProductProvider(
      GetProductsUseCase(repo),
      SaveProductUseCase(repo),
      DeactivateProductUseCase(repo),
      SearchProductsUseCase(repo),
      _StubProductLocalDS(),
      _StubCacheMetadataService(),
      ConnectivityService.stub(isOnline: online),
    );

AuthProvider buildAuthProvider(IAuthRepository repo) => AuthProvider(
      LoginUseCase(repo),
      LogoutUseCase(repo),
      RegisterUseCase(repo),
      RegisterShopUseCase(repo),
      ForgotPasswordUseCase(repo),
      ResetPasswordUseCase(repo),
      RestoreSessionUseCase(repo),
      VerifyEmailUseCase(repo),
      ResendVerificationUseCase(repo),
      GetShopInfoUseCase(repo),
      UpdateShopUseCase(repo),
      FetchAllShopsUseCase(repo),
      SwitchActiveShopUseCase(repo),
    );

DashboardProvider buildDashboardProvider(
  IDashboardRepository repo, {
  bool online = false,
}) =>
    DashboardProvider(
      GetDashboardStatsUseCase(repo),
      _StubDashboardLocalDS(),
      _StubCacheMetadataService(),
      ConnectivityService.stub(isOnline: online),
    );

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

final testCustomer = Customer(
  id: 'cust-1',
  shopId: 'shop-1',
  name: 'Alice Doe',
  phone: '237670001122',
  totalDebt: 5000,
  createdAt: DateTime(2026, 1, 1),
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

Sale makeSale({
  String id = 'sale-abcd1234-5678',
  double totalAmount = 3500,
  double paidAmount = 3500,
  bool isCredit = false,
  String? customerId,
}) =>
    Sale(
      id: id,
      shopId: 'shop-1',
      ownerId: 'owner-1',
      customerId: customerId,
      items: const [
        SaleItem(
          productId: 'prod-1',
          unit: 'Bottle',
          quantity: 7,
          unitPrice: 500,
          totalPrice: 3500,
        ),
      ],
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      dueAmount: totalAmount - paidAmount,
      isCredit: isCredit,
      isPaid: paidAmount >= totalAmount,
      createdAt: DateTime(2026, 6, 10),
    );
