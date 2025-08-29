import 'dart:convert';
import 'package:http/http.dart' as http;
import 'special_pooja_model.dart';
import 'package:hive/hive.dart';

class WeeklyPoojaRepository {
  static const String _endpoint =
      'http://templerun.click/api/booking/poojas/weekly_pooja';

  Future<List<SpecialPooja>> fetchWeeklyPoojas() async {
    final response = await http.get(Uri.parse(_endpoint));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => SpecialPooja.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load weekly poojas');
    }
  }

  Future<void> saveWeeklyPoojasToCache(List<SpecialPooja> poojas) async {
    final box = await Hive.openBox<SpecialPooja>('weeklyPoojas');
    await box.clear();
    await box.addAll(poojas);
  }
}
