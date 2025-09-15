import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:temple/core/constants/api_constants.dart';
import 'package:temple/features/shop/cart/data/model/cart_model.dart';

class CartRepository {
  Future<List<CartItem>> getCart() async {
    try {
      final url = Uri.parse("${ApiConstants.baseUrl}/ecommerce/cart/");
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final cartList = data['cart'] as List<dynamic>;
        return cartList.map((json) => CartItem.fromJson(json)).toList();
      } else {
        // Log the error status
        print(
          "Failed to fetch cart. Status code: ${response.statusCode}, Body: ${response.body}",
        );
        return [];
      }
    } catch (e, stackTrace) {
      // Log any exceptions
      print("Exception while fetching cart: $e");
      print(stackTrace);
      return [];
    }
  }

  Future removeFromCart(String productVariantId) async {
    final url = Uri.parse("$ApiConstants.baseUrl/ecommerce/cart/remove/");

    final body = jsonEncode({"product_variant_id": productVariantId});

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      // TODO: Update Hive/Local Storage here
      return true;
    } else {
      throw Exception("Failed to remove from cart: ${response.body}");
    }
  }

  /// Add item or increase quantity
  Future<CartItem> addToCart(
    String productVariantId, {
    int quantity = 1,
  }) async {
    final url = Uri.parse("${ApiConstants.baseUrl}/ecommerce/cart/");
    final body = jsonEncode({
      "product_variant_id": productVariantId,
      "quantity": quantity,
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );
    log(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return CartItem.fromJson(json);
    } else {
      throw Exception("Failed to add to cart: ${response.body}");
    }
  }

  /// Decrease quantity (if > 1) or remove (if quantity == 0)
  Future<CartItem> updateCartQuantity(
    String productVariantId,
    int quantity,
  ) async {
    final url = Uri.parse("${ApiConstants.baseUrl}/ecommerce/cart/");
    final body = jsonEncode({
      "product_variant_id": productVariantId,
      "quantity": quantity,
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return CartItem.fromJson(json);
    } else {
      throw Exception("Failed to update cart: ${response.body}");
    }
  }
}
