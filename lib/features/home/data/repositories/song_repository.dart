import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/song_model.dart';

class SongRepository {
  final String baseUrl = 'http://templerun.click/api';

  Future<SongResponse> fetchSong(int songId) async {
    final url = Uri.parse('$baseUrl/song/songs/$songId/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return SongResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load song');
    }
  }
}
