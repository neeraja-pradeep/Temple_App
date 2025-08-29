import 'dart:convert';
import 'package:http/http.dart' as http;
import 'special_pooja_model.dart';
import 'package:hive/hive.dart';

class SpecialPoojaRepository {
  static const String _endpoint =
      'http://templerun.click/api/booking/poojas/?banner=true';

  Future<List<SpecialPooja>> fetchSpecialPoojas() async {
    final response = await http.get(Uri.parse(_endpoint));
    if (response.statusCode == 200) {
      print(response.body);
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => SpecialPooja.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load special poojas');
    }
  }

  Future<void> saveSpecialPoojasToCache(List<SpecialPooja> poojas) async {
    final box = await Hive.openBox<SpecialPooja>('specialPoojas');
    await box.clear();
    await box.addAll(poojas);
  }
}
