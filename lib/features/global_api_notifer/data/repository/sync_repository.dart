import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:temple_app/core/constants/api_constants.dart';
import 'package:temple_app/features/booking/providers/booking_provider.dart';
import 'package:temple_app/features/drawer/store_order/data/order_model.dart';
import 'package:temple_app/features/drawer/store_order/data/order_service.dart';
import 'package:temple_app/features/global_api_notifer/data/model/global_update_model.dart';
import 'package:temple_app/features/music/providers/music_providers.dart';
import 'package:temple_app/features/pooja/data/models/pooja_category_model.dart';
import 'package:temple_app/features/shop/data/repositories/category_repository.dart';
import 'package:temple_app/features/shop/data/repositories/product_repository.dart';
import 'package:temple_app/features/special/data/special_pooja_model.dart';
import 'package:temple_app/features/special/data/special_pooja_repository.dart';
import 'package:temple_app/features/special/data/special_prayer_repository.dart';
import 'package:temple_app/features/special/data/weekly_pooja_repository.dart';
import 'package:temple_app/features/special/providers/special_pooja_provider.dart';

// Import repositories
import '../local/hive_sync_cache.dart';

part 'sync_repository.handlers.dart';
part 'sync_repository.helpers.dart';

typedef _ModelUpdateHandler = Future<void> Function(Ref ref);

class SyncRepository {
  static const _baseUrl = ApiConstants.bookingBase;

  final CategoryRepository _categoryRepo = CategoryRepository();
  final CategoryProductRepository _categoryProductRepo =
      CategoryProductRepository();
  final SpecialPoojaRepository _specialPoojaRepo = SpecialPoojaRepository();
  final WeeklyPoojaRepository _weeklyPoojaRepo = WeeklyPoojaRepository();
  final SpecialPrayerRepository _specialPrayerRepo = SpecialPrayerRepository();
  late final Map<String, _ModelUpdateHandler> _modelHandlers;

  SyncRepository() {
    _modelHandlers = buildModelHandlers(this);
  }

  ///  Check the global update timestamp and refresh if needed
  Future<void> checkForUpdates(Ref ref) async {
    debugPrint('🔄 [SyncRepository] Starting 30-second sync check...');
    debugPrint('⏰ Timestamp: ${DateTime.now().toIso8601String()}');

    try {
      debugPrint('🌐 API Call #1: GET $_baseUrl/global-update/');
      final response = await http.get(Uri.parse("$_baseUrl/global-update/"));
      debugPrint('📥 Response Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint(
          '❌ [SyncRepository] Failed global-update: ${response.statusCode}',
        );
        return;
      }

      final data = jsonDecode(response.body);
      final latestTimestamp = data['last_updated'];
      final cachedTimestamp = await HiveSyncCache.getLastUpdated();

      debugPrint('📊 Server timestamp: $latestTimestamp');
      debugPrint('💾 Cached timestamp: $cachedTimestamp');
      debugPrint(
        '🔍 Timestamp comparison: ${cachedTimestamp == latestTimestamp ? "SAME" : "DIFFERENT"}',
      );

      // If new update detected
      if (cachedTimestamp == null || cachedTimestamp != latestTimestamp) {
        debugPrint('🆕 New update detected! Fetching details...');
        debugPrint(
          '🔄 Processing updates and will save new timestamp after completion',
        );

        final processed = await _processGlobalUpdateDetails(ref);
        if (processed) {
          // Clear old timestamp and save new one
          await HiveSyncCache.saveLastUpdated(latestTimestamp);
          debugPrint(
            '💾 Cleared old timestamp and saved new timestamp: $latestTimestamp',
          );
          debugPrint(
            '✅ Sync completed successfully - timestamp updated locally',
          );
        } else {
          debugPrint(
            '❌ [SyncRepository] Detail processing failed; cached timestamp unchanged.',
          );
        }
      } else {
        debugPrint('✅ No new updates found - sync check complete');
        debugPrint('💾 Using existing cached timestamp: $cachedTimestamp');
      }
    } catch (e, stack) {
      debugPrint('❌ [SyncRepository] Error checking updates: $e');
      debugPrint(stack.toString());
    }

    debugPrint('🏁 [SyncRepository] 30-second sync check completed');
    debugPrint('⏰ Next check in 30 seconds...');
  }

  /// dY"< Fetch details of what models were updated
  Future<bool> _processGlobalUpdateDetails(Ref ref) async {
    try {
      debugPrint('🌐 API Call #2: GET $_baseUrl/global-update-details/');
      final response = await http.get(
        Uri.parse(ApiConstants.globalUpdateDetails),
      );
      debugPrint('📥 Response Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint(
          '❌ [SyncRepository] Failed global-update-details: ${response.statusCode}',
        );
        return false;
      }

      final data = jsonDecode(response.body);
      final List results = data['results'];
      debugPrint('📋 Found ${results.length} model updates to process');

      for (final item in results) {
        final detail = GlobalUpdateDetailModel.fromJson(item);
        final handler = _modelHandlers[detail.modelName];
        if (handler != null) {
          debugPrint('🔄 Processing model change: ${detail.modelName}');
          await handler(ref);
        } else {
          debugPrint('❓ [SyncRepository] Unknown model: ${detail.modelName}');
        }
      }
      debugPrint('✅ All model updates processed successfully');
      return true;
    } catch (e, stack) {
      debugPrint('❌ [SyncRepository] Error processing details: $e');
      debugPrint(stack.toString());
      return false;
    }
  }
}
