import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:temple_app/core/constants/api_constants.dart';
import 'package:temple_app/features/shop/data/model/category/store_category.dart';
import '../../../../core/services/token_storage_service.dart';

class CategoryRepository {
  final String baseUrl = ApiConstants.baseUrl;
  static String hiveBoxName = 'store_categories';

  Future<List<StoreCategory>> fetchCategories({bool forceRefresh = false}) async {
    try {
      // Open Hive box for categories
      final box = await Hive.openBox<StoreCategory>(hiveBoxName);

      // If cache exists and not forcing refresh → return cached
      if (!forceRefresh && box.isNotEmpty) {
        print("📦 Returning categories from Hive cache");
        return box.values.toList();
      }

      // Get authorization header with bearer token
      final authHeader = TokenStorageService.getAuthorizationHeader();
      if (authHeader == null) {
        throw Exception(
          'No valid authentication token found. Please login again.',
        );
      }

      final headers = {
        'Accept': 'application/json',
        'Authorization': authHeader,
      };

      print(
        '🌐 Making shop categories API call to: $baseUrl/ecommerce/category/',
      );
      print('🔐 Authorization header: $authHeader');

      final response = await http.get(
        Uri.parse("$baseUrl/ecommerce/category/"),
        headers: headers,
      );

      print('📥 Shop Categories API Response Status: ${response.statusCode}');
      print('📥 Shop Categories API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body is List) {
          final categories = body.map((e) => StoreCategory.fromJson(e)).toList();

          // ✅ Clear old cache & save new data into Hive
          await box.clear();
          await box.addAll(categories);

          print("💾 Categories cached in Hive (${categories.length} items)");

          return categories;
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

      // If API fails but cache exists → return cached data
      try {
        final box = await Hive.openBox<StoreCategory>(hiveBoxName);
        if (box.isNotEmpty) {
          print("⚠️ Returning cached categories due to API error");
          return box.values.toList();
        }
      } catch (_) {}

      return [];
    }
  }
}
