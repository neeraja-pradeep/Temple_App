import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:temple_app/features/pooja/data/models/malayalam_date_model.dart';
import 'package:temple_app/features/pooja/data/models/pooja_model.dart';
import '../models/pooja_category_model.dart';

class PoojaRepository {
  final String baseUrl = 'http://templerun.click/api';

  final String poojaCategoryBox = 'poojaCategoryBox';
  final String poojaBox = 'poojaBox';
  final String malayalamDateBox = 'malayalamDateBox';

  Future<List<PoojaCategory>> fetchPoojaCategories() async {
    final box = await Hive.openBox<PoojaCategory>(poojaCategoryBox);

    final url = Uri.parse('$baseUrl/booking/poojacategory/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = decoded['results'] as List<dynamic>;
      final categories = data.map((e) => PoojaCategory.fromJson(e)).toList();

      await box.clear();
      for (var category in categories) {
        await box.put(category.id, category);
      }
      return categories;
    } else {
      return box.values.toList();
    }
  }

  Future<List<Pooja>> fetchPoojasByCategory(int categoryId) async {
    print('🌐 Fetching poojas for category ID: $categoryId');

    // For now, let's skip caching to avoid type issues
    // TODO: Fix Hive caching later
    print('📦 Skipping cache for now to avoid type casting issues');

    final url = Uri.parse(
      '$baseUrl/booking/poojas/?pooja_category_id=$categoryId',
    );
    print('🌐 API Call: $url');
    final response = await http
        .get(url)
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            print('⏰ API call timed out after 10 seconds');
            throw Exception('Request timeout');
          },
        );

    print('📥 Response Status: ${response.statusCode}');
    print('📥 Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final dynamic responseData = jsonDecode(response.body);
      print('📦 Raw response data type: ${responseData.runtimeType}');
      print('📦 Raw response data: $responseData');

      List<dynamic> data;
      if (responseData is List) {
        data = responseData;
      } else if (responseData is Map && responseData.containsKey('results')) {
        data = responseData['results'] as List<dynamic>;
      } else if (responseData is Map && responseData.containsKey('data')) {
        data = responseData['data'] as List<dynamic>;
      } else {
        print('❌ Unexpected response format: $responseData');
        throw Exception('Unexpected response format');
      }

      print('📦 Parsed data length: ${data.length}');
      final poojas = data
          .map((e) => Pooja.fromJson(e as Map<String, dynamic>))
          .toList();
      print('📦 Created ${poojas.length} pooja objects');

      // Skip caching for now to avoid type issues
      return poojas;
    } else {
      print('❌ API Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load poojas');
    }
  }

  Future<MalayalamDateModel> fetchMalayalamDate(String date) async {
    final box = await Hive.openBox<MalayalamDateModel>(malayalamDateBox);

    final cached = box.get(date);
    if (cached != null) return cached;

    final response = await http.get(
      Uri.parse('$baseUrl/booking/malayalam-dates/?date=$date'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final malDate = MalayalamDateModel.fromJson(data.first);

      await box.put(date, malDate);
      return malDate;
    } else {
      if (cached != null) return cached;
      throw Exception('Failed to fetch Malayalam date');
    }
  }
}
