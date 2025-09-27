import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temple_app/features/pooja/data/models/malayalam_date_model.dart';
import 'package:temple_app/features/pooja/data/models/pooja_model.dart';
import 'package:temple_app/features/pooja/data/repositories/pooja_repository.dart';
import '../data/models/pooja_category_model.dart';

final repositoryProvider = Provider<PoojaRepository>((ref) => PoojaRepository());

final poojaCategoriesProvider = FutureProvider<List<PoojaCategory>>((ref) async {
  final repo = ref.read(repositoryProvider);
  return await repo.fetchPoojaCategories();
});

final poojasByCategoryProvider =
    FutureProvider.family<List<Pooja>, int>((ref, categoryId) async {
  final repo = ref.read(repositoryProvider);
  return await repo.fetchPoojasByCategory(categoryId);
});

class MalayalamDateNotifier extends StateNotifier<AsyncValue<MalayalamDateModel>> {
  MalayalamDateNotifier(this.ref) : super(const AsyncValue.loading()) {
    _initTmr();
  }

  final Ref ref;

  Future<void> _initTmr() async {
    final now = DateTime.now().add(const Duration(days: 1));
    final defaultDate = now.toIso8601String().split("T").first;
    await fetchDate(defaultDate);
  }

  Future<void> fetchDate(String date) async {
    state = const AsyncValue.loading();

    try {
      final repo = ref.read(repositoryProvider);
      final result = await repo.fetchMalayalamDate(date);
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final malayalamDateProvider =
    StateNotifierProvider<MalayalamDateNotifier, AsyncValue<MalayalamDateModel>>(
  (ref) => MalayalamDateNotifier(ref),
);

