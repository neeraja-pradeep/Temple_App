import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:temple_app/core/providers/token_provider.dart';
import 'package:temple_app/features/drawer/saved_members/data/member_model.dart';

class MemberService {
  final String baseUrl = "http://templerun.click/api/user/user-lists/";

  // all users
  Future<List<MemberModel>> fetchUserLists(Ref ref) async {
    final token = ref.read(authorizationHeaderProvider) ?? '';
    if (token.isEmpty) throw Exception('User not authenticated');

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': token,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => MemberModel.fromJson(json)).toList();
    } else {
      throw Exception("Failed to fetch user lists: ${response.statusCode}");
    }
  }

  /// add new user
  Future<MemberModel> addUser(Ref ref, Map<String, dynamic> payload) async {
    final token = ref.read(authorizationHeaderProvider) ?? '';
    if (token.isEmpty) throw Exception('User not authenticated');

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': token,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return MemberModel.fromJson(data);
    } else {
      throw Exception('Failed to add user ⚠️ ${response.statusCode} ${response.body}');
    }
  }

  /// edit existing user
  Future<MemberModel> editUser(Ref ref, int id, Map<String, dynamic> payload) async {
    final token = ref.read(authorizationHeaderProvider) ?? '';
    if (token.isEmpty) throw Exception('User not authenticated');

    final uri = Uri.parse('$baseUrl$id/');
    final response = await http.patch(
      uri,
      headers: {
        'Authorization': token,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return MemberModel.fromJson(data);
    } else {
      throw Exception('Failed to edit user ⚠️ ${response.statusCode} ${response.body}');
    }
  }

  // delete existing user
  Future<void> deleteUser(Ref ref, int id) async {
    final token = ref.read(authorizationHeaderProvider) ?? '';
    if (token.isEmpty) throw Exception('User not authenticated');

    final uri = Uri.parse('$baseUrl$id/');
    final response = await http.delete(
      uri,
      headers: {
        'Authorization': token,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete user ⚠️ ${response.statusCode} ${response.body}');
    }
  }
}

// Service provider
final memberServiceProvider = Provider<MemberService>((ref) => MemberService());

// Fetch all users
final memberProvider = FutureProvider.autoDispose<List<MemberModel>>((ref) async {
  final service = ref.read(memberServiceProvider);
  return service.fetchUserLists(ref);
});

// Add user provider
final addMemberProvider = FutureProvider.family<MemberModel, Map<String, dynamic>>((ref, payload) async {
  final service = ref.read(memberServiceProvider);
  return service.addUser(ref, payload);
});

///Edit user provider
final editMemberProvider = FutureProvider.family<MemberModel, Map<String, dynamic>>((ref, payload) async {
  final service = ref.read(memberServiceProvider);
  final id = payload['id'] as int;
  return service.editUser(ref, id, payload);
});

// Delete user provider
final deleteMemberProvider = FutureProvider.family<void, int>((ref, id) async {
  final service = ref.read(memberServiceProvider);
  return service.deleteUser(ref, id);
});