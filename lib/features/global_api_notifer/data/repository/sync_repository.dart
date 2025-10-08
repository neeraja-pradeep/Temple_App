import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:temple_app/features/global_api_notifer/data/model/global_update_model.dart';
import 'package:temple_app/features/shop/data/model/category/store_category.dart';
import 'package:temple_app/features/shop/data/repositories/category_repository.dart';

// Import repositories
import '../local/hive_sync_cache.dart';

class SyncRepository {
  static const _baseUrl = "http://templerun.click/api/booking";

  final CategoryRepository _categoryRepo = CategoryRepository();

  ///  Check the global update timestamp and refresh if needed
  Future<void> checkForUpdates() async {
    debugPrint(' [SyncRepository] Checking for updates...');

    try {
      final response = await http.get(Uri.parse("$_baseUrl/global-update/"));
      if (response.statusCode != 200) {
        debugPrint(
          ' [SyncRepository] Failed global-update: ${response.statusCode}',
        );
        return;
      }

      final data = jsonDecode(response.body);
      final latestTimestamp = data['last_updated'];
      final cachedTimestamp = await HiveSyncCache.getLastUpdated();

      debugPrint(' Server timestamp: $latestTimestamp');
      debugPrint(' Cached timestamp: $cachedTimestamp');

      // If new update detected
      if (cachedTimestamp == null || cachedTimestamp != latestTimestamp) {
        debugPrint(' New update detected! Fetching details...');
        await HiveSyncCache.saveLastUpdated(latestTimestamp);
        await _processGlobalUpdateDetails();
      } else {
        debugPrint(' No new updates found.');
      }
    } catch (e, stack) {
      debugPrint(' [SyncRepository] Error checking updates: $e');
      debugPrint(stack.toString());
    }
  }

  /// 📋 Fetch details of what models were updated
  Future<void> _processGlobalUpdateDetails() async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/global-update-details/"),
      );
      if (response.statusCode != 200) {
        debugPrint(
          '[SyncRepository] Failed global-update-details: ${response.statusCode}',
        );
        return;
      }

      final data = jsonDecode(response.body);
      final List results = data['results'];

      for (final item in results) {
        final detail = GlobalUpdateDetailModel.fromJson(item);
        debugPrint(' Model changed: ${detail.modelName}');

        // Match model and refresh accordingly
        switch (detail.modelName) {
          case 'PoojaCategory':
            await _refreshHiveBox('poojaCategoryBox', 'PoojaCategory'); // sets your logic
            break;

          case 'Pooja':
            await _refreshStoreCategory();// exampl....................
            break;

          case 'StoreCategory':
            await _refreshStoreCategory();
            break;

          default:
            debugPrint('ℹ Unknown model: ${detail.modelName}');
        }
      }
    } catch (e, stack) {
      debugPrint(' [SyncRepository] Error processing details: $e');
      debugPrint(stack.toString());
    }
  }

  ///  Generic Hive clear
  Future<void> _refreshHiveBox(String boxName, String modelName) async {
    try {
      final box = await Hive.openBox(boxName);
      await box.clear();
      debugPrint('Cleared Hive box: $boxName');

      // Optional: you could fetch new data for other models too
    } catch (e) {
      debugPrint(' Error clearing $boxName: $e');
    }
  }

  ///  Refresh Store Categories via CategoryRepository
  Future<void> _refreshStoreCategory() async {
    try {
      debugPrint(' Clearing and refreshing Store Categories...');
      final box = await Hive.openBox<StoreCategory>(
        CategoryRepository.hiveBoxName,
      );
      await box.clear();

      debugPrint('📡 Fetching fresh Store Categories from API...');
      final categories = await _categoryRepo.fetchCategories(
        forceRefresh: true,
      );
      //  await box.deleteAt(1);
      debugPrint(
        ' Store Categories refreshed: ${categories.length} items cached.',
      );
    } catch (e, stack) {
      debugPrint(' [SyncRepository] Failed to refresh StoreCategory: $e');
      debugPrint(stack.toString());
    }
  }
}
