import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:temple/core/constants/api_constants.dart';
import 'package:temple/features/shop/data/model/product/product_category.dart';

class CategoryProductRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future addToCart(String productVariantId, {int quantity = 1}) async {
    final url = Uri.parse("$baseUrl/ecommerce/cart/");

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
      final data = jsonDecode(response.body);

      // TODO: Update Hive/Local Storage here
      return data;
    } else {
      throw Exception("Failed to add to cart: ${response.body}");
    }
  }

  /// Increment quantity
  Future incrementCart(String productVariantId, int currentQuantity) async {
    final newQuantity = currentQuantity + 1;
    return await addToCart(productVariantId, quantity: newQuantity);
  }

  /// Decrement quantity
  Future decrementCart(String productVariantId, int currentQuantity) async {
    final newQuantity = currentQuantity - 1;

    if (newQuantity > 0) {
      return await addToCart(productVariantId, quantity: newQuantity);
    } else {
      return await removeFromCart(productVariantId);
    }
  }

  /// Remove from cart (when quantity = 0)
  Future removeFromCart(String productVariantId) async {
    final url = Uri.parse("$baseUrl/ecommerce/cart/remove/");

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

  Future<List<CategoryProductModel>> fetchCategoryProduct(
    int? categoryId,
  ) async {
    try {
      final uri = Uri.parse(
        categoryId == null
            ? "$baseUrl/ecommerce/shop-products/"
            : "$baseUrl/ecommerce/shop-products/?category=$categoryId",
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        // Ensure body is a list
        if (body is List) {
          return body.map((e) => CategoryProductModel.fromJson(e)).toList();
        } else {
          throw Exception("Invalid response format: expected a List");
        }
      } else {
        throw Exception(
          "Failed to fetch products. Status Code: ${response.statusCode}",
        );
      }
    } catch (e) {
      // Log or rethrow depending on your needs
      print("Error in fetchCategoryProduct: $e");
      return [];
    }
  }
}
