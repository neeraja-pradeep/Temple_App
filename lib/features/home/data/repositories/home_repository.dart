import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/home_pooja_category_model.dart';

class HomeRepository {
  final String baseUrl = 'http://templerun.click/api';

  Future<HomePoojaCategoryResponse> fetchPoojaCategories() async {
    final url = Uri.parse('$baseUrl/booking/poojacategory/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return HomePoojaCategoryResponse.fromJson(data);
    } else {
      throw Exception('Failed to load pooja categories');
    }
  }
}
