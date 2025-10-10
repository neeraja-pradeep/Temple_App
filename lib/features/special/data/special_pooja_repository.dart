import 'dart:convert';
import 'package:http/http.dart' as http;
import 'special_pooja_model.dart';
import 'package:hive/hive.dart';
import 'package:temple_app/core/network/auth_headers.dart';

class SpecialPoojaRepository {
  static const String _endpoint =
      'http://templerun.click/api/booking/poojas/?banner=true';

  Future<List<SpecialPooja>> fetchSpecialPoojas() async {
    try {
      final uri = Uri.parse(_endpoint);

      // Get authorization header with bearer token
      final authHeader = await AuthHeaders.requireToken();
      final headers = AuthHeaders.readFromHeader(authHeader);

      print('🌐 Making banner API call to: $uri');
      print('🔐 Authorization header: $authHeader');

      final response = await http.get(uri, headers: headers);

      print('📥 Banner API Response Status: ${response.statusCode}');
      print('📥 Banner API Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load special poojas: ${response.statusCode}',
        );
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
      print('fetchSpecialPoojas error: $e');
      rethrow;
    }
  }

  Future<void> saveSpecialPoojasToCache(List<SpecialPooja> poojas) async {
    final box = await Hive.openBox<SpecialPooja>('specialPoojas');
    await box.clear();
    await box.addAll(poojas);
  }
}
