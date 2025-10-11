import 'dart:convert';
import 'package:http/http.dart' as http;
import 'special_pooja_model.dart';
import 'package:hive/hive.dart';
import 'package:temple_app/core/network/auth_headers.dart';

class WeeklyPoojaRepository {
  static const String _endpoint =
      'http://templerun.click/api/booking/poojas/weekly_pooja';
  static String hiveBoxName = 'weeklyPoojas';

  // Add this flag for sync control
  bool skipApiFetch = false;

  Future<List<SpecialPooja>> fetchWeeklyPoojas({
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
        print("📦 Returning weekly poojas from Hive cache");
        return box.values.toList();
      }

      // Fetch from API if Hive is empty or force refresh
      final uri = Uri.parse(_endpoint);

      // Get authorization header with bearer token
      final authHeader = await AuthHeaders.requireToken();
      final headers = AuthHeaders.readFromHeader(authHeader);

      print('🌐 Making weekly pooja API call to: $uri');
      print('🔐 Authorization header: $authHeader');

      final response = await http.get(uri, headers: headers);

      print('📥 Weekly Pooja API Response Status: ${response.statusCode}');
      print('📥 Weekly Pooja API Response Body: ${response.body}');

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

      final poojas = list
          .map((e) => SpecialPooja.fromJson(e as Map<String, dynamic>))
          .toList();

      // Cache the results
      await box.clear();
      await box.addAll(poojas);
      print("💾 Weekly poojas cached in Hive (${poojas.length} items)");

      return poojas;
    } catch (e) {
      print('fetchWeeklyPoojas error: $e');

      // fallback to cache
      try {
        final box = await Hive.openBox<SpecialPooja>(hiveBoxName);
        if (box.isNotEmpty) {
          print("⚠️ Returning cached weekly poojas due to error");
          return box.values.toList();
        }
      } catch (_) {}

      return [];
    }
  }

  Future<void> saveWeeklyPoojasToCache(List<SpecialPooja> poojas) async {
    final box = await Hive.openBox<SpecialPooja>(hiveBoxName);
    await box.clear();
    await box.addAll(poojas);
  }

  Future<void> clearWeeklyPoojas() async {
    final box = await Hive.openBox<SpecialPooja>(hiveBoxName);
    await box.clear();
  }

  Future<void> resetWeeklyPoojas() async {
    skipApiFetch = true;
    try {
      await clearWeeklyPoojas();
      print('🧹 Cleared weekly poojas cache');
    } finally {
      skipApiFetch = false;
    }
  }
}
