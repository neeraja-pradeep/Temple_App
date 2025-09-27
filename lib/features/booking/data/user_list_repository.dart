import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_list_model.dart';
import 'nakshatram_model.dart';
import '../../../core/services/complete_token_service.dart';

class UserListRepository {
  static const String baseUrl = 'http://templerun.click/api';

  Future<List<UserList>> getUserLists() async {
    try {
      // Get authorization header with bearer token (auto-refresh if needed)
      final authHeader = await CompleteTokenService.getAuthorizationHeader();
      if (authHeader == null) {
        throw Exception(
          'No valid authentication token found. Please login again.',
        );
      }

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': authHeader,
      };

      print('🌐 Making get user lists API call to: $baseUrl/user/user-lists');
      print('🔐 Authorization header: $authHeader');

      final response = await http.get(
        Uri.parse('$baseUrl/user/user-lists'),
        headers: headers,
      );

      print('📥 Get User Lists API Response Status: ${response.statusCode}');
      print('📥 Get User Lists API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => UserList.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load user lists: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load user lists: $e');
    }
  }

  Future<UserList> getCurrentUser(int userId) async {
    try {
      // Get authorization header with bearer token (auto-refresh if needed)
      final authHeader = await CompleteTokenService.getAuthorizationHeader();
      if (authHeader == null) {
        throw Exception(
          'No valid authentication token found. Please login again.',
        );
      }

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': authHeader,
      };

      print(
        '🌐 Making get current user API call to: $baseUrl/user/user-lists/$userId/',
      );
      print('🔐 Authorization header: $authHeader');

      final response = await http.get(
        Uri.parse('$baseUrl/user/user-lists/$userId/'),
        headers: headers,
      );

      print('📥 Get Current User API Response Status: ${response.statusCode}');
      print('📥 Get Current User API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return UserList.fromJson(jsonData);
      } else {
        throw Exception('Failed to load current user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load current user: $e');
    }
  }

  Future<UserList> addNewUser(Map<String, dynamic> userData) async {
    try {
      // Get authorization header with bearer token (auto-refresh if needed)
      final authHeader = await CompleteTokenService.getAuthorizationHeader();
      if (authHeader == null) {
        throw Exception(
          'No valid authentication token found. Please login again.',
        );
      }

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': authHeader,
      };

      print('🌐 Making add new user API call to: $baseUrl/user/user-lists/');
      print('🔐 Authorization header: $authHeader');
      print('📤 Request body: ${json.encode(userData)}');

      final response = await http.post(
        Uri.parse('$baseUrl/user/user-lists/'),
        headers: headers,
        body: json.encode(userData),
      );

      print('📥 Add New User API Response Status: ${response.statusCode}');
      print('📥 Add New User API Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return UserList.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to add new user: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to add new user: $e');
    }
  }

  Future<UserList> updateUser(int userId, Map<String, dynamic> userData) async {
    try {
      // Get authorization header with bearer token (auto-refresh if needed)
      final authHeader = await CompleteTokenService.getAuthorizationHeader();
      if (authHeader == null) {
        throw Exception(
          'No valid authentication token found. Please login again.',
        );
      }

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': authHeader,
      };

      print(
        '🌐 Making update user API call to: $baseUrl/user/user-lists/$userId/',
      );
      print('🔐 Authorization header: $authHeader');
      print('📤 Request body: ${json.encode(userData)}');

      final response = await http.patch(
        Uri.parse('$baseUrl/user/user-lists/$userId/'),
        headers: headers,
        body: json.encode(userData),
      );

      print('📥 Update User API Response Status: ${response.statusCode}');
      print('📥 Update User API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return UserList.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to update user: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<List<NakshatramOption>> getNakshatrams() async {
    try {
      // Get authorization header with bearer token (auto-refresh if needed)
      final authHeader = await CompleteTokenService.getAuthorizationHeader();
      if (authHeader == null) {
        throw Exception(
          'No valid authentication token found. Please login again.',
        );
      }

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': authHeader,
      };

      print(
        '🌐 Making get nakshatrams API call to: $baseUrl/user/nakshatrams/',
      );
      print('🔐 Authorization header: $authHeader');

      final response = await http.get(
        Uri.parse('$baseUrl/user/nakshatrams/'),
        headers: headers,
      );

      print('📥 Get Nakshatrams API Response Status: ${response.statusCode}');
      print('📥 Get Nakshatrams API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((e) => NakshatramOption.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load nakshatrams: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load nakshatrams: $e');
    }
  }
}
