import 'package:http/http.dart' as http;
import 'package:temple/features/shop/data/models/shop_category_model.dart';
import 'package:temple/features/shop/data/models/shop_product_models.dart';

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
}
