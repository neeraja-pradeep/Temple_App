import 'dart:convert';
import 'package:http/http.dart' as http;

import 'song_model.dart';

class MusicRepository {
  final String baseUrl = "http://templerun.click/api";

  Future<List<SongItem>> fetchSongs() async {
    try {
      final url = Uri.parse('$baseUrl/song/songs/');
      print('=== FETCHING SONGS ===');
      print('URL: $url');

      final response = await http.get(url);
      print('Response status: ${response.statusCode}');

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
