import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:temple_app/features/home/data/models/god_category_model.dart';
import 'package:temple_app/features/home/data/models/profile_model.dart';
import 'package:temple_app/features/home/data/models/song_model.dart';
import '../../../../core/services/complete_token_service.dart';

class HomeRepository {
  final String baseUrl = "http://templerun.click/api";

  Future<List<GodCategory>> fetchGodCategories() async {
    final url = Uri.parse('$baseUrl/booking/poojacategory/');

    // Get authorization header with bearer token (auto-refresh if needed)
    final authHeader = await CompleteTokenService.getAuthorizationHeader();
    if (authHeader == null) {
      throw Exception(
        'No valid authentication token found. Please login again.',
      );
    }

    final headers = {'Accept': 'application/json', 'Authorization': authHeader};

    print('🌐 Making god categories API call to: $url');
    print('🔐 Authorization header: $authHeader');

    final response = await http.get(url, headers: headers);

    print('📥 God Categories API Response Status: ${response.statusCode}');
    print('📥 God Categories API Response Body: ${response.body}');

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

    // Get authorization header with bearer token (auto-refresh if needed)
    final authHeader = await CompleteTokenService.getAuthorizationHeader();
    if (authHeader == null) {
      throw Exception(
        'No valid authentication token found. Please login again.',
      );
    }

    final headers = {'Accept': 'application/json', 'Authorization': authHeader};

    print('🌐 Making profile API call to: $url');
    print('🔐 Authorization header: $authHeader');

    final response = await http.get(url, headers: headers);

    print('📥 Profile API Response Status: ${response.statusCode}');
    print('📥 Profile API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Profile.fromJson(data['profile']);
    } else {
      throw Exception("Failed to load Profile");
    }
  }

  Future<Song> fetchSong() async {
    final url = Uri.parse('$baseUrl/song/songs/14/');

    // Get authorization header with bearer token (auto-refresh if needed)
    final authHeader = await CompleteTokenService.getAuthorizationHeader();
    if (authHeader == null) {
      throw Exception(
        'No valid authentication token found. Please login again.',
      );
    }

    final headers = {'Accept': 'application/json', 'Authorization': authHeader};

    print('🌐 Making song API call to: $url');
    print('🔐 Authorization header: $authHeader');

    final response = await http.get(url, headers: headers);

    print('📥 Song API Response Status: ${response.statusCode}');
    print('📥 Song API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Song.fromJson(data);
    } else {
      throw Exception("Failed to load Song");
    }
  }
}
