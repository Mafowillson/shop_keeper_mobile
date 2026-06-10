import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shopkeeper/core/errors/failures.dart';
import 'package:shopkeeper/features/products/domain/entities/product.dart';
import 'package:shopkeeper/features/products/domain/repositories/i_product_repository.dart';

import '../../../../helpers/fake_providers.dart';

// ── Test repositories ─────────────────────────────────────────────────────────

class _SuccessProductRepo implements IProductRepository {
  final Product _product;
  _SuccessProductRepo(this._product);

  @override
  TaskEither<Failure, List<Product>> getProducts(
          {required String shopId, String? search, String? category}) =>
      TaskEither.right([_product]);

  @override
  TaskEither<Failure, Product> getProductById(String id) =>
      TaskEither.right(_product);

  @override
  TaskEither<Failure, Product> saveProduct(Product product) =>
      TaskEither.right(product);

  @override
  TaskEither<Failure, Unit> deactivateProduct(String id) =>
      TaskEither.right(unit);

  @override
  TaskEither<Failure, List<Product>> searchProducts(String query,
          {required String shopId}) =>
      TaskEither.right([_product]);

  @override
  TaskEither<Failure, Unit> decrementStock(String productId, int qty) =>
      TaskEither.right(unit);
}

class _FailingProductRepo implements IProductRepository {
  final String message;
  _FailingProductRepo([this.message = 'Server error']);

  @override
  TaskEither<Failure, List<Product>> getProducts(
          {required String shopId, String? search, String? category}) =>
      TaskEither.left(ServerFailure(message));

  @override
  TaskEither<Failure, Product> getProductById(String id) =>
      TaskEither.left(ServerFailure(message));

  @override
  TaskEither<Failure, Product> saveProduct(Product product) =>
      TaskEither.left(ServerFailure(message));

  @override
  TaskEither<Failure, Unit> deactivateProduct(String id) =>
      TaskEither.left(ServerFailure(message));

  @override
  TaskEither<Failure, List<Product>> searchProducts(String query,
          {required String shopId}) =>
      TaskEither.left(ServerFailure(message));

  @override
  TaskEither<Failure, Unit> decrementStock(String productId, int qty) =>
      TaskEither.left(ServerFailure(message));
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── saveProduct (new) ─────────────────────────────────────────────────────

  group('ProductProvider — saveProduct new', () {
    test('returns product and prepends to list', () async {
      final product = makeProduct();
      final p = buildProductProvider(_SuccessProductRepo(product));

      final result = await p.saveProduct(product);

      expect(result, product);
      expect(p.products, [product]);
      expect(p.errorMessage, isNull);
      expect(p.isSaving, isFalse);
    });
  });

  group('ProductProvider — saveProduct update', () {
    test('replaces existing product in-place', () async {
      final original = makeProduct(name: 'Original');
      final updated = makeProduct(name: 'Updated');
      final repo = _SuccessProductRepo(updated);
      final p = buildProductProvider(repo);

      // Add original first
      await p.saveProduct(original);
      expect(p.products.first.name, 'Original');

      // Now update
      await p.saveProduct(updated);
      expect(p.products.length, 1);
      expect(p.products.first.name, 'Updated');
    });
  });

  group('ProductProvider — saveProduct failure', () {
    test('sets errorMessage and returns null', () async {
      final p = buildProductProvider(_FailingProductRepo('Validation error'));
      final result = await p.saveProduct(makeProduct());
      expect(result, isNull);
      expect(p.errorMessage, 'Validation error');
      expect(p.products, isEmpty);
    });
  });

  // ── deactivateProduct ─────────────────────────────────────────────────────

  group('ProductProvider — deactivateProduct success', () {
    test('returns true and removes product from list', () async {
      final product = makeProduct();
      final p = buildProductProvider(_SuccessProductRepo(product));
      await p.saveProduct(product);
      expect(p.products, [product]);

      final result = await p.deactivateProduct(product.id);
      expect(result, isTrue);
      expect(p.products, isEmpty);
    });
  });

  group('ProductProvider — deactivateProduct failure', () {
    test('returns false and sets errorMessage', () async {
      final p = buildProductProvider(_FailingProductRepo('Not found'));
      final result = await p.deactivateProduct('prod-x');
      expect(result, isFalse);
      expect(p.errorMessage, 'Not found');
    });
  });

  // ── categories ────────────────────────────────────────────────────────────

  group('ProductProvider — categories', () {
    test('is empty when no products', () {
      final p = buildProductProvider(_FailingProductRepo());
      expect(p.categories, isEmpty);
    });

    test('returns sorted unique categories from product list', () async {
      final drinks = makeProduct(id: 'p1', name: 'Coke', category: 'Drinks');
      final food = makeProduct(id: 'p2', name: 'Rice', category: 'Food');
      final p = buildProductProvider(_SuccessProductRepo(drinks));
      await p.saveProduct(drinks);
      await p.saveProduct(food);
      expect(p.categories, ['Drinks', 'Food']);
    });
  });

  // ── clearError ────────────────────────────────────────────────────────────

  group('ProductProvider — clearError', () {
    test('clears errorMessage', () async {
      final p = buildProductProvider(_FailingProductRepo('oops'));
      await p.saveProduct(makeProduct());
      expect(p.errorMessage, 'oops');

      p.clearError();
      expect(p.errorMessage, isNull);
    });
  });

  // ── invalidateCache ───────────────────────────────────────────────────────

  group('ProductProvider — invalidateCache', () {
    test('clears products list', () async {
      final product = makeProduct();
      final p = buildProductProvider(_SuccessProductRepo(product));
      await p.saveProduct(product);
      expect(p.products, isNotEmpty);

      await p.invalidateCache();
      expect(p.products, isEmpty);
    });
  });

  // ── loadProducts offline ──────────────────────────────────────────────────

  group('ProductProvider — loadProducts offline', () {
    test('stays empty with no cache and no network', () async {
      final p = buildProductProvider(_SuccessProductRepo(makeProduct()),
          online: false);
      await p.loadProducts('shop-1');
      expect(p.products, isEmpty);
      expect(p.isLoading, isFalse);
    });
  });

  // ── loadProducts online ───────────────────────────────────────────────────

  group('ProductProvider — loadProducts online', () {
    test('populates products from repo on success', () async {
      final product = makeProduct();
      final p =
          buildProductProvider(_SuccessProductRepo(product), online: true);
      await p.loadProducts('shop-1');
      expect(p.products, [product]);
      expect(p.isLoading, isFalse);
      expect(p.isRefreshing, isFalse);
    });

    test('sets errorMessage when repo fails and list is empty', () async {
      final p =
          buildProductProvider(_FailingProductRepo('No data'), online: true);
      await p.loadProducts('shop-1');
      expect(p.errorMessage, 'No data');
    });
  });

  // ── searchProducts online ─────────────────────────────────────────────────

  group('ProductProvider — searchProducts online', () {
    test('populates products from search on success', () async {
      final product = makeProduct();
      final p =
          buildProductProvider(_SuccessProductRepo(product), online: true);
      await p.searchProducts('Coca', 'shop-1');
      expect(p.products, [product]);
      expect(p.isLoading, isFalse);
    });

    test('calls loadProducts when query is empty', () async {
      final product = makeProduct();
      final p =
          buildProductProvider(_SuccessProductRepo(product), online: true);
      await p.searchProducts('', 'shop-1');
      // Empty query delegates to loadProducts — products populated online
      expect(p.products, [product]);
    });
  });
}
