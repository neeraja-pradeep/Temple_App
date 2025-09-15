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
  final poojas = await repo.fetchSpecialPoojas();
  await repo.saveSpecialPoojasToCache(poojas);
  return poojas;
});


final specialBannerPageProvider = StateProvider<int>((ref) => 0);

final weeklyPoojaRepositoryProvider = Provider<WeeklyPoojaRepository>((ref) {
  return WeeklyPoojaRepository();
});

final weeklyPoojasProvider = FutureProvider<List<SpecialPooja>>((ref) async {
  final repo = ref.watch(weeklyPoojaRepositoryProvider);
  final poojas = await repo.fetchWeeklyPoojas();
  await repo.saveWeeklyPoojasToCache(poojas);
  return poojas;
});

final specialPrayerRepositoryProvider = Provider<SpecialPrayerRepository>((
  ref,
) {
  return SpecialPrayerRepository();
});

final specialPrayersProvider = FutureProvider<List<SpecialPooja>>((ref) async {
  final repo = ref.watch(specialPrayerRepositoryProvider);
  final prayers = await repo.fetchSpecialPrayers();
  await repo.saveSpecialPrayersToCache(prayers);
  return prayers;
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
