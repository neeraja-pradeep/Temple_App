import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/special_pooja_model.dart';
import '../data/special_pooja_repository.dart';
import '../data/weekly_pooja_repository.dart';

final specialPoojaRepositoryProvider = Provider<SpecialPoojaRepository>((ref) {
  return SpecialPoojaRepository();
});

final specialPoojasProvider = FutureProvider<List<SpecialPooja>>((ref) async {
  final repo = ref.watch(specialPoojaRepositoryProvider);
  return repo.fetchSpecialPoojas();
});

final specialBannerPageProvider = StateProvider<int>((ref) => 0);

final weeklyPoojaRepositoryProvider = Provider<WeeklyPoojaRepository>((ref) {
  return WeeklyPoojaRepository();
});

final weeklyPoojasProvider = FutureProvider<List<SpecialPooja>>((ref) async {
  final repo = ref.watch(weeklyPoojaRepositoryProvider);
  return repo.fetchWeeklyPoojas();
});
