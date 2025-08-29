import 'dart:convert';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:temple/features/special/data/models/special_pooja_model.dart';

class SpecialPoojaRepository {
  static const String _endpoint =
      'http://templerun.click/api/booking/poojas/?banner=true';

  final boxName = 'special_poojas';

  Future<List<SpecialPooja>> fetchSpecialPoojas() async {
    try{
    final response = await http.get(Uri.parse(_endpoint));
    if (response.statusCode == 200) {
      print(response.body);
      final List<dynamic> data = json.decode(response.body);
      final poojas = data.map((e) => SpecialPooja.fromJson(e)).toList();

      // saving to hive
      final box = await Hive.openBox<SpecialPooja>(boxName);
      await box.clear();
      await box.addAll(poojas);
      print("CACHED Special poojas");

      return poojas;

    } else {
      throw Exception('Failed to load special poojas');
    }
   }
   catch(e){
    // api response failed -> we load the cache 
    final box = await Hive.openBox<SpecialPooja>(boxName);
    final cachedPooja = box.values.toList();
    if (cachedPooja.isNotEmpty){
      return cachedPooja;
    }
    rethrow;
   }
  }
}
