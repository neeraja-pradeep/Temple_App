import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:temple_app/core/constants/api_constants.dart';
import 'package:temple_app/core/network/auth_headers.dart';
import 'package:temple_app/features/shop/data/model/category/store_category.dart';
import 'package:temple_app/features/shop/providers/categoryRepo_provider.dart';

class CategoryRepository {
  static String hiveBoxName = 'store_categories';

  // ðŸ‘‡ Add this flag
  bool skipApiFetch = false;
  Completer<void>? _resetBarrier;

  Future<List<StoreCategory>> fetchCategories({
    bool forceRefresh = false,
    bool bypassBarrier = false,
  }) async {
    if (!bypassBarrier) {
      final barrier = _resetBarrier;
      if (barrier != null && !barrier.isCompleted) {
        await barrier.future;
      }
    }

    try {
      final box = await Hive.openBox<StoreCategory>(hiveBoxName);

      // âœ… if manual clear mode is active â€” just return empty
      if (skipApiFetch && !forceRefresh) {
        print("â¸ï¸ API fetch skipped (manual clear mode active)");
        return [];
      }

      if (!forceRefresh && box.isNotEmpty) {
        print("ðŸ“¦ Returning categories from Hive cache");
        return box.values.toList();
      }

      // Fetch from API if Hive is empty
      final authHeader = await AuthHeaders.requireToken();
      final headers = AuthHeaders.readFromHeader(authHeader);

      print('ðŸŒ Fetching categories from API...');
      final response = await http.get(
        Uri.parse(ApiConstants.storeCategories),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is List) {
          final categories = body
              .map((e) => StoreCategory.fromJson(e))
              .toList();
          await box.clear();
          await box.addAll(categories);
          print("ðŸ’¾ Categories cached in Hive (${categories.length} items)");
          return categories;
        } else {
          throw Exception("Invalid response format");
        }
      } else {
        throw Exception("Failed to fetch categories (${response.statusCode})");
      }
    } catch (e) {
      print("Error fetching categories: $e");

      // fallback to cache
      try {
        final box = await Hive.openBox<StoreCategory>(hiveBoxName);
        if (box.isNotEmpty) {
          print("âš ï¸ Returning cached categories due to error");
          return box.values.toList();
        }
      } catch (_) {}

      return [];
    }
  }

  Future<void> clearCategories() async {
    final box = await Hive.openBox<StoreCategory>(hiveBoxName);
    await box.clear();
  }

  Future<void> resetCategories(Ref ref) async {
    final repo = ref.read(categoryRepositoryProvider);

    ref.read(categoryRefreshInProgressProvider.notifier).state = true;

    final inFlightBarrier = repo._resetBarrier;
    if (inFlightBarrier != null && !inFlightBarrier.isCompleted) {
      await inFlightBarrier.future;
    }

    final barrier = Completer<void>();
    repo._resetBarrier = barrier;
    repo.skipApiFetch = true;

    try {
      await repo.clearCategories().then((_) {
        log(
          '-------------------\nMANUAL CLEAR\n-----------------------------------',
        );
      });
      ref.invalidate(categoriesProvider);
      ref.invalidate(categoryProductProvider);

      await Future.delayed(const Duration(seconds: 0));

      repo.skipApiFetch = false;
      log(
        '-------------------\nPERIODIC SYNC\n-----------------------------------',
      );
      await repo.fetchCategories(forceRefresh: true, bypassBarrier: true);
      ref.invalidate(categoriesProvider);
      ref.invalidate(categoryProductProvider);
      if (!barrier.isCompleted) {
        barrier.complete();
      }
    } catch (e, stack) {
      if (!barrier.isCompleted) {
        barrier.completeError(e);
      }
      log('Failed to force refresh categories: $e', stackTrace: stack);
    } finally {
      repo.skipApiFetch = false;
      if (!barrier.isCompleted) {
        barrier.complete();
      }
      repo._resetBarrier = null;
      ref.read(categoryRefreshInProgressProvider.notifier).state = false;
    }
  }
}
