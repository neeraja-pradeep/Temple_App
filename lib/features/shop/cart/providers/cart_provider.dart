import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temple/features/shop/cart/data/model/cart_model.dart';
import 'package:temple/features/shop/cart/data/repositories/cart_repository.dart';

final cartProviders = StateNotifierProvider<CartListNotifier, List<CartItem>>((ref) {
  final repo = CartRepository();
  return CartListNotifier(repo);
});

class CartListNotifier extends StateNotifier<List<CartItem>> {
  final CartRepository _repository;
  CartListNotifier(this._repository) : super([]) {
    loadCart();
    
  }

  Future<void> loadCart() async {
    final items = await _repository.getCart();
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
}

