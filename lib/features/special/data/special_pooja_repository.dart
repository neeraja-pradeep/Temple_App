import 'dart:convert';
import 'package:http/http.dart' as http;
import 'special_pooja_model.dart';
import 'package:hive/hive.dart';
import 'package:temple_app/core/network/auth_headers.dart';

class SpecialPoojaRepository {
  static const String _endpoint =
      'http://templerun.click/api/booking/poojas/?banner=true';
  static String hiveBoxName = 'specialPoojas';

  // Add this flag for sync control
  bool skipApiFetch = false;

  Future<List<SpecialPooja>> fetchSpecialPoojas({
    bool forceRefresh = false,
  }) async {
    try {
      final box = await Hive.openBox<SpecialPooja>(hiveBoxName);

      // ✅ if manual clear mode is active — just return empty
      if (skipApiFetch && !forceRefresh) {
        print("⏭️ API fetch skipped (manual clear mode active)");
        return [];
      }

      if (!forceRefresh && box.isNotEmpty) {
        print("📦 Returning special poojas from Hive cache");
        return box.values.toList();
      }

      // Fetch from API if Hive is empty or force refresh
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

      final poojas = list
          .map((e) => SpecialPooja.fromJson(e as Map<String, dynamic>))
          .toList();

      // Cache the results
      await box.clear();
      await box.addAll(poojas);
      print("💾 Special poojas cached in Hive (${poojas.length} items)");

      return poojas;
    } catch (e) {
      print('fetchSpecialPoojas error: $e');

      // fallback to cache
      try {
        final box = await Hive.openBox<SpecialPooja>(hiveBoxName);
        if (box.isNotEmpty) {
          print("⚠️ Returning cached special poojas due to error");
          return box.values.toList();
        }
      } catch (_) {}

      return [];
    }
  }

  Future<void> saveSpecialPoojasToCache(List<SpecialPooja> poojas) async {
    final box = await Hive.openBox<SpecialPooja>(hiveBoxName);
    await box.clear();
    await box.addAll(poojas);
  }

  Future<void> clearSpecialPoojas() async {
    final box = await Hive.openBox<SpecialPooja>(hiveBoxName);
    await box.clear();
  }

  Future<void> resetSpecialPoojas() async {
    skipApiFetch = true;
    try {
      await clearSpecialPoojas();
      print('🧹 Cleared special poojas cache');
    } finally {
      skipApiFetch = false;
    }
  }
}
