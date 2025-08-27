import 'dart:convert';
import 'package:http/http.dart' as http;
import 'special_pooja_model.dart';

class SpecialPrayerRepository {
  static const String _endpoint =
      'http://templerun.click/api/booking/poojas/?special_pooja=true';

  Future<List<SpecialPooja>> fetchSpecialPrayers() async {
    final response = await http.get(Uri.parse(_endpoint));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => SpecialPooja.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load special prayers');
    }
  }
}
