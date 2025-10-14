import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:temple_app/features/home/data/models/god_category_model.dart';
import 'package:temple_app/features/home/data/models/profile_model.dart';
import 'package:temple_app/features/home/data/models/song_model.dart';
import '../../../../core/services/complete_token_service.dart';

class HomeRepository {
  final String baseUrl = "http://templerun.click/api";

  /// Fetch God Categories - Cache first
  Future<List<GodCategory>> fetchGodCategories() async {
    final godBox = await Hive.openBox<GodCategory>('godCategoriesBox');

    // 1️⃣ Return cache if available
    if (godBox.isNotEmpty) {
      print('📦 Returning cached God Categories (${godBox.length} items)');
      return godBox.values.toList();
    }

    // 2️⃣ API call if cache is empty
    final url = Uri.parse('$baseUrl/booking/poojacategory/');
    final authHeader = await CompleteTokenService.getAuthorizationHeader();
    if (authHeader == null) {
      throw Exception('No valid authentication token found. Please login again.');
    }
    final headers = {'Accept': 'application/json', 'Authorization': authHeader};

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> results = jsonDecode(response.body)['results'] ?? [];
        final categories = results
            .map((e) => GodCategory.fromJson(e))
            .where((cat) => cat.isActive)
            .toList();

        // Cache in Hive
        await godBox.clear();
        for (var category in categories) {
          await godBox.put(category.id, category);
        }
        print('💾 Cached ${categories.length} God Categories to Hive');

        return categories;
      } else {
        throw Exception("Failed to load God Categories: ${response.statusCode}");
      }
    } catch (e) {
      // fallback to cache if API fails
      if (godBox.isNotEmpty) {
        print('⚠️ Using cached God Categories from Hive after failure');
        return godBox.values.toList();
      }
      rethrow;
    }
  }

  /// Fetch Profile - Cache first
  Future<Profile> fetchProfile() async {
    final profileBox = await Hive.openBox<Profile>('profileBox');

    if (profileBox.isNotEmpty) {
      print('📦 Returning cached profile');
      return profileBox.get('profile')!;
    }

    final url = Uri.parse('$baseUrl/user/profile/');
    final authHeader = await CompleteTokenService.getAuthorizationHeader();
    if (authHeader == null) throw Exception('No valid authentication token found.');

    final headers = {'Accept': 'application/json', 'Authorization': authHeader};

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final profile = Profile.fromJson(jsonDecode(response.body)['profile']);
        await profileBox.put('profile', profile);
        print('💾 Cached Profile to Hive');
        return profile;
      } else {
        throw Exception("Failed to load Profile");
      }
    } catch (e) {
      if (profileBox.isNotEmpty) {
        print('⚠️ Using cached Profile after API failure');
        return profileBox.get('profile')!;
      }
      rethrow;
    }
  }

  /// Fetch Song - Cache first
  Future<Song> fetchSong() async {
    final songBox = await Hive.openBox<Song>('songBox');

    if (songBox.isNotEmpty) {
      print('📦 Returning cached Song');
      return songBox.get('song')!;
    }

    final url = Uri.parse('$baseUrl/song/songs/14/');
    final authHeader = await CompleteTokenService.getAuthorizationHeader();
    if (authHeader == null) throw Exception('No valid authentication token found.');

    final headers = {'Accept': 'application/json', 'Authorization': authHeader};

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final song = Song.fromJson(jsonDecode(response.body));
        await songBox.put('song', song);
        print('💾 Cached Song to Hive');
        return song;
      } else {
        throw Exception("Failed to load Song");
      }
    } catch (e) {
      if (songBox.isNotEmpty) {
        print('⚠️ Using cached Song after API failure');
        return songBox.get('song')!;
      }
      rethrow;
    }
  }
}
