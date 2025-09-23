import 'dart:convert';
import 'dart:developer';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:temple/core/constants/api_constants.dart';
import 'package:temple/features/shop/cart/data/model/cart_model.dart';

class CartRepository {
  final String baseUrl = ApiConstants.baseUrl;

  /// 🔑 Get the cart box
  Future<Box<CartItem>> _cartBox() async {
    return await Hive.openBox<CartItem>('cartBox');
  }

  /// 🛒 Trigger checkout
  Future<bool> checkoutCart() async {
    try {
      final uri = Uri.parse("$baseUrl/ecommerce/checkout/");
      final headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

      // Raw request log
      print("HTTP REQUEST → POST ${uri.toString()}");
      print("REQUEST HEADERS → ${headers.toString()}");

      final response = await http.post(uri, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("HTTP RESPONSE ← ${response.statusCode}");
        print("RESPONSE BODY ← ${response.body}");
        return true;
      } else {
        print("HTTP RESPONSE ← ${response.statusCode}");
        print("RESPONSE BODY ← ${response.body}");
        return false;
      }
    } catch (e, st) {
      print("EXCEPTION DURING CHECKOUT → $e");
      print(st.toString());
      return false;
    }
  }

  /// 💳 Initiate payment (no payload)
  Future<bool> pay() async {
    try {
      final uri = Uri.parse("$baseUrl/ecommerce/pay/");
      final headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

      log("[PAYMENT] REQUEST → POST ${uri.toString()}");
      _logLarge("[PAYMENT] REQUEST HEADERS", headers.toString());

      final response = await http.post(uri, headers: headers);

      log("[PAYMENT] RESPONSE ← ${response.statusCode}");
      _logLarge("[PAYMENT] RESPONSE HEADERS", response.headers.toString());
      _logBodyJsonPretty("[PAYMENT] RESPONSE BODY", response.body);

      final ok = response.statusCode == 200 || response.statusCode == 201;
      log("[PAYMENT] RESULT → ${ok ? 'SUCCESS' : 'FAIL'}");
      return ok;
    } catch (e, st) {
      log("[PAYMENT] EXCEPTION DURING PAY → $e");
      log(st.toString());
      return false;
    }
  }

  /// 💳 Initiate payment and try to extract order id from response
  Future<int?> payAndReturnOrderId() async {
    try {
      final uri = Uri.parse("$baseUrl/ecommerce/pay/");
      final headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
      };
      log("[PAYMENT] REQUEST (orderId) → POST ${uri.toString()}");
      final response = await http.post(uri, headers: headers);
      log("[PAYMENT] RESPONSE (orderId) ← ${response.statusCode}");
      _logLarge("[PAYMENT] RESPONSE HEADERS", response.headers.toString());
      _logBodyJsonPretty("[PAYMENT] RESPONSE BODY", response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            final dynamic directId = decoded['id'] ?? decoded['order_id'];
            if (directId != null) {
              final parsed = int.tryParse(directId.toString());
              log("[PAYMENT] PARSED ORDER ID (direct) → $parsed");
              return parsed;
            }
            if (decoded['order'] is Map<String, dynamic>) {
              final inner = decoded['order'] as Map<String, dynamic>;
              final dynamic innerId = inner['id'] ?? inner['order_id'];
              if (innerId != null) {
                final parsed = int.tryParse(innerId.toString());
                log("[PAYMENT] PARSED ORDER ID (inner) → $parsed");
                return parsed;
              }
            }
          }
        } catch (parseErr, st) {
          log("[PAYMENT] ORDER ID PARSE ERROR → $parseErr");
          log(st.toString());
        }
      }
      log("[PAYMENT] NO ORDER ID FOUND IN RESPONSE");
      return null;
    } catch (e, st) {
      log("[PAYMENT] EXCEPTION DURING PAY (orderId) → $e");
      log(st.toString());
      return null;
    }
  }

  /// Pretty-print and chunk large JSON/text bodies to avoid logcat truncation
  void _logBodyJsonPretty(String label, String body) {
    String printable;
    try {
      final dynamic decoded = jsonDecode(body);
      printable = const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
      printable = body; // not JSON, log raw
    }
    _logLarge(label, printable);
  }

  void _logLarge(String label, String text) {
    const int chunkSize = 800; // safe chunk size for Android logcat
    if (text.length <= chunkSize) {
      final line = "$label →\n$text";
      log(line);
      // Also print for environments that filter out log()
      // ignore: avoid_print
      print(line);
      return;
    }
    final header = "$label (chunked) → length=${text.length}";
    log(header);
    // ignore: avoid_print
    print(header);
    int start = 0;
    int index = 1;
    while (start < text.length) {
      final end = (start + chunkSize < text.length)
          ? start + chunkSize
          : text.length;
      final chunk = text.substring(start, end);
      final part = "$label [part $index] →\n$chunk";
      log(part);
      // ignore: avoid_print
      print(part);
      start = end;
      index++;
    }
  }

  /// 🗑 Delete cart item by cartId

  Future<bool> deleteCartItemByProductVariantId(String productVariantId) async {
    try {
      // 1️⃣ Fetch all cart items
      final fetchResponse = await http.get(
        Uri.parse("$baseUrl/ecommerce/cart/"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      if (fetchResponse.statusCode != 200) {
        log("❌ Failed to fetch cart: ${fetchResponse.statusCode}");
        return false;
      }

      final decoded = jsonDecode(fetchResponse.body);

      final List<dynamic> rawCartItems = decoded is Map<String, dynamic>
          ? (decoded["cart"] ?? []) as List<dynamic>
          : (decoded as List<dynamic>);

      // 2️⃣ Find cart item by product_variant.id
      final cartItem = rawCartItems.firstWhere(
        (item) => item["product_variant"]["id"].toString() == productVariantId,
        orElse: () => null,
      );

      if (cartItem == null) {
        log("⚠️ No cart item found for productVariantId: $productVariantId");
        return false;
      }

      final int cartId = cartItem["id"]; // the cart item id needed for DELETE

      // 3️⃣ Call DELETE
      final response = await http.delete(
        Uri.parse("$baseUrl/ecommerce/cart/$cartId/"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        log("✅ Deleted cart item with cartId: $cartId");
        return true;
      } else {
        log(
          "❌ Failed to delete cart item $cartId: ${response.statusCode} ${response.body}",
        );
        return false;
      }
    } catch (e, st) {
      log("⚠️ Error deleting cart item: $e");
      log("$st");
      return false;
    }
  }

  Future<bool> addAndUpdateCartItemToAPI({
    required String productVariantId,
    required int quantity,
  }) async {
    try {
      final fetchResponse = await http.get(
        Uri.parse("$baseUrl/ecommerce/cart/"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      if (fetchResponse.statusCode != 200) {
        log("❌ Failed to fetch cart: ${fetchResponse.statusCode}");
        return false;
      }

      final decoded = jsonDecode(fetchResponse.body);

      // Support both "cart" and fallback keys
      final List<dynamic> rawCartItems = decoded is Map<String, dynamic>
          ? (decoded["cart"] ?? decoded["results"] ?? []) as List<dynamic>
          : (decoded as List<dynamic>);

      final List<CartItem> cartItems = rawCartItems
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList();

      // Use indexWhere to avoid firstWhere null issues
      final index = cartItems.indexWhere(
        (item) =>
            item.productVariantId.toString() == productVariantId.toString(),
      );

      final CartItem? existingItem = index != -1 ? cartItems[index] : null;

      http.Response response;

      if (existingItem != null) {
        final cartId = existingItem.id;
        final newQuantity = quantity; // choose increment or replace as needed

        response = await http.patch(
          Uri.parse("$baseUrl/ecommerce/cart/$cartId/"),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body: jsonEncode({"quantity": newQuantity}),
        );

        log("🟡 PATCH /cart/$cartId → qty: $newQuantity");
        log("⬅️ Response ${response.statusCode}: ${response.body}");
      } else {
        response = await http.post(
          Uri.parse("$baseUrl/ecommerce/cart/"),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body: jsonEncode({
            "product_variant_id": productVariantId,
            "quantity": quantity,
          }),
        );

        log("🟢 POST add product $productVariantId → qty: $quantity");
        log("⬅️ Response ${response.statusCode}: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("✅ Cart updated: ${response.body}");
        return true;
      } else {
        log("❌ Failed: ${response.statusCode} ${response.body}");
        return false;
      }
    } catch (e, st) {
      log("⚠️ Error: $e");
      log("$st");
      return false;
    }
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
  }

  Future<bool> decrementFromCart(String productVariantId) async {
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

  Future<List<CartItem>> getinitStateCartFromAPi() async {
    final box = await _cartBox();
    try {
      // 1️⃣ Fetch from API
      final response = await http.get(
        Uri.parse("$baseUrl/ecommerce/cart/"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> rawCartItems = data["cart"] ?? [];

        // 2️⃣ Map API response to Hive model
        final List<CartItem> cartItems = rawCartItems.map((item) {
          final variant = item["product_variant"];
          return CartItem(
            id: item["id"],
            productVariantId: variant["id"].toString(),
            name: variant["name"],
            sku: variant["sku"],
            price: variant["price"],
            quantity: item["quantity"],
            productimage: item["product_image"] ?? "",
          );
        }).toList();

        // 3️⃣ Save/update Hive
        await box.clear(); // clear old cart
        await box.addAll(cartItems);

        log("✅ Cart fetched from API: ${cartItems.length} items");
        return cartItems;
      } else {
        log("⚠️ Failed to fetch cart from API, returning Hive cache");
        return box.values.toList();
      }
    } catch (e, st) {
      log("🚨 Error fetching cart: $e");
      log("$st");
      return box.values.toList();
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

  /// 🗑 Clear all cart items (used after successful order completion)
  Future<bool> clearCart() async {
    try {
      final box = await _cartBox();
      await box.clear();
      log("✅ Cart cleared successfully after order completion");
      return true;
    } catch (e, stackTrace) {
      log("🚨 Failed to clear cart: $e");
      log("🧾 $stackTrace");
      return false;
    }
  }
}
