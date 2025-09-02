import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temple/features/pooja/data/models/malayalam_date_model.dart';
import 'package:temple/features/pooja/data/models/pooja_model.dart';
import 'package:temple/features/pooja/data/repositories/pooja_repository.dart';
import '../data/models/pooja_category_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

final repositoryProvider = Provider<PoojaRepository>((ref) => PoojaRepository());

const String poojaCategoryBox = "poojaCategoryBox";
const String poojaBox = "poojaBox";
const String malayalamDateBox = "malayalamDateBox";


final poojaCategoriesProvider = FutureProvider<List<PoojaCategory>>((ref) async {
  final repo = ref.read(repositoryProvider);
  final box = await Hive.openBox<PoojaCategory>(poojaCategoryBox);

  try {
    final apiData = await repo.fetchPoojaCategories();
    await box.clear();
    for (var category in apiData) {
      await box.put(category.id, category);
    }
    return apiData;
  } catch (_) {
    return box.values.toList();
  }
});



final poojasByCategoryProvider =
    FutureProvider.family<List<Pooja>, int>((ref, categoryId) async {
  final repo = ref.read(repositoryProvider);
  final box = await Hive.openBox<Pooja>(poojaBox);
  try {
    final apiData = await repo.fetchPoojasByCategory(categoryId);
    final keysToDelete = box.keys.where((key) => (box.get(key) as Pooja).category == categoryId);
    await box.deleteAll(keysToDelete);
    for (var pooja in apiData) {
      await box.put(pooja.id, pooja);
    }
    return apiData;
  } catch (_) {
    return box.values.where((p) => p.category == categoryId).toList();
  }
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
    final box = await Hive.openBox<MalayalamDateModel>(malayalamDateBox);

    try {
      final repo = ref.read(repositoryProvider);
      final result = await repo.fetchMalayalamDate(date);
      await box.put(date, result);
      state = AsyncValue.data(result);
    } catch (_) {
      final cached = box.get(date);
      if (cached != null) {
        state = AsyncValue.data(cached);
      } else {
        state = AsyncValue.error('Failed to fetch Malayalam date and no cache found',
        StackTrace.current);
      }
    }
  }
}

final malayalamDateProvider =
    StateNotifierProvider<MalayalamDateNotifier, AsyncValue<MalayalamDateModel>>(
  (ref) => MalayalamDateNotifier(ref),
);
