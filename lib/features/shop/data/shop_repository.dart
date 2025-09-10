import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:temple/features/shop/data/models/shop_category_model.dart';
import 'package:temple/features/shop/data/models/shop_product_models.dart';
import 'package:temple/features/shop/data/models/cart_models.dart';

class ShopRepository {
  final String baseUrl = 'http://templerun.click/api';

  Future<List<ShopCategory>> fetchCategories() async {
    final url = Uri.parse('$baseUrl/ecommerce/category/');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return ShopCategory.listFromJsonString(response.body);
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<ShopProduct>> fetchShopProducts({int? categoryId}) async {
    final url = Uri.parse(
      categoryId == null
          ? '$baseUrl/ecommerce/shop-products/'
          : '$baseUrl/ecommerce/shop-products/?category=$categoryId',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return ShopProduct.listFromJsonString(response.body);
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<void> addToCart(AddToCartRequest request) async {
    final url = Uri.parse('$baseUrl/ecommerce/cart/');
    final requestBody = request.toJson();
    final jsonBody = jsonEncode(requestBody);

    print('🛒 CART API REQUEST:');
    print('URL: $url');
    print('Headers: {\'Content-Type\': \'application/json\'}');
    print('Body (Map): $requestBody');
    print('Body (JSON): $jsonBody');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonBody,
    );

    print('🛒 CART API RESPONSE:');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('Response Headers: ${response.headers}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add to cart: ${response.statusCode}');
    }
  }
}
