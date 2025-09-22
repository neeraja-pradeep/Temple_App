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

final addAndUpdateCartItemToAPI =
    FutureProvider.family<bool, Map<String, dynamic>>((ref, data) async {
      final repo = ref.watch(cartRepositoryProvider);

      // 1️⃣ Add or update cart item
      final cartResult = await repo.addAndUpdateCartItemToAPI(
        productVariantId: data["productVariantId"] as String,
        quantity: data["quantity"] as int,
      );

      if (!cartResult) {
        // Failed to add/update cart, return false
        return false;
      }

      // 2️⃣ Trigger checkout
      final checkoutResult = await repo.checkoutCart();
      return checkoutResult;
    });

/// 🗑 Clear all cart items (used after successful order completion)
final clearCartProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(cartRepositoryProvider);
  return await repo.clearCart();
});

/// ✅ Trigger checkout (no payload)
final checkoutCartProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(cartRepositoryProvider);
  return await repo.checkoutCart();
});

/// 💳 Trigger payment (no payload)
final payProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(cartRepositoryProvider);
  return await repo.pay();
});

final payAndGetOrderIdProvider = FutureProvider<int?>((ref) async {
  final repo = ref.watch(cartRepositoryProvider);
  return await repo.payAndReturnOrderId();
});

final deleteCartItemFromAPI = FutureProvider.family<bool, Map<String, dynamic>>(
  (ref, data) async {
    final repo = ref.watch(cartRepositoryProvider);

    return repo.deleteCartItemByProductVariantId(data["productVariantId"]);
  },
);
