import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:temple_app/core/constants/api_constants.dart';
import 'package:temple_app/features/booking/providers/booking_provider.dart';
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

typedef _ModelUpdateHandler = Future<void> Function(Ref ref);

class SyncRepository {
  static const _baseUrl = "http://templerun.click/api/booking";

  final CategoryRepository _categoryRepo = CategoryRepository();
  final CategoryProductRepository _categoryProductRepo =
      CategoryProductRepository();
  final SpecialPoojaRepository _specialPoojaRepo = SpecialPoojaRepository();
  final WeeklyPoojaRepository _weeklyPoojaRepo = WeeklyPoojaRepository();
  final SpecialPrayerRepository _specialPrayerRepo = SpecialPrayerRepository();
  late final Map<String, _ModelUpdateHandler> _modelHandlers;

  SyncRepository() {
    _modelHandlers = {
      'PoojaCategory': _wrapNoRef(
        '📂 Refreshing PoojaCategory...',
        () => _refreshHiveBox<PoojaCategory>('poojaCategoryBox'),
      ),
      'Pooja': _wrapRef('📂 Refreshing Pooja...', _refreshStoreCategory),
      'StoreCategory': _wrapRef(
        '📂 Refreshing StoreCategory...',
        _refreshStoreCategory,
      ),
      'SpecialPoojaDate': _wrapRef(
        '📂 Refreshing SpecialPoojaDate...',
        _refreshSpecialPoojaDatesOnly,
      ),
      'SpecialPooja': _wrapRef(
        '📂 Refreshing Special Pooja Banner...',
        _refreshSpecialPoojaBannerOnly,
      ),
      'SpecialPoojaBanner': _wrapRef(
        '📂 Refreshing Special Pooja Banner...',
        _refreshSpecialPoojaBannerOnly,
      ),
      'WeeklyPooja': _wrapRef(
        '📂 Refreshing Weekly Pooja...',
        _refreshWeeklyPoojaOnly,
      ),
      'WeeklyPoojaData': _wrapRef(
        '📂 Refreshing Weekly Pooja...',
        _refreshWeeklyPoojaOnly,
      ),
      'SpecialPrayer': _wrapRef(
        '📂 Refreshing Special Prayer...',
        _refreshSpecialPrayerOnly,
      ),
      'SpecialPrayerData': _wrapRef(
        '📂 Refreshing Special Prayer...',
        _refreshSpecialPrayerOnly,
      ),
      'Music': _wrapRef('📂 Refreshing Music...', _refreshMusicOnly),
      'Song': _wrapRef('📂 Refreshing Music...', _refreshMusicOnly),
      'MusicData': _wrapRef('📂 Refreshing Music...', _refreshMusicOnly),
    };
  }

  _ModelUpdateHandler _wrapNoRef(
    String message,
    Future<void> Function() handler,
  ) {
    return (ref) async {
      debugPrint(message);
      await handler();
    };
  }

  _ModelUpdateHandler _wrapRef(
    String message,
    Future<void> Function(Ref ref) handler,
  ) {
    return (ref) async {
      debugPrint(message);
      await handler(ref);
    };
  }

  void _invalidateProviders(
    Ref ref, {
    required String logMessage,
    required Iterable<ProviderOrFamily> providers,
  }) {
    debugPrint(logMessage);
    for (final provider in providers) {
      ref.invalidate(provider);
    }
  }

  void _invalidateBookingProviders(Ref ref) {
    _invalidateProviders(
      ref,
      logMessage: '🔄 Invalidating booking providers to prevent stale data...',
      providers: [bookingPoojaProvider, cartProvider],
    );
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

  ///  Generic Hive clear
  Future<void> _refreshHiveBox<T>(String boxName) async {
    try {
      final box = await _ensureTypedBox<T>(boxName);
      await box.clear();
      debugPrint('Cleared Hive box: $boxName');
    } catch (e) {
      debugPrint(' Error clearing $boxName: $e');
    }
  }

  Future<Box<T>> _ensureTypedBox<T>(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<T>(boxName);
    }
    return Hive.openBox<T>(boxName);
  }

  Future<void> _clearBoxIfOpen<T>(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      return;
    }
    final box = Hive.box<T>(boxName);
    await box.clear();
    debugPrint('🧹 Cleared $boxName box');
  }

  Future<void> _refreshStoreProducts(Ref ref) async {
    try {
      debugPrint('Clearing and refreshing Store Products...');
      await _categoryProductRepo.resetCategoryProducts(ref);
    } catch (e, stack) {
      debugPrint(' [SyncRepository] Failed to refresh StoreProduct: $e');
      debugPrint(stack.toString());
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

  /// Refresh only Special Pooja Dates (when SpecialPoojaDate model is updated)
  Future<void> _refreshSpecialPoojaDatesOnly(Ref ref) async {
    try {
      debugPrint('🔄 Clearing and refreshing Special Pooja Dates only...');
      debugPrint('📋 This will trigger API calls for date-related data only');

      // Note: Since SpecialPoojaDate affects all special pooja data,
      // we still need to refresh all providers but with more specific logging
      await _clearSpecialPoojaHiveBoxes();

      _invalidateProviders(
        ref,
        logMessage:
            '🔄 Invalidating special pooja providers to trigger API calls...',
        providers: [
          specialPoojasProvider,
          weeklyPoojasProvider,
          specialPrayersProvider,
        ],
      );

      _invalidateBookingProviders(ref);

      debugPrint(
        '✅ Special Pooja Dates refresh initiated - API calls will be triggered when providers are accessed',
      );
    } catch (e, stack) {
      debugPrint('❌ [SyncRepository] Failed to refresh SpecialPoojaDate: $e');
      debugPrint(stack.toString());
    }
  }

  /// Refresh only Special Pooja Banner (when SpecialPooja/SpecialPoojaBanner model is updated)
  Future<void> _refreshSpecialPoojaBannerOnly(Ref ref) async {
    try {
      debugPrint('🔄 Clearing and refreshing Special Pooja Banner only...');
      debugPrint('📋 This will trigger: GET /poojas/?banner=true');

      await _clearBoxIfOpen<SpecialPooja>('specialPoojas');

      _invalidateProviders(
        ref,
        logMessage: '🔄 Invalidating banner provider...',
        providers: [specialPoojasProvider],
      );

      _invalidateBookingProviders(ref);

      debugPrint('✅ Special Pooja Banner refresh initiated');
    } catch (e, stack) {
      debugPrint('❌ [SyncRepository] Failed to refresh SpecialPoojaBanner: $e');
      debugPrint(stack.toString());
    }
  }

  /// Refresh only Weekly Pooja (when WeeklyPooja/WeeklyPoojaData model is updated)
  Future<void> _refreshWeeklyPoojaOnly(Ref ref) async {
    try {
      debugPrint('🔄 Clearing and refreshing Weekly Pooja only...');
      debugPrint('📋 This will trigger: GET /poojas/weekly_pooja');

      await _clearBoxIfOpen<SpecialPooja>('weeklyPoojas');

      _invalidateProviders(
        ref,
        logMessage: '🔄 Invalidating weekly poojas provider...',
        providers: [weeklyPoojasProvider],
      );

      _invalidateBookingProviders(ref);

      debugPrint('✅ Weekly Pooja refresh initiated');
    } catch (e, stack) {
      debugPrint('❌ [SyncRepository] Failed to refresh WeeklyPooja: $e');
      debugPrint(stack.toString());
    }
  }

  /// Refresh only Special Prayer (when SpecialPrayer/SpecialPrayerData model is updated)
  Future<void> _refreshSpecialPrayerOnly(Ref ref) async {
    try {
      debugPrint('🔄 Clearing and refreshing Special Prayer only...');
      debugPrint('📋 This will trigger: GET /poojas/?special_pooja=true');

      await _clearBoxIfOpen<SpecialPooja>('specialPrayers');

      _invalidateProviders(
        ref,
        logMessage: '🔄 Invalidating special prayers provider...',
        providers: [specialPrayersProvider],
      );

      _invalidateBookingProviders(ref);

      debugPrint('✅ Special Prayer refresh initiated');
    } catch (e, stack) {
      debugPrint('❌ [SyncRepository] Failed to refresh SpecialPrayer: $e');
      debugPrint(stack.toString());
    }
  }

  /// Refresh only Music (when Music/Song/MusicData model is updated)
  Future<void> _refreshMusicOnly(Ref ref) async {
    try {
      debugPrint('🔄 Clearing and refreshing Music only...');
      debugPrint('📋 This will trigger: GET /song/songs/');

      // Since music doesn't use Hive caching, we just invalidate the provider
      // This will trigger a fresh API call when the music page is accessed
      _invalidateProviders(
        ref,
        logMessage: '🔄 Invalidating music provider...',
        providers: [songsProvider],
      );

      // Also invalidate any music-related state providers to reset the music player
      _invalidateProviders(
        ref,
        logMessage: '🔄 Invalidating music player state...',
        providers: [
          queueProvider,
          queueIndexProvider,
          currentlyPlayingIdProvider,
          isPlayingProvider,
          isMutedProvider,
        ],
      );

      debugPrint(
        '✅ Music refresh initiated - fresh API call will be triggered when music page is accessed',
      );
    } catch (e, stack) {
      debugPrint('❌ [SyncRepository] Failed to refresh Music: $e');
      debugPrint(stack.toString());
    }
  }

  /// Clear all special pooja related Hive boxes
  Future<void> _clearSpecialPoojaHiveBoxes() async {
    try {
      await _clearBoxIfOpen<SpecialPooja>('specialPoojas');
      await _clearBoxIfOpen<SpecialPooja>('weeklyPoojas');
      await _clearBoxIfOpen<SpecialPooja>('specialPrayers');
    } catch (e) {
      debugPrint('❌ Error clearing special pooja boxes: $e');
    }
  }
}
