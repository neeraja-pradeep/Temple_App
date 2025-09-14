import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:temple/core/constants/api_constants.dart';
import 'package:temple/features/shop/cart/data/model/cart_model.dart';

class CartRepository {
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
log(     response.body);
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
