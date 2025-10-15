import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temple_app/features/shop/data/model/category/store_category.dart';
import 'package:temple_app/features/shop/data/model/product/product_category.dart';
import 'package:temple_app/features/shop/data/repositories/category_repository.dart';
import 'package:temple_app/features/shop/data/repositories/product_repository.dart';

// CATEGORY
final categoryRepositoryProvider = Provider((ref) => CategoryRepository());

/// Tracks whether a manual/category sync is in progress so UI can show shimmer
final categoryRefreshInProgressProvider = StateProvider<bool>((ref) => false);

final categoriesProvider = FutureProvider<List<StoreCategory>>((ref) async {
  return ref.read(categoryRepositoryProvider).fetchCategories();
});

// Example for a refreshable provider
final refreshCategoriesProvider = FutureProvider<List<StoreCategory>>((ref) async {
  return ref.read(categoryRepositoryProvider).fetchCategories(forceRefresh: true);
});


// PRODUCT
final categoryProductRepositoryProvider = Provider(
  (ref) => CategoryProductRepository(),
);
// Providers
final selectedCategoryIndexProvider = StateProvider<int?>((ref) => null);

final selectedCategoryIDProvider = Provider<int?>((ref) {
  final categoriesAsync = ref.watch(categoriesProvider);
  final index = ref.watch(selectedCategoryIndexProvider);
  if (index == null) return null;
  return categoriesAsync.when(
    data: (catdata) {
      if (catdata.isEmpty) return null;

      if (index < 0 || index >= catdata.length) return null;
      return catdata[index].id;
    },
    error: (error, stackTrace) => null,
    loading: () => null,
  );
});
final selectedCategoryNameProvider = Provider<String>((ref) {
  final index = ref.watch(selectedCategoryIndexProvider);
  final categoriesAsync = ref.watch(categoriesProvider);

  return categoriesAsync.when(
    data: (cats) {
      if (index == null || index < 0 || index >= cats.length) {
        return "All Products";
      }
      return cats[index].name;
    },
    loading: () => "Loading...",
    error: (_, __) => "All Products",
  );
});

// Make it accept categoryId as a parameter
final categoryProductProvider = FutureProvider<List<CategoryProductModel>>((
  ref,
) async {
  final categoryID = ref.watch(selectedCategoryIDProvider);
  return ref
      .read(categoryProductRepositoryProvider)
      .fetchCategoryProduct(categoryID);
});
