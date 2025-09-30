import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temple_app/core/providers/token_provider.dart';

class NakshatraService {
  static Future<List<Map<String, dynamic>>> fetchNakshatras(Ref ref) async {
    final token = ref.read(authorizationHeaderProvider) ?? '';
    print('🔑 Authorization Token: $token'); // debug token

    if (token.isEmpty) throw Exception('User not authenticated');

    final uri = Uri.parse('http://templerun.click/api/user/nakshatrams/');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': token,
    };
    print('📝 Request Headers: $headers');

    final response = await http.get(uri, headers: headers);

    print('📦 Response status: ${response.statusCode}');
    print('📄 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data
          .map<Map<String, dynamic>>(
            (item) => {'id': item['id'] as int, 'name': item['name'] as String},
          )
          .toList();
    } else if (response.statusCode == 403) {
      throw Exception('❌ 403 Forbidden: Check user role or token validity');
    } else {
      throw Exception('⚠️ ${response.statusCode} ${response.body}');
    }
  }
}

final userNakshatraListProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  return NakshatraService.fetchNakshatras(ref);
});
