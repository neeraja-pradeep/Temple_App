import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:temple_app/core/constants/api_constants.dart';
import 'package:temple_app/core/network/auth_headers.dart';
import 'package:temple_app/features/shop/data/model/product/product_category.dart';

import '../../providers/categoryRepo_provider.dart';

/// Repository that keeps shop category products in sync with the backend and
/// the local Hive cache while coordinating UI refresh barriers.
class CategoryProductRepository {
  static const String _hiveBoxPrefix = 'category_products';
  static final Set<String> _trackedBoxNames = <String>{};

  bool skipApiFetch = false;
  Completer<void>? _resetBarrier;

  String _boxNameFor(int? categoryId) {
    final suffix = categoryId?.toString() ?? 'all';
    final name = '${_hiveBoxPrefix}_$suffix';
    _trackedBoxNames.add(name);
    return name;
  }

  Future<Box<CategoryProductModel>> _openProductBox(int? categoryId) async {
    final boxName = _boxNameFor(categoryId);
    return Hive.openBox<CategoryProductModel>(boxName);
  }

  Future<List<CategoryProductModel>> _getCachedProducts(int? categoryId) async {
    final box = await _openProductBox(categoryId);
    return box.values.toList(growable: false);
  }

  Future<void> _cacheProducts(
    int? categoryId,
    List<CategoryProductModel> products,
  ) async {
    final box = await _openProductBox(categoryId);
    await box.clear();
    await box.addAll(products);
  }

  Future<void> _clearCategoryProducts({int? categoryId}) async {
    if (categoryId != null) {
      final box = await _openProductBox(categoryId);
      await box.clear();
      return;
    }

    final targets = _trackedBoxNames.isEmpty
        ? <String>{_boxNameFor(null)}
        : Set<String>.from(_trackedBoxNames);

    for (final name in targets) {
      final box = await Hive.openBox<CategoryProductModel>(name);
      await box.clear();
    }
  }

  Future<List<CategoryProductModel>> fetchCategoryProduct(
    int? categoryId, {
    bool forceRefresh = false,
    bool bypassBarrier = false,
  }) async {
    log(
      'fetchCategoryProduct → categoryId: $categoryId, forceRefresh: $forceRefresh',
    );

    if (!bypassBarrier) {
      final barrier = _resetBarrier;
      if (barrier != null && !barrier.isCompleted) {
        await barrier.future;
      }
    }

    if (skipApiFetch && !forceRefresh) {
      log('API fetch skipped for category products (manual reset in progress)');
      return [];
    }

    try {
      final cacheBox = await _openProductBox(categoryId);

      if (!forceRefresh && cacheBox.isNotEmpty) {
        log('Returning cached products for categoryId: $categoryId');
        return cacheBox.values.toList(growable: false);
      }

      final response = await http.get(
        _buildProductsUri(categoryId),
        headers: await _buildAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is List) {
          final products = body
              .map((e) => CategoryProductModel.fromJson(e))
              .toList(growable: false);

          await _cacheProducts(categoryId, products);
          log('Cached ${products.length} products for categoryId: $categoryId');
          return products;
        } else {
          throw Exception('Invalid response format: expected a List');
        }
      } else {
        throw Exception(
          'Failed to fetch products. Status Code: ${response.statusCode}',
        );
      }
    } catch (e, stack) {
      log('Error in fetchCategoryProduct: $e');
      log(stack.toString());
      try {
        final cached = await _getCachedProducts(categoryId);
        if (cached.isNotEmpty) {
          log(
            'Returning cached products due to error (count: ${cached.length})',
          );
          return cached;
        }
      } catch (cacheError) {
        log('Failed to load cached products: $cacheError');
      }
      return [];
    }
  }

  Future<void> resetCategoryProducts(Ref ref, {int? categoryId}) async {
    final repo = ref.read(categoryProductRepositoryProvider);

    ref.read(categoryRefreshInProgressProvider.notifier).state = true;

    final inFlight = repo._resetBarrier;
    if (inFlight != null && !inFlight.isCompleted) {
      await inFlight.future;
    }

    final barrier = Completer<void>();
    repo._resetBarrier = barrier;
    repo.skipApiFetch = true;

    final targetCategory = categoryId ?? ref.read(selectedCategoryIDProvider);

    try {
      await repo._clearCategoryProducts();
      ref.invalidate(categoryProductProvider);

      await Future.delayed(const Duration(seconds: 1));

      repo.skipApiFetch = false;
      await repo.fetchCategoryProduct(
        targetCategory,
        forceRefresh: true,
        bypassBarrier: true,
      );
      ref.invalidate(categoryProductProvider);

      if (!barrier.isCompleted) {
        barrier.complete();
      }
    } catch (e, stack) {
      if (!barrier.isCompleted) {
        barrier.completeError(e);
      }
      log('Failed to reset category products: $e', stackTrace: stack);
    } finally {
      repo.skipApiFetch = false;
      if (!barrier.isCompleted) {
        barrier.complete();
      }
      repo._resetBarrier = null;
      ref.read(categoryRefreshInProgressProvider.notifier).state = false;
    }
  }

  Future<Map<String, String>> _buildAuthHeaders() async {
    final authHeader = await AuthHeaders.requireToken();
    return AuthHeaders.readFromHeader(authHeader);
  }

  Uri _buildProductsUri(int? categoryId) {
    if (categoryId == null) {
      return Uri.parse(ApiConstants.shopProducts);
    }
    return Uri.parse(ApiConstants.shopProductsByCategory(categoryId));
  }
}
