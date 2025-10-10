import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:temple_app/features/global_api_notifer/data/model/global_update_model.dart';
import 'package:temple_app/features/pooja/data/models/pooja_category_model.dart';
import 'package:temple_app/features/shop/data/repositories/category_repository.dart';
import 'package:temple_app/features/special/data/special_pooja_repository.dart';
import 'package:temple_app/features/special/data/weekly_pooja_repository.dart';
import 'package:temple_app/features/special/data/special_prayer_repository.dart';
import 'package:temple_app/features/special/providers/special_pooja_provider.dart';
import 'package:temple_app/features/special/data/special_pooja_model.dart';

// Import repositories
import '../local/hive_sync_cache.dart';

class SyncRepository {
  static const _baseUrl = "http://templerun.click/api/booking";

  final CategoryRepository _categoryRepo = CategoryRepository();
  final SpecialPoojaRepository _specialPoojaRepo = SpecialPoojaRepository();
  final WeeklyPoojaRepository _weeklyPoojaRepo = WeeklyPoojaRepository();
  final SpecialPrayerRepository _specialPrayerRepo = SpecialPrayerRepository();

  ///  Check the global update timestamp and refresh if needed
  Future<void> checkForUpdates(Ref ref) async {
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
        final processed = await _processGlobalUpdateDetails(ref);
        if (processed) {
          await HiveSyncCache.saveLastUpdated(
            '2024-10-09T13:46:07.862214+05:30',
          ); //2024-10-09T13:46:07.862214+05:30 -------------> for testing puprose only | | orginal line(latestTimestamp)
        } else {
          debugPrint(
            ' [SyncRepository] Detail processing failed; cached timestamp unchanged.',
          );
        }
      } else {
        debugPrint(' No new updates found.');
      }
    } catch (e, stack) {
      debugPrint(' [SyncRepository] Error checking updates: $e');
      debugPrint(stack.toString());
    }
  }

  /// dY"< Fetch details of what models were updated
  Future<bool> _processGlobalUpdateDetails(Ref ref) async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/global-update-details/"),
      );
      if (response.statusCode != 200) {
        debugPrint(
          '[SyncRepository] Failed global-update-details: ${response.statusCode}',
        );
        return false;
      }

      final data = jsonDecode(response.body);
      final List results = data['results'];

      for (final item in results) {
        final detail = GlobalUpdateDetailModel.fromJson(item);
        debugPrint(' Model changed: ${detail.modelName}');

        // Match model and refresh accordingly
        switch (detail.modelName) {
          case 'PoojaCategory':
            await _refreshHiveBox(
              'poojaCategoryBox',
              'PoojaCategory',
            ); // sets your logic
            break;

          case 'Pooja':
            await _refreshStoreCategory(ref);
            break;

          case 'StoreCategory':
            await _refreshStoreCategory(ref);
            break;

          case 'SpecialPoojaDate':
            await _refreshSpecialPoojaData(ref);
            break;

          default:
            debugPrint(' [SyncRepository] Unknown model: ${detail.modelName}');
        }
      }
      return true;
    } catch (e, stack) {
      debugPrint(' [SyncRepository] Error processing details: $e');
      debugPrint(stack.toString());
      return false;
    }
  }

  ///  Generic Hive clear
  Future<void> _refreshHiveBox(String boxName, String modelName) async {
    try {
      final box = await _ensureBoxForModel(boxName, modelName);
      await box.clear();
      debugPrint('Cleared Hive box: $boxName');
    } catch (e) {
      debugPrint(' Error clearing $boxName: $e');
    }
  }

  Future<Box> _ensureBoxForModel(String boxName, String modelName) async {
    if (Hive.isBoxOpen(boxName)) {
      try {
        return _getOpenBoxForModel(boxName, modelName);
      } catch (_) {
        await Hive.box(boxName).close();
      }
    }
    return _openBoxForModel(boxName, modelName);
  }

  Box _getOpenBoxForModel(String boxName, String modelName) {
    switch (modelName) {
      case 'PoojaCategory':
        return Hive.box<PoojaCategory>(boxName);
      default:
        return Hive.box(boxName);
    }
  }

  Future<Box> _openBoxForModel(String boxName, String modelName) {
    switch (modelName) {
      case 'PoojaCategory':
        return Hive.openBox<PoojaCategory>(boxName);
      default:
        return Hive.openBox(boxName);
    }
  }

  ///  Refresh Store Categories via CategoryRepository
  Future<void> _refreshStoreCategory(Ref ref) async {
    try {
      debugPrint('Clearing and refreshing Store Categories...');
      await _categoryRepo.resetCategories(ref); // directly clear hive
    } catch (e, stack) {
      debugPrint(' [SyncRepository] Failed to refresh StoreCategory: $e');
      debugPrint(stack.toString());
    }
  }

  ///  Refresh Special Pooja Data (Banner, Weekly, Special Prayers)
  Future<void> _refreshSpecialPoojaData(Ref ref) async {
    try {
      debugPrint('🔄 Clearing and refreshing Special Pooja Data...');

      // Clear all special pooja related Hive boxes
      await _clearSpecialPoojaHiveBoxes();

      // Invalidate all special pooja providers to trigger refresh
      ref.invalidate(specialPoojasProvider);
      ref.invalidate(weeklyPoojasProvider);
      ref.invalidate(specialPrayersProvider);

      debugPrint('✅ Special Pooja Data refresh initiated');
    } catch (e, stack) {
      debugPrint('❌ [SyncRepository] Failed to refresh SpecialPoojaDate: $e');
      debugPrint(stack.toString());
    }
  }

  /// Clear all special pooja related Hive boxes
  Future<void> _clearSpecialPoojaHiveBoxes() async {
    try {
      // Clear special poojas (banner) box
      if (Hive.isBoxOpen('specialPoojas')) {
        final box = Hive.box<SpecialPooja>('specialPoojas');
        await box.clear();
        debugPrint('🧹 Cleared specialPoojas box');
      }

      // Clear weekly poojas box
      if (Hive.isBoxOpen('weeklyPoojas')) {
        final box = Hive.box<SpecialPooja>('weeklyPoojas');
        await box.clear();
        debugPrint('🧹 Cleared weeklyPoojas box');
      }

      // Clear special prayers box
      if (Hive.isBoxOpen('specialPrayers')) {
        final box = Hive.box<SpecialPooja>('specialPrayers');
        await box.clear();
        debugPrint('🧹 Cleared specialPrayers box');
      }
    } catch (e) {
      debugPrint('❌ Error clearing special pooja boxes: $e');
    }
  }
}
