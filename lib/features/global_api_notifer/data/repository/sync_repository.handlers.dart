part of 'sync_repository.dart';

Map<String, _ModelUpdateHandler> buildModelHandlers(SyncRepository repo) {
  return {
    'PoojaCategory': _wrapNoRef(
      repo,
      '📂 Refreshing PoojaCategory...',
      () => _refreshHiveBox<PoojaCategory>(repo, 'poojaCategoryBox'),
    ),
    'Pooja': _wrapRef(
      repo,
      '📂 Refreshing Pooja...',
      (ref) => _refreshStoreCategory(repo, ref),
    ),
    'StoreCategory': _wrapRef(
      repo,
      '📂 Refreshing StoreCategory...',
      (ref) => _refreshStoreCategory(repo, ref),
    ),
    'SpecialPoojaDate': _wrapRef(
      repo,
      '📂 Refreshing SpecialPoojaDate...',
      (ref) => _refreshSpecialPoojaDatesOnly(repo, ref),
    ),
    'SpecialPooja': _wrapRef(
      repo,
      '📂 Refreshing Special Pooja Banner...',
      (ref) => _refreshSpecialPoojaBannerOnly(repo, ref),
    ),
    'SpecialPoojaBanner': _wrapRef(
      repo,
      '📂 Refreshing Special Pooja Banner...',
      (ref) => _refreshSpecialPoojaBannerOnly(repo, ref),
    ),
    'WeeklyPooja': _wrapRef(
      repo,
      '📂 Refreshing Weekly Pooja...',
      (ref) => _refreshWeeklyPoojaOnly(repo, ref),
    ),
    'WeeklyPoojaData': _wrapRef(
      repo,
      '📂 Refreshing Weekly Pooja...',
      (ref) => _refreshWeeklyPoojaOnly(repo, ref),
    ),
    'SpecialPrayer': _wrapRef(
      repo,
      '📂 Refreshing Special Prayer...',
      (ref) => _refreshSpecialPrayerOnly(repo, ref),
    ),
    'SpecialPrayerData': _wrapRef(
      repo,
      '📂 Refreshing Special Prayer...',
      (ref) => _refreshSpecialPrayerOnly(repo, ref),
    ),
    'Music': _wrapRef(
      repo,
      '📂 Refreshing Music...',
      (ref) => _refreshMusicOnly(repo, ref),
    ),
    'Song': _wrapRef(
      repo,
      '📂 Refreshing Music...',
      (ref) => _refreshMusicOnly(repo, ref),
    ),
    'MusicData': _wrapRef(
      repo,
      '📂 Refreshing Music...',
      (ref) => _refreshMusicOnly(repo, ref),
    ),
  };
}

_ModelUpdateHandler _wrapNoRef(
  SyncRepository repo,
  String message,
  Future<void> Function() handler,
) {
  return (ref) async {
    debugPrint(message);
    await handler();
  };
}

_ModelUpdateHandler _wrapRef(
  SyncRepository repo,
  String message,
  Future<void> Function(Ref ref) handler,
) {
  return (ref) async {
    debugPrint(message);
    await handler(ref);
  };
}
