import 'dart:convert';
import 'dart:developer';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:temple_app/core/constants/api_constants.dart';
import 'package:temple_app/core/network/auth_headers.dart';
import 'package:temple_app/features/shop/cart/data/model/cart_model.dart';

class CartRepository {
  /// Hive box helpers
  Future<Box<CartItem>> _cartBox() async =>
      Hive.openBox<CartItem>('cartBox');

  /// Pre-built endpoints
  Uri get _checkoutUri => Uri.parse(ApiConstants.checkout);
  Uri get _payUri => Uri.parse(ApiConstants.pay);
  Uri get _cartUri => Uri.parse(ApiConstants.cart);
  Uri _cartItemUri(int cartId) => Uri.parse(ApiConstants.cartItem(cartId));

  /// Shared HTTP helpers
  Future<Map<String, String>> _jsonHeaders() async =>
      AuthHeaders.json();

  Future<Map<String, String>> _readHeaders() async =>
      AuthHeaders.read();

  Future<List<CartItem>?> _fetchRemoteCartItems() async {
    try {
      final response = await http.get(
        _cartUri,
        headers: await _readHeaders(),
      );

      if (response.statusCode != 200) {
        log('❌ Failed to fetch cart: ${response.statusCode}');
        return null;
      }

      final decoded = jsonDecode(response.body);
      return _decodeCartItems(decoded);
    } catch (e, st) {
      log('🚨 Error loading cart items: $e');
      log(st.toString());
      return null;
    }
  }

  List<CartItem> _decodeCartItems(dynamic decoded) {
    final rawItems = _extractCartPayload(decoded);
    return rawItems
        .whereType<Map<String, dynamic>>()
        .map(CartItem.fromJson)
        .toList();
  }

  List<dynamic> _extractCartPayload(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final dynamic data = decoded['cart'] ?? decoded['results'] ?? [];
      return data is List ? List<dynamic>.from(data) : <dynamic>[];
    }
    if (decoded is List) {
      return List<dynamic>.from(decoded);
    }
    return <dynamic>[];
  }

  CartItem? _findCartItemByVariant(
    List<CartItem> items,
    String variantId,
  ) {
    for (final item in items) {
      if (item.productVariantId == variantId) {
        return item;
      }
    }
    return null;
  }

  /// Checkout / payment flows
  Future<bool> checkoutCart() async {
    try {
      final response = await http.post(
        _checkoutUri,
        headers: await _jsonHeaders(),
      );

      final ok = response.statusCode == 200 || response.statusCode == 201;
      if (!ok) {
        log('Checkout failed: ${response.statusCode} ${response.body}');
      }
      return ok;
    } catch (e, st) {
      log('Checkout error', error: e, stackTrace: st);
      return false;
    }
  }

  Future<bool> pay() async {
    try {
      final headers = await _jsonHeaders();
      log('[PAYMENT] REQUEST → POST ${_payUri.toString()}');
      _logLarge('[PAYMENT] REQUEST HEADERS', headers.toString());

      final response = await http.post(_payUri, headers: headers);

      log('[PAYMENT] RESPONSE ← ${response.statusCode}');
      _logLarge('[PAYMENT] RESPONSE HEADERS', response.headers.toString());
      _logBodyJsonPretty('[PAYMENT] RESPONSE BODY', response.body);

      final ok = response.statusCode == 200 || response.statusCode == 201;
      log('[PAYMENT] RESULT → ${ok ? 'SUCCESS' : 'FAIL'}');
      return ok;
    } catch (e, st) {
      log('[PAYMENT] EXCEPTION → $e');
      log(st.toString());
      return false;
    }
  }

  Future<int?> payAndReturnOrderId() async {
    try {
      final headers = await _jsonHeaders();
      log('[PAYMENT] REQUEST (orderId) → POST ${_payUri.toString()}');
      final response = await http.post(_payUri, headers: headers);
      log('[PAYMENT] RESPONSE (orderId) ← ${response.statusCode}');
      _logLarge('[PAYMENT] RESPONSE HEADERS', response.headers.toString());
      _logBodyJsonPretty('[PAYMENT] RESPONSE BODY', response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            final dynamic directId = decoded['id'] ?? decoded['order_id'];
            if (directId != null) {
              final parsed = int.tryParse(directId.toString());
              log('[PAYMENT] PARSED ORDER ID (direct) → $parsed');
              return parsed;
            }
            if (decoded['order'] is Map<String, dynamic>) {
              final inner = decoded['order'] as Map<String, dynamic>;
              final dynamic innerId = inner['id'] ?? inner['order_id'];
              if (innerId != null) {
                final parsed = int.tryParse(innerId.toString());
                log('[PAYMENT] PARSED ORDER ID (inner) → $parsed');
                return parsed;
              }
            }
          }
        } catch (parseErr, st) {
          log('[PAYMENT] ORDER ID PARSE ERROR → $parseErr');
          log(st.toString());
        }
      }
      log('[PAYMENT] NO ORDER ID FOUND IN RESPONSE');
      return null;
    } catch (e, st) {
      log('[PAYMENT] EXCEPTION DURING PAY (orderId) → $e');
      log(st.toString());
      return null;
    }
  }

  /// Cart mutations
  Future<bool> addAndUpdateCartItemToAPI({
    required String productVariantId,
    required int quantity,
  }) async {
    try {
      final cartItems = await _fetchRemoteCartItems();
      if (cartItems == null) {
        return false;
      }

      final existingItem =
          _findCartItemByVariant(cartItems, productVariantId);

      http.Response response;

      if (existingItem != null) {
        response = await http.patch(
          _cartItemUri(existingItem.id),
          headers: await _jsonHeaders(),
          body: jsonEncode({'quantity': quantity}),
        );
        log('🟡 PATCH /cart/${existingItem.id} → qty: $quantity');
      } else {
        response = await http.post(
          _cartUri,
          headers: await _jsonHeaders(),
          body: jsonEncode({
            'product_variant_id': productVariantId,
            'quantity': quantity,
          }),
        );
        log('🟢 POST add product $productVariantId → qty: $quantity');
      }

      log('⬅️ Response ${response.statusCode}: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        log('Cart updated successfully');
        await getinitStateCartFromAPi();
        return true;
      }

      log('❌ Failed updating cart: ${response.statusCode} ${response.body}');
      return false;
    } catch (e, st) {
      log('⚠️ Error updating cart: $e');
      log(st.toString());
      return false;
    }
  }

  Future<bool> deleteCartItemByProductVariantId(String productVariantId) async {
    try {
      final cartItems = await _fetchRemoteCartItems();
      if (cartItems == null) {
        return false;
      }

      final target = _findCartItemByVariant(cartItems, productVariantId);
      if (target == null) {
        log('⚠️ No cart item found for productVariantId: $productVariantId');
        return false;
      }

      final response = await http.delete(
        _cartItemUri(target.id),
        headers: await _jsonHeaders(),
      );

      final ok = response.statusCode == 200 || response.statusCode == 204;
      if (!ok) {
        log(
          '❌ Failed to delete cart item ${target.id}: '
          '${response.statusCode} ${response.body}',
        );
      } else {
        log('✅ Deleted cart item with cartId: ${target.id}');
      }
      return ok;
    } catch (e, st) {
      log('⚠️ Error deleting cart item: $e');
      log(st.toString());
      return false;
    }
  }

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
        log('🔄 Updated quantity for: ${cartItem.productVariantId}');
      } else {
        await box.add(cartItem);
        log('✅ Added new item: ${cartItem.productVariantId}');
      }

      return true;
    } catch (e, st) {
      log('🚨 Failed to add to cart: $e');
      log(st.toString());
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
          log('➖ Decreased quantity for: $productVariantId');
        } else {
          await box.delete(existingKey);
          log('🗑️ Removed item: $productVariantId');
        }
      }

      return true;
    } catch (e, st) {
      log('🚨 Failed to decrement from cart: $e');
      log(st.toString());
      return false;
    }
  }

  /// Local cache helpers
  Future<List<CartItem>> getinitStateCartFromAPi() async {
    final box = await _cartBox();
    try {
      final remoteItems = await _fetchRemoteCartItems();
      if (remoteItems != null) {
        await box.clear();
        await box.addAll(remoteItems);
        log('✅ Cart fetched from API: ${remoteItems.length} items');
        return remoteItems;
      }

      log('⚠️ Failed to fetch cart from API, returning Hive cache');
      return box.values.toList();
    } catch (e, st) {
      log('🚨 Error fetching cart: $e');
      log(st.toString());
      return box.values.toList();
    }
  }

  Future<List<CartItem>> getCart() async {
    try {
      final box = await _cartBox();
      return box.values.toList();
    } catch (e, st) {
      log('🚨 Failed to fetch cart: $e');
      log(st.toString());
      return [];
    }
  }

  Future<bool> removeFromCart(String productVariantId) async {
    try {
      final box = await _cartBox();
      final keyToDelete = box.keys.firstWhere(
        (key) => box.get(key)?.productVariantId == productVariantId,
        orElse: () => null,
      );

      if (keyToDelete != null) {
        await box.delete(keyToDelete);
        log('✅ Removed item: $productVariantId');
        return true;
      }

      log('⚠️ Item not found: $productVariantId');
      return false;
    } catch (e, st) {
      log('🚨 Failed to remove from cart: $e');
      log(st.toString());
      return false;
    }
  }

  Future<bool> clearCart() async {
    try {
      final box = await _cartBox();
      await box.clear();
      log('✅ Cart cleared successfully after order completion');
      return true;
    } catch (e, st) {
      log('🚨 Failed to clear cart: $e');
      log(st.toString());
      return false;
    }
  }

  /// Logging helpers
  void _logBodyJsonPretty(String label, String body) {
    String printable;
    try {
      final dynamic decoded = jsonDecode(body);
      printable = const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
      printable = body;
    }
    _logLarge(label, printable);
  }

  void _logLarge(String label, String text) {
    const chunkSize = 800;
    if (text.length <= chunkSize) {
      final line = '$label →\n$text';
      log(line);
      // ignore: avoid_print
      print(line);
      return;
    }
    final header = '$label (chunked) → length=${text.length}';
    log(header);
    // ignore: avoid_print
    print(header);
    int start = 0;
    var index = 1;
    while (start < text.length) {
      final end = (start + chunkSize < text.length)
          ? start + chunkSize
          : text.length;
      final chunk = text.substring(start, end);
      final part = '$label [part $index] →\n$chunk';
      log(part);
      // ignore: avoid_print
      print(part);
      start = end;
      index++;
    }
  }
}
