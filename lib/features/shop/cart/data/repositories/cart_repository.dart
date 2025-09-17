import 'dart:developer';
import 'package:hive/hive.dart';
import 'package:temple/features/shop/cart/data/model/cart_model.dart';

class CartRepository {
  /// 🔑 Get the cart box
  Future<Box<CartItem>> _cartBox() async {
    return await Hive.openBox<CartItem>('cartBox');
  }

  /// ➕ Add or update item
  Future<bool> addToCart(CartItem cartItem) async {
    try {
      final box = await _cartBox();

      final existingKey = box.keys.firstWhere(
        (key) => box.get(key)?.productVariantId == cartItem.productVariantId,
        orElse: () => null,
      );

      if (existingKey != null) {
        final existingItem = box.get(existingKey)!;
        final updatedItem = CartItem(
          id: existingItem.id,
          productVariantId: existingItem.productVariantId,
          name: existingItem.name,
          sku: existingItem.sku,
          price: existingItem.price,
          quantity: existingItem.quantity + cartItem.quantity,
          productimage: existingItem.productimage,
        );
        await box.put(existingKey, updatedItem);
        log("🔄 Updated quantity for: ${cartItem.productVariantId}");
      } else {
        await box.add(cartItem);
        log("✅ Added new item: ${cartItem.productVariantId}");
      }

      return true;
    } catch (e, stackTrace) {
      log("🚨 Failed to add to cart: $e");
      log("🧾 $stackTrace");
      return false;
    }
  }Future<bool> decrementFromCart(String productVariantId) async {
  try {
    final box = await _cartBox();

    final existingKey = box.keys.firstWhere(
      (key) => box.get(key)?.productVariantId == productVariantId,
      orElse: () => null,
    );

    if (existingKey != null) {
      final existingItem = box.get(existingKey)!;

      if (existingItem.quantity > 1) {
        // Reduce quantity
        final updatedItem = CartItem(
          id: existingItem.id,
          productVariantId: existingItem.productVariantId,
          name: existingItem.name,
          sku: existingItem.sku,
          price: existingItem.price,
          quantity: existingItem.quantity - 1,
          productimage: existingItem.productimage,
        );
        await box.put(existingKey, updatedItem);
        log("➖ Decreased quantity for: $productVariantId");
      } else {
        // Remove item if quantity = 1
        await box.delete(existingKey);
        log("🗑️ Removed item: $productVariantId");
      }
    }

    return true;
  } catch (e, stackTrace) {
    log("🚨 Failed to decrement from cart: $e");
    log("🧾 $stackTrace");
    return false;
  }
}

 

  /// 🛒 Get all items
  Future<List<CartItem>> getCart() async {
    try {
      final box = await _cartBox();
      return box.values.toList();
    } catch (e, stackTrace) {
      log("🚨 Failed to fetch cart: $e");
      log("🧾 $stackTrace");
      return [];
    }
  }

  /// 🗑 Remove item
  Future<bool> removeFromCart(String productVariantId) async {
    try {
      final box = await _cartBox();

      final keyToDelete = box.keys.firstWhere(
        (key) => box.get(key)?.productVariantId == productVariantId,
        orElse: () => null,
      );

      if (keyToDelete != null) {
        await box.delete(keyToDelete);
        log("✅ Removed item: $productVariantId");
        return true;
      } else {
        log("⚠️ Item not found: $productVariantId");
        return false;
      }
    } catch (e, stackTrace) {
      log("🚨 Failed to remove from cart: $e");
      log("🧾 $stackTrace");
      return false;
    }
  }
}
