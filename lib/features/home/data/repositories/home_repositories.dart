import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:temple_app/features/home/data/models/god_category_model.dart';
import 'package:temple_app/features/home/data/models/profile_model.dart';
import 'package:temple_app/features/home/data/models/song_model.dart';
import '../../../../core/services/complete_token_service.dart';
import '../../../../core/services/token_storage_service.dart';

class HomeRepository {
  final String baseUrl = "http://templerun.click/api";

  Future<List<GodCategory>> fetchGodCategories() async {
    print('🚀 Starting fetchGodCategories...');

    // Check token availability before retry loop
    print(
      '🔍 Pre-check: Token available? ${TokenStorageService.getIdToken() != null}',
    );
    print(
      '🔍 Pre-check: Token expired? ${TokenStorageService.isTokenExpired()}',
    );

    // Retry mechanism for token availability
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        print('🔄 Attempt $attempt/3 starting...');
        final url = Uri.parse('$baseUrl/booking/poojacategory/');

        // Add a small delay to ensure token is saved after login
        await Future.delayed(Duration(milliseconds: 100 * attempt));

        // Get authorization header with bearer token (auto-refresh if needed)
        print(
          '🔍 Attempting to get authorization header (attempt $attempt/3)...',
        );
        final authHeader = await CompleteTokenService.getAuthorizationHeader();
        print(
          '🔍 Authorization header result: ${authHeader != null ? '${authHeader.substring(0, 30)}...' : 'null'}',
        );
        if (authHeader == null) {
          print('❌ No authorization header available (attempt $attempt/3)');
          if (attempt == 3) {
            throw Exception(
              'No valid authentication token found. Please login again.',
            );
          }
          print('🔄 Retrying in next attempt...');
          continue; // Retry
        }

        final headers = {
          'Accept': 'application/json',
          'Authorization': authHeader,
        };

        print(
          '🌐 Making god categories API call to: $url (attempt $attempt/3)',
        );
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

          print('✅ Successfully loaded ${categories.length} god categories');
          return categories;
        } else {
          print(
            '❌ God categories API failed with status: ${response.statusCode}',
          );
          print('❌ Response body: ${response.body}');
          throw Exception(
            "Failed to load God Categories: ${response.statusCode}",
          );
        }
      } catch (e) {
        print('❌ God categories fetch error (attempt $attempt/3): $e');
        if (attempt == 3) {
          rethrow; // Final attempt failed
        }
        // Continue to next attempt
      }
    }

    // This should never be reached, but just in case
    throw Exception('All attempts to fetch god categories failed');
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
