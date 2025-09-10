import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temple/features/shop/data/models/shop_category_model.dart';
import 'package:temple/features/shop/data/models/shop_product_models.dart';
import 'package:temple/features/shop/data/shop_repository.dart';

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  return ShopRepository();
});

final shopCategoriesProvider = FutureProvider<List<ShopCategory>>((ref) async {
  final repo = ref.read(shopRepositoryProvider);
  return repo.fetchCategories();
});

final selectedCategoryIndexProvider = StateProvider<int?>((ref) => null);

final selectedCategoryIdProvider = Provider<int?>((ref) {
  final categoriesAsync = ref.watch(shopCategoriesProvider);
  final int? index = ref.watch(selectedCategoryIndexProvider);
  if (index == null) return null;
  return categoriesAsync.when(
    data: (cats) {
      if (cats.isEmpty) return null;
      if (index < 0 || index >= cats.length) return null;
      return cats[index].id;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

final shopProductsByCategoryProvider = FutureProvider<List<ShopProduct>>((
  ref,
) async {
  final repo = ref.read(shopRepositoryProvider);
  final categoryId = ref.watch(selectedCategoryIdProvider);
  return repo.fetchShopProducts(categoryId: categoryId);
});
