import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temple/features/shop/cart/data/model/cart_model.dart';
import 'package:temple/features/shop/cart/data/repositories/cart_repository.dart';

class CartNotifier extends StateNotifier<Map<String, int>> {
  final CartRepository _repository;

  CartNotifier(this._repository) : super({});

  Future<void> addItem(String productVariantId) async {
    final currentQuantity = state[productVariantId] ?? 0;
    final newQuantity = currentQuantity + 1;

    await _repository.addToCart(productVariantId, quantity: 1);

    state = {...state, productVariantId: newQuantity};
  }

  Future<void> removeItem(String productVariantId) async {
    final currentQuantity = state[productVariantId] ?? 0;

    if (currentQuantity > 1) {
      // Decrease quantity by 1
      final newQuantity = currentQuantity - 1;
      await _repository.addToCart(productVariantId, quantity: -1);
      state = {...state, productVariantId: newQuantity};
    } else if (currentQuantity == 1) {
      // Set quantity = 0 to remove from backend
      await _repository.addToCart(productVariantId, quantity: 0);

      // Remove from local state
      final updated = {...state};
      updated.remove(productVariantId);
      state = updated;
    }
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, Map<String, int>>((
  ref,
) {
  final repo = CartRepository();
  return CartNotifier(repo);
});
final cartProvidercheck = FutureProvider<List<CartItem>>((ref) async {
  try {
    final cartItems = await CartRepository().getCart();
    return cartItems;
  } catch (e) {
    // Handle error
    print("Failed to fetch cart: $e");
    return [];
  }
});

///////////////////////
///
class CartListNotifier extends StateNotifier<List<CartItem>> {
  final CartRepository _repository; // ✅ use CartRepository

  CartListNotifier(this._repository) : super([]) {
    loadCart();
  }

  /// Fetch all cart items
  Future<void> loadCart() async {
    try {
      final items = await _repository.getCart();
      state = items;
    } catch (e) {
      print("❌ Failed to fetch cart: $e");
      state = [];
    }
  }

  /// Add or update item
  Future<void> addItem(String productVariantId) async {
    try {
      await _repository.addToCart(productVariantId, quantity: 1);
      await loadCart(); // refresh after update
    } catch (e) {
      print("❌ Failed to add item: $e");
    }
  }

  /// Remove or decrement item
  Future<void> removeItem(String productVariantId) async {
    try {
      // Find the current item in state
      final item = state.firstWhere(
        (e) => e.productVariantId == productVariantId,
        orElse: () => throw Exception("Item not found"),
      );

      if (item.quantity > 1) {
        // Decrement quantity
        await _repository.addToCart(productVariantId, quantity: -1);
      } else {
        // Quantity is 1 → remove item completely
        await _repository.removeFromCart(productVariantId);
      }

      // Refresh cart after update
      await loadCart();
    } catch (e) {
      print("❌ Failed to remove item: $e");
    }
  }
}

/// ✅ Riverpod provider for cart state
final cartProviders =
    StateNotifierProvider<CartListNotifier, List<CartItem>>((ref) {
  final repo = CartRepository();
  final notifier = CartListNotifier(repo)..loadCart();

  // 👇 This keeps the provider alive even when no widget is listening
  ref.keepAlive();

  return notifier;
});


/// ✅ Provider that just checks if cart has items
final cartProviderChecker = Provider<bool>((ref) {
  final items = ref.watch(cartProvider);
  return items.isNotEmpty;
});
