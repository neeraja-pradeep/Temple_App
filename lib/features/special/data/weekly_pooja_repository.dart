import 'dart:convert';
import 'package:http/http.dart' as http;
import 'special_pooja_model.dart';
import 'package:hive/hive.dart';

class WeeklyPoojaRepository {
  static const String _endpoint =
      'http://templerun.click/api/booking/poojas/weekly_pooja';

  Future<List<SpecialPooja>> fetchWeeklyPoojas() async {
    try {
      final uri = Uri.parse(_endpoint);
      final response = await http.get(
        uri,
        headers: const {'Accept': 'application/json'},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to load weekly poojas: ${response.statusCode}');
      }
      final dynamic decoded = json.decode(response.body);
      List<dynamic> list;
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map<String, dynamic>) {
        list =
            (decoded['poojas'] as List?) ??
            (decoded['results'] as List?) ??
            (decoded['data'] as List?) ??
            <dynamic>[];
      } else {
        list = <dynamic>[];
      }
      return list
          .map((e) => SpecialPooja.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('fetchWeeklyPoojas error: $e');
      rethrow;
    }
  }

  Future<void> saveWeeklyPoojasToCache(List<SpecialPooja> poojas) async {
    final box = await Hive.openBox<SpecialPooja>('weeklyPoojas');
    await box.clear();
    await box.addAll(poojas);
  }
}
