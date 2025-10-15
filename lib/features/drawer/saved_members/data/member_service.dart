import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:temple_app/core/providers/token_provider.dart';
import 'package:temple_app/features/drawer/saved_members/data/member_model.dart';
import 'package:temple_app/features/global_api_notifer/data/repository/sync_repository.dart';

class MemberService {
  final String baseUrl = "http://templerun.click/api/user/user-lists/";

  final syncRepo = SyncRepository();

  Future<Box<MemberModel>> _getMemberBox() async {
  if (Hive.isBoxOpen('memberBox')) {
    return Hive.box<MemberModel>('memberBox');
  } else {
    return Hive.openBox<MemberModel>('memberBox');
  }
}

  /// ✅ Fetch all members (use cached data first)
  Future<List<MemberModel>> fetchUserLists(Ref ref) async {

    final box = await _getMemberBox();

    // 🐝 Return cached data immediately if available
    if (box.isNotEmpty) {
      print('📦 Returning cached members (${box.values.length})');
      return box.values.toList();
    }

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
      final members = data.map((json) => MemberModel.fromJson(json)).toList();

      // 🐝 Cache to Hive
      await box.clear();
      for (var member in members) {
        await box.put(member.id, member);
      }

      return members;
    } else {
      throw Exception("Failed to fetch user lists: ${response.statusCode}");
    }
  }

  /// ✅ Add new user (also trigger manual sync)
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
      final newMember = MemberModel.fromJson(data);

      final box = await _getMemberBox();
      await box.put(newMember.id, newMember);

      // 🧩 Trigger sync after add
      await checkMemberUpdateAndSync(syncRepo , ref);

      return newMember;
    } else {
      throw Exception('Failed to add user ⚠️ ${response.statusCode} ${response.body}');
    }
  }

  /// ✅ Edit user (trigger manual sync)
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
      final updatedMember = MemberModel.fromJson(data);

      final box = await _getMemberBox();
      await box.put(id, updatedMember);

      // 🧩 Trigger sync after edit
      await checkMemberUpdateAndSync(syncRepo , ref);

      return updatedMember;
    } else {
      throw Exception('Failed to edit user ⚠️ ${response.statusCode} ${response.body}');
    }
  }

  /// ✅ Delete user (trigger manual sync)
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

    if (response.statusCode == 200 || response.statusCode == 204) {
      final box = await _getMemberBox();
      await box.delete(id);

      // 🧩 Trigger sync after delete
      await checkMemberUpdateAndSync(syncRepo , ref);
    } else {
      throw Exception('Failed to delete user ⚠️ ${response.statusCode} ${response.body}');
    }
  }
}

final memberServiceProvider = Provider<MemberService>((ref) => MemberService());

final memberProvider = FutureProvider.autoDispose<List<MemberModel>>((ref) async {
  final service = ref.read(memberServiceProvider);
  return service.fetchUserLists(ref);
});

final addMemberProvider = FutureProvider.family<MemberModel, Map<String, dynamic>>((ref, payload) async {
  final service = ref.read(memberServiceProvider);
  return service.addUser(ref, payload);
});

final editMemberProvider = FutureProvider.family<MemberModel, Map<String, dynamic>>((ref, payload) async {
  final service = ref.read(memberServiceProvider);
  final id = payload['id'] as int;
  return service.editUser(ref, id, payload);
});

final deleteMemberProvider = FutureProvider.family<void, int>((ref, id) async {
  final service = ref.read(memberServiceProvider);
  return service.deleteUser(ref, id);
});
