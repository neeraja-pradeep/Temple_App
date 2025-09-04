import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/profile_model.dart';

class ProfileRepository {
  final String baseUrl = 'http://templerun.click/api';

  Future<ProfileResponse> fetchProfile() async {
    final url = Uri.parse('$baseUrl/user/profile/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return ProfileResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load profile');
    }
  }
}
