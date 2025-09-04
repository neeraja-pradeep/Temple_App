import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:temple/features/home/data/models/god_category_model.dart';
import 'package:temple/features/home/data/models/profile_model.dart';
import 'package:temple/features/home/data/models/song_model.dart';


class HomeRepository {
  final String baseUrl = "http://templerun.click/api";

  Future<List<GodCategory>> fetchGodCategories() async {
  final url = Uri.parse('$baseUrl/booking/poojacategory/');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(response.body);

    final List<dynamic> results = data["results"] ?? [];


    final categories = results
        .map((e) => GodCategory.fromJson(e))
        .where((cat) => cat.isActive == true)
        .toList();

    return categories;
  } else {
    throw Exception("Failed to load God Categories");
  }
}

  Future<Profile> fetchProfile() async {
    final url = Uri.parse('$baseUrl/user/profile/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Profile.fromJson(data['profile']);
    } else {
      throw Exception("Failed to load Profile");
    }
  }

  Future<Song> fetchSong() async {
    final url = Uri.parse('$baseUrl/song/songs/14/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Song.fromJson(data);
    } else {
      throw Exception("Failed to load Song");
    }
  }
}
