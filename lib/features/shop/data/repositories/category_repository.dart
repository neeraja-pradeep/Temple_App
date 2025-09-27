import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:temple/core/constants/api_constants.dart';
import 'package:temple/features/shop/data/model/category/store_category.dart';

class CategoryRepository {
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<StoreCategory>> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/ecommerce/category/"),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body is List) {
          return body.map((e) => StoreCategory.fromJson(e)).toList();
        } else {
          throw Exception("Invalid response format: expected a List");
        }
      } else {
        throw Exception(
          "Failed to fetch categories. Status Code: ${response.statusCode}",
        );
      }
    } catch (e) {
      print("Error fetching categories: $e");
      return [];
    }
  }
}
