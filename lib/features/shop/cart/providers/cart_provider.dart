import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temple_app/features/shop/cart/data/model/cart_model.dart';
import 'package:temple_app/features/shop/cart/data/repositories/cart_repository.dart';

final cartProviders = StateNotifierProvider<CartListNotifier, List<CartItem>>((
  ref,
) {
  final repo = CartRepository();
  return CartListNotifier(repo);
});

class CartListNotifier extends StateNotifier<List<CartItem>> {
  final CartRepository _repository;
  CartListNotifier(this._repository) : super([]) {
    loadCart();
  }

  Future<void> loadCart() async {
    // Prefer fresh data from API and sync to Hive; falls back to Hive inside repo
    final items = await _repository.getinitStateCartFromAPi();
    state = items;
  }

  Future<void> addItem(CartItem item) async {
    await _repository.addToCart(item);
    await loadCart(); // triggers UI rebuild
  }

  Future<void> removeItem(String productVariantId) async {
    await _repository.removeFromCart(productVariantId);
    await loadCart(); // triggers UI rebuild
  }

  Future<void> decrementItem(String productVariantId) async {
    await _repository.decrementFromCart(productVariantId);
    await loadCart(); // triggers UI rebuild
  }

  /// 🗑 Clear all cart items (used after successful order completion)
  Future<void> clearCart() async {
    await _repository.clearCart();
    state = []; // Clear the state immediately
  }

  /// ➕ Add or update via API (POST if new, PATCH if exists), then sync
  Future<void> addOrUpdateViaApi({
    required String productVariantId,
    required int quantity,
  }) async {
    final updated = await _repository.addAndUpdateCartItemToAPI(
      productVariantId: productVariantId,
      quantity: quantity,
    );
    if (updated) {
      state = await _repository.getCart(); // use freshly synced Hive cache
    } else {
      await loadCart(); // fallback to server fetch if API update failed
    }
  }

  /// ➖ Decrement via API (PATCH new qty, or DELETE if zero), then sync
  Future<void> decrementViaApi({
    required String productVariantId,
    required int currentQuantity,
  }) async {
    final nextQty = currentQuantity - 1;
    if (nextQty <= 0) {
      await _repository.deleteCartItemByProductVariantId(productVariantId);
    } else {
      await _repository.addAndUpdateCartItemToAPI(
        productVariantId: productVariantId,
        quantity: nextQty,
      );
    }
    await loadCart();
  }

  /// 🗑 Delete item via API by productVariantId, then sync
  Future<void> deleteViaApi(String productVariantId) async {
    await _repository.deleteCartItemByProductVariantId(productVariantId);
    await loadCart();
  }
}
