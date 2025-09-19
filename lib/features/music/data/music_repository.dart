import 'dart:convert';
import 'package:http/http.dart' as http;

import 'song_model.dart';

class MusicRepository {
  final String baseUrl = "http://templerun.click/api";

  Future<List<SongItem>> fetchSongs() async {
    final url = Uri.parse('$baseUrl/song/songs/');
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to load songs');
    }
    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> list = (body['songs'] as List<dynamic>? ?? <dynamic>[]);

    return list
        .map((e) => SongItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
