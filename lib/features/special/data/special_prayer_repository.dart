import 'dart:convert';
import 'package:http/http.dart' as http;
import 'special_pooja_model.dart';
import 'package:hive/hive.dart';
import '../../../core/services/complete_token_service.dart';

class SpecialPrayerRepository {
  static const String _endpoint =
      'http://templerun.click/api/booking/poojas/?special_pooja=true';
  static String hiveBoxName = 'specialPrayers';

  // Add this flag for sync control
  bool skipApiFetch = false;

  Future<List<SpecialPooja>> fetchSpecialPrayers({
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
        print("📦 Returning special prayers from Hive cache");
        return box.values.toList();
      }

      // Fetch from API if Hive is empty or force refresh
      final uri = Uri.parse(_endpoint);

      // Get authorization header with bearer token (auto-refresh if needed)
      final authHeader = await CompleteTokenService.getAuthorizationHeader();
      if (authHeader == null) {
        throw Exception(
          'No valid authentication token found. Please login again.',
        );
      }

      final headers = {
        'Accept': 'application/json',
        'Authorization': authHeader,
      };

      print('🌐 Making special pooja API call to: $uri');
      print('🔐 Authorization header: $authHeader');

      final response = await http.get(uri, headers: headers);

      print('📥 Special Pooja API Response Status: ${response.statusCode}');
      print('📥 Special Pooja API Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load special prayers: ${response.statusCode}',
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

      final prayers = list
          .map((e) => SpecialPooja.fromJson(e as Map<String, dynamic>))
          .toList();

      // Cache the results
      await box.clear();
      await box.addAll(prayers);
      print("💾 Special prayers cached in Hive (${prayers.length} items)");

      return prayers;
    } catch (e) {
      print('fetchSpecialPrayers error: $e');

      // fallback to cache
      try {
        final box = await Hive.openBox<SpecialPooja>(hiveBoxName);
        if (box.isNotEmpty) {
          print("⚠️ Returning cached special prayers due to error");
          return box.values.toList();
        }
      } catch (_) {}

      return [];
    }
  }

  Future<void> saveSpecialPrayersToCache(List<SpecialPooja> prayers) async {
    final box = await Hive.openBox<SpecialPooja>(hiveBoxName);
    await box.clear();
    await box.addAll(prayers);
  }

  Future<void> clearSpecialPrayers() async {
    final box = await Hive.openBox<SpecialPooja>(hiveBoxName);
    await box.clear();
  }

  Future<void> resetSpecialPrayers() async {
    skipApiFetch = true;
    try {
      await clearSpecialPrayers();
      print('🧹 Cleared special prayers cache');
    } finally {
      skipApiFetch = false;
    }
  }
}
