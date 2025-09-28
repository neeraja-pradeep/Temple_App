import 'dart:convert';
import 'package:http/http.dart' as http;

import 'song_model.dart';
import '../../../core/services/complete_token_service.dart';

class MusicRepository {
  final String baseUrl = "http://templerun.click/api";

  Future<List<SongItem>> fetchSongs() async {
    try {
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

      return list
          .map((e) => SongItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('=== SONGS FETCH ERROR ===');
      print('Error: $e');
      print('=== END ERROR ===');
      rethrow;
    }
  }
}
