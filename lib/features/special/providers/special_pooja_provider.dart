import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/special_pooja_model.dart';
import '../data/special_pooja_repository.dart';
import '../data/weekly_pooja_repository.dart';
import '../data/special_prayer_repository.dart';
import 'package:hive/hive.dart';

final specialPoojaRepositoryProvider = Provider<SpecialPoojaRepository>((ref) {
  return SpecialPoojaRepository();
});

final specialPoojasProvider = FutureProvider<List<SpecialPooja>>((ref) async {
  final repo = ref.watch(specialPoojaRepositoryProvider);
  return await repo.fetchSpecialPoojas();
});

// Example for a refreshable provider
final refreshSpecialPoojasProvider = FutureProvider<List<SpecialPooja>>((
  ref,
) async {
  final repo = ref.watch(specialPoojaRepositoryProvider);
  return await repo.fetchSpecialPoojas(forceRefresh: true);
});

final specialBannerPageProvider = StateProvider<int>((ref) => 0);

final weeklyPoojaRepositoryProvider = Provider<WeeklyPoojaRepository>((ref) {
  return WeeklyPoojaRepository();
});

final weeklyPoojasProvider = FutureProvider<List<SpecialPooja>>((ref) async {
  final repo = ref.watch(weeklyPoojaRepositoryProvider);
  return await repo.fetchWeeklyPoojas();
});

// Example for a refreshable provider
final refreshWeeklyPoojasProvider = FutureProvider<List<SpecialPooja>>((
  ref,
) async {
  final repo = ref.watch(weeklyPoojaRepositoryProvider);
  return await repo.fetchWeeklyPoojas(forceRefresh: true);
});

final specialPrayerRepositoryProvider = Provider<SpecialPrayerRepository>((
  ref,
) {
  return SpecialPrayerRepository();
});

final specialPrayersProvider = FutureProvider<List<SpecialPooja>>((ref) async {
  final repo = ref.watch(specialPrayerRepositoryProvider);
  return await repo.fetchSpecialPrayers();
});

// Example for a refreshable provider
final refreshSpecialPrayersProvider = FutureProvider<List<SpecialPooja>>((
  ref,
) async {
  final repo = ref.watch(specialPrayerRepositoryProvider);
  return await repo.fetchSpecialPrayers(forceRefresh: true);
});

final specialPoojasBoxProvider = Provider<Box<SpecialPooja>?>(
  (ref) => Hive.isBoxOpen('specialPoojas')
      ? Hive.box<SpecialPooja>('specialPoojas')
      : null,
);
final weeklyPoojasBoxProvider = Provider<Box<SpecialPooja>?>(
  (ref) => Hive.isBoxOpen('weeklyPoojas')
      ? Hive.box<SpecialPooja>('weeklyPoojas')
      : null,
);
final specialPrayersBoxProvider = Provider<Box<SpecialPooja>?>(
  (ref) => Hive.isBoxOpen('specialPrayers')
      ? Hive.box<SpecialPooja>('specialPrayers')
      : null,
);

final specialPoojasCacheProvider = FutureProvider<List<SpecialPooja>>((
  ref,
) async {
  final box = await Hive.openBox<SpecialPooja>('specialPoojas');
  return box.values.toList();
});
final weeklyPoojasCacheProvider = FutureProvider<List<SpecialPooja>>((
  ref,
) async {
  final box = await Hive.openBox<SpecialPooja>('weeklyPoojas');
  return box.values.toList();
});
final specialPrayersCacheProvider = FutureProvider<List<SpecialPooja>>((
  ref,
) async {
  final box = await Hive.openBox<SpecialPooja>('specialPrayers');
  return box.values.toList();
});
