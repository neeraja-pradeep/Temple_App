import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temple/features/shop/cart/data/model/cart_model.dart';
import 'package:temple/features/shop/cart/data/repositories/cart_repository.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository();
});

/// ➕ Add to cart
final addToCartProvider = FutureProvider.family<bool, CartItem>((
  ref,
  cartItem,
) async {
  final repo = ref.watch(cartRepositoryProvider);
  final result = await repo.addToCart(cartItem);

  // Refresh cart list after adding
  ref.invalidate(
    cartRepositoryProvider,
  ); // cartProviders = StateNotifierProvider for cart
  return result;
});

/// 🛒 Get cart items
final getCartProvider = FutureProvider<List<CartItem>>((ref) async {
  final repo = ref.watch(cartRepositoryProvider);
  return repo.getCart();
});

/// 🗑 Remove item
final removeFromCartProvider = FutureProvider.family<bool, String>((
  ref,
  productVariantId,
) async {
  final repo = ref.watch(cartRepositoryProvider);
  return repo.removeFromCart(productVariantId);
});
final decrementFromCartProvider = FutureProvider.family<bool, String>((
  ref,
  productVariantId,
) async {
  final repo = ref.watch(cartRepositoryProvider);
  return repo.decrementFromCart(productVariantId);
});


