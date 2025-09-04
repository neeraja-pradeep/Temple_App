import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_list_model.dart';
import 'nakshatram_model.dart';

class UserListRepository {
  static const String baseUrl = 'http://templerun.click/api';

  Future<List<UserList>> getUserLists() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/user-lists'),
        headers: {'Content-Type': 'application/json'},
      );

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
      final response = await http.get(
        Uri.parse('$baseUrl/user/user-lists/$userId/'),
        headers: {'Content-Type': 'application/json'},
      );

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
      final response = await http.post(
        Uri.parse('$baseUrl/user/user-lists/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

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
      final response = await http.patch(
        Uri.parse('$baseUrl/user/user-lists/$userId/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

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
      final response = await http.get(
        Uri.parse('$baseUrl/user/nakshatrams/'),
        headers: {'Content-Type': 'application/json'},
      );

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
