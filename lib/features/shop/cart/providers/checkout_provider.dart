import 'package:flutter_riverpod/flutter_riverpod.dart';
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

final cartProvider =
    StateNotifierProvider<CartNotifier, Map<String, int>>((ref) {
  final repo = CartRepository();
  return CartNotifier(repo);
});
