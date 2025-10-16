import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:temple_app/features/pooja/data/models/malayalam_date_model.dart';
import 'package:temple_app/features/pooja/data/models/pooja_model.dart';
import '../models/pooja_category_model.dart';
import '../../../../core/services/complete_token_service.dart';

class PoojaRepository {
  final String baseUrl = 'http://templerun.click/api';

  final String poojaCategoryBox = 'poojaCategoryBox';
  final String poojaBox = 'poojaBox';
  final String malayalamDateBox = 'malayalamDateBox';

  // ===================================================
  // ✅ 1️⃣ FETCH POOJA CATEGORIES
  // ===================================================
  Future<List<PoojaCategory>> fetchPoojaCategories() async {
    final box = await Hive.openBox<PoojaCategory>(poojaCategoryBox);

    // 1️⃣ Check Hive first
    final cached = box.values.toList();
    if (cached.isNotEmpty) {
      print('📦 Returning ${cached.length} cached pooja categories');
      return cached;
    }

    // 2️⃣ Fetch from API only if cache empty
    final url = Uri.parse('$baseUrl/booking/poojacategory/');
    final authHeader = await CompleteTokenService.getAuthorizationHeader();
    if (authHeader == null) throw Exception('No valid auth token found');

    print('🌐 Fetching categories from API...');
    final response = await http.get(
      url,
      headers: {'Accept': 'application/json', 'Authorization': authHeader},
    );

    print('📥 Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = decoded['results'] as List<dynamic>;
      final categories = data.map((e) => PoojaCategory.fromJson(e)).toList();

      await box.clear();
      for (final c in categories) {
        await box.put(c.id, c);
      }
      print('💾 Saved ${categories.length} categories to Hive');
      return box.values.toList(); // Return from Hive again
    } else {
      throw Exception('Failed to load pooja categories');
    }
  }

  // ===================================================
  // ✅ 2️⃣ FETCH POOJAS BY CATEGORY
  // ===================================================
  Future<List<Pooja>> fetchPoojasByCategory(int categoryId) async {
    final boxName = '$poojaBox-$categoryId';
    final box = await Hive.openBox<Pooja>(boxName);

    // 1️⃣ Try Hive first
    final cached = box.values.toList();
    if (cached.isNotEmpty) {
      print('📦 Returning ${cached.length} cached poojas for category $categoryId');
      return cached;
    }

    // 2️⃣ If cache empty, fetch from API
    final url = Uri.parse('$baseUrl/booking/poojas/?pooja_category_id=$categoryId');
    final authHeader = await CompleteTokenService.getAuthorizationHeader();
    if (authHeader == null) throw Exception('No valid auth token found');

    print('🌐 Fetching poojas for category $categoryId...');
    final response = await http.get(
      url,
      headers: {'Accept': 'application/json', 'Authorization': authHeader},
    );

    print('📥 Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final dynamic responseData = jsonDecode(response.body);
      List<dynamic> data;
      if (responseData is List) {
        data = responseData;
      } else if (responseData is Map && responseData.containsKey('results')) {
        data = responseData['results'];
      } else {
        throw Exception('Unexpected response format');
      }

      final poojas = data.map((e) => Pooja.fromJson(e)).toList();
      await box.clear();
      for (final p in poojas) {
        await box.put(p.id, p);
      }
      print('💾 Saved ${poojas.length} poojas to Hive');
      return box.values.toList(); // Return from Hive again
    } else {
      throw Exception('Failed to load poojas');
    }
  }

  // ===================================================
  // ✅ 3️⃣ FETCH MALAYALAM DATE
  // ===================================================
  Future<MalayalamDateModel> fetchMalayalamDate(String date) async {
    final box = await Hive.openBox<MalayalamDateModel>(malayalamDateBox);

    // 1️⃣ Try cache first
    final cached = box.get(date);
    if (cached != null) {
      print('📦 Returning cached Malayalam date for $date');
      return cached;
    }

    // 2️⃣ Fetch from API
    final url = Uri.parse('$baseUrl/booking/malayalam-dates/?date=$date');
    final authHeader = await CompleteTokenService.getAuthorizationHeader();
    if (authHeader == null) throw Exception('No valid auth token found');

    print('🌐 Fetching Malayalam date from API...');
    final response = await http.get(
      url,
      headers: {'Accept': 'application/json', 'Authorization': authHeader},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final malDate = MalayalamDateModel.fromJson(data.first);

      await box.put(date, malDate);
      print('💾 Saved Malayalam date for $date to Hive');
      return malDate;
    } else {
      throw Exception('Failed to fetch Malayalam date');
    }
  }
}
