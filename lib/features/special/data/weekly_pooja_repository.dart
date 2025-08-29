import 'dart:convert';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:temple/features/special/data/models/special_pooja_model.dart';

class WeeklyPoojaRepository {
  static const String _endpoint =
      'http://templerun.click/api/booking/poojas/weekly_pooja';

   final boxName = 'weekly_poojas';

  Future<List<SpecialPooja>> fetchWeeklyPoojas() async {
    try{
    final response = await http.get(Uri.parse(_endpoint));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final poojas = data.map((e) => SpecialPooja.fromJson(e)).toList();

      final box = await Hive.openBox<SpecialPooja>(boxName);
      await box.clear();
      await box.addAll(poojas);
      print("CACHED Weekly poojas");

      return poojas;

    } else {
      throw Exception('Failed to load weekly poojas');
    }
   }
   catch(e){
    final box = await Hive.openBox<SpecialPooja>(boxName);
    final cachedPoojas = box.values.toList();
    if (cachedPoojas.isNotEmpty){
      return cachedPoojas;
    }
    rethrow;
   }
  }
}
