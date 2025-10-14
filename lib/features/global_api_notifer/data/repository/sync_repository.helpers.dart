part of 'sync_repository.dart';

void _invalidateProviders(
  Ref ref, {
  required String logMessage,
  required Iterable<ProviderOrFamily> providers,
}) {
  var disposed = false;
  ref.onDispose(() => disposed = true);

  SchedulerBinding.instance.addPostFrameCallback((_) {
    if (disposed) return;
    debugPrint(logMessage);
    for (final provider in providers) {
      ref.invalidate(provider);
    }
  });
}

void _invalidateBookingProviders(Ref ref) {
  _invalidateProviders(
    ref,
    logMessage: '🔄 Invalidating booking providers to prevent stale data...',
    providers: [bookingPoojaProvider, cartProvider],
  );
}

Future<void> _refreshHiveBox<T>(SyncRepository repo, String boxName) async {
  try {
    final box = await _ensureTypedBox<T>(repo, boxName);
    await box.clear();
    debugPrint('Cleared Hive box: $boxName');
  } catch (e) {
    debugPrint(' Error clearing $boxName: $e');
  }
}

Future<Box<T>> _ensureTypedBox<T>(SyncRepository repo, String boxName) async {
  if (Hive.isBoxOpen(boxName)) {
    return Hive.box<T>(boxName);
  }
  return Hive.openBox<T>(boxName);
}

Future<void> _clearBoxIfOpen<T>(SyncRepository repo, String boxName) async {
  if (!Hive.isBoxOpen(boxName)) {
    return;
  }
  final box = Hive.box<T>(boxName);
  await box.clear();
  debugPrint('🧹 Cleared $boxName box');
}

Future<void> _refreshStoreProducts(SyncRepository repo, Ref ref) async {
  try {
    debugPrint('Clearing and refreshing Store Products...');
    await repo._categoryProductRepo.resetCategoryProducts(ref);
  } catch (e, stack) {
    debugPrint(' [SyncRepository] Failed to refresh StoreProduct: $e');
    debugPrint(stack.toString());
  }
}

Future<void> _refreshStoreCategory(SyncRepository repo, Ref ref) async {
  try {
    debugPrint('Clearing and refreshing Store Categories...');
    await repo._categoryRepo.resetCategories(ref);
  } catch (e, stack) {
    debugPrint(' [SyncRepository] Failed to refresh StoreCategory: $e');
    debugPrint(stack.toString());
  }
}

Future<void> _refreshSpecialPoojaDatesOnly(SyncRepository repo, Ref ref) async {
  try {
    debugPrint('🔄 Clearing and refreshing Special Pooja Dates only...');
    debugPrint('📋 This will trigger API calls for date-related data only');

    await _clearSpecialPoojaHiveBoxes(repo);

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

Future<void> _refreshSpecialPoojaBannerOnly(
  SyncRepository repo,
  Ref ref,
) async {
  try {
    debugPrint('🔄 Clearing and refreshing Special Pooja Banner only...');
    debugPrint('📋 This will trigger: GET /poojas/?banner=true');

    await _clearBoxIfOpen<SpecialPooja>(repo, 'specialPoojas');

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

Future<void> _refreshWeeklyPoojaOnly(SyncRepository repo, Ref ref) async {
  try {
    debugPrint('🔄 Clearing and refreshing Weekly Pooja only...');
    debugPrint('📋 This will trigger: GET /poojas/weekly_pooja');

    await _clearBoxIfOpen<SpecialPooja>(repo, 'weeklyPoojas');

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

Future<void> _refreshSpecialPrayerOnly(SyncRepository repo, Ref ref) async {
  try {
    debugPrint('🔄 Clearing and refreshing Special Prayer only...');
    debugPrint('📋 This will trigger: GET /poojas/?special_pooja=true');

    await _clearBoxIfOpen<SpecialPooja>(repo, 'specialPrayers');

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

Future<void> _refreshMusicOnly(SyncRepository repo, Ref ref) async {
  try {
    debugPrint('🔄 Clearing and refreshing Music only...');
    debugPrint('📋 This will trigger: GET /song/songs/');

    _invalidateProviders(
      ref,
      logMessage: '🔄 Invalidating music provider...',
      providers: [songsProvider],
    );

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

Future<void> _clearSpecialPoojaHiveBoxes(SyncRepository repo) async {
  try {
    await _clearBoxIfOpen<SpecialPooja>(repo, 'specialPoojas');
    await _clearBoxIfOpen<SpecialPooja>(repo, 'weeklyPoojas');
    await _clearBoxIfOpen<SpecialPooja>(repo, 'specialPrayers');
  } catch (e) {
    debugPrint('❌ Error clearing special pooja boxes: $e');
  }
}
