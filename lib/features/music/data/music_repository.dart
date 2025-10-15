import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

import 'song_model.dart';
import '../../../core/services/complete_token_service.dart';

class MusicRepository {
  final String baseUrl = "http://templerun.click/api";
  static const String hiveBoxName = 'songs';
  static const String hiveKeyItems = 'items';

  Future<List<SongItem>> fetchSongs({bool forceRefresh = false}) async {
    try {
      // 1) Try cache unless forceRefresh
      final box = await Hive.openBox(hiveBoxName);
      if (!forceRefresh && box.containsKey(hiveKeyItems)) {
        final cached = box.get(hiveKeyItems);
        if (cached is List) {
          final items = cached
              .whereType<Map>()
              .map((e) => SongItem.fromJson(e.cast<String, dynamic>()))
              .toList();
          if (items.isNotEmpty) {
            print('📦 Returning songs from Hive cache (${items.length} items)');
            return items;
          }
        }
      }

      // 2) Fetch from API
      final url = Uri.parse('$baseUrl/song/songs/');

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

      print('=== FETCHING SONGS ===');
      print('URL: $url');
      print('🔐 Authorization header: $authHeader');

      final response = await http.get(url, headers: headers);
      print('Response status: ${response.statusCode}');
      print('📥 Songs API Response Body: ${response.body}');

      if (response.statusCode != 200) {
        print('Failed to load songs: ${response.statusCode}');
        throw Exception('Failed to load songs: ${response.statusCode}');
      }

      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> list =
          (body['songs'] as List<dynamic>? ?? <dynamic>[]);

      print('Found ${list.length} songs');
      print('=== END FETCH ===');

      final songs = list
          .map((e) => SongItem.fromJson(e as Map<String, dynamic>))
          .toList();

      // 3) Cache in Hive
      await box.put(hiveKeyItems, songs.map((e) => e.toJson()).toList());
      print('💾 Songs cached in Hive (${songs.length} items)');

      return songs;
    } catch (e) {
      print('=== SONGS FETCH ERROR ===');
      print('Error: $e');
      print('=== END ERROR ===');
      rethrow;
    }
  }

  Future<void> clearSongsCache() async {
    try {
      final box = await Hive.openBox(hiveBoxName);
      await box.delete(hiveKeyItems);
      print('🧹 Cleared songs cache');
    } catch (_) {}
  }
}
