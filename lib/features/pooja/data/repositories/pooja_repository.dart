import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:temple/features/pooja/data/models/malayalam_date_model.dart';
import 'package:temple/features/pooja/data/models/pooja_model.dart';
import '../models/pooja_category_model.dart';

class PoojaRepository {
  final String baseUrl = 'http://templerun.click/api';

  
  final String poojaCategoryBox = 'pooja_category_box';
  final String poojaBox = 'pooja_box';
  final String malayalamDateBox = 'malayalam_date_box';

  Future<List<PoojaCategory>> fetchPoojaCategories() async {
    final box = await Hive.openBox<List>('pooja_category_box');
    if (box.isNotEmpty) {
      final cached = box.get('categories');
      if (cached != null) return List<PoojaCategory>.from(cached);
    }
    final url = Uri.parse('$baseUrl/booking/poojacategory/');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      final List<dynamic> data = decoded['results'];
      final categories = data.map((e) => PoojaCategory.fromJson(e)).toList();

      await box.clear();
      await box.put('categories', categories);

      return categories;
    } else {
      if (box.isNotEmpty) {
        final cached = box.get('categories');
        if (cached != null) return List<PoojaCategory>.from(cached);
      }
      throw Exception('Failed to load categories');
    }
  }


  Future<List<Pooja>> fetchPoojasByCategory(int categoryId) async {
    final box = await Hive.openBox<List>('pooja_box');

    final cached = box.get('poojas_$categoryId');
    if (cached != null) return List<Pooja>.from(cached);

    final url = Uri.parse('$baseUrl/booking/poojas/?pooja_category_id=$categoryId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body); 
      final poojas = data.map((e) => Pooja.fromJson(e)).toList();

     
      await box.put('poojas_$categoryId', poojas);

      return poojas;
    } else {
      if (cached != null) return List<Pooja>.from(cached);
      throw Exception('Failed to load poojas');
    }
  }

  Future<MalayalamDateModel> fetchMalayalamDate(String date) async {
    final box = await Hive.openBox<MalayalamDateModel>('malayalam_date_box');

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
