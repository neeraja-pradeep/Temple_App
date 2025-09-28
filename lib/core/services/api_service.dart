import 'package:http/http.dart' as http;
import 'dart:convert';
import 'token_storage_service.dart';

/// API Service for making authenticated requests
class ApiService {
  static const String baseUrl =
      'http://templerun.click/api'; // Update with your actual API base URL

  /// Make authenticated GET request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getAuthHeaders();

    print('🌐 Making GET request to: $url');
    print('🔐 Headers: $headers');

    try {
      final response = await http.get(url, headers: headers);
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ API Error: $e');
      rethrow;
    }
  }

  /// Make authenticated POST request
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getAuthHeaders();
    headers['Content-Type'] = 'application/json';

    print('🌐 Making POST request to: $url');
    print('🔐 Headers: $headers');
    print('📤 Data: $data');

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to post data: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ API Error: $e');
      rethrow;
    }
  }

  /// Make authenticated PUT request
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getAuthHeaders();
    headers['Content-Type'] = 'application/json';

    print('🌐 Making PUT request to: $url');
    print('🔐 Headers: $headers');
    print('📤 Data: $data');

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(data),
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update data: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ API Error: $e');
      rethrow;
    }
  }

  /// Make authenticated DELETE request
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getAuthHeaders();

    print('🌐 Making DELETE request to: $url');
    print('🔐 Headers: $headers');

    try {
      final response = await http.delete(url, headers: headers);

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to delete data: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ API Error: $e');
      rethrow;
    }
  }

  /// Get authentication headers with bearer token
  static Future<Map<String, String>> _getAuthHeaders() async {
    final headers = <String, String>{};

    // Get authorization header from token storage
    final authHeader = TokenStorageService.getAuthorizationHeader();
    if (authHeader != null) {
      headers['Authorization'] = authHeader;
      print('🔐 Using stored bearer token for authentication');
    } else {
      print('⚠️ No valid authentication token found');
      throw Exception(
        'No valid authentication token found. Please login again.',
      );
    }

    // Add other common headers
    headers['Accept'] = 'application/json';
    headers['User-Agent'] = 'TempleApp/1.0.0';

    return headers;
  }

  /// Check if user is authenticated before making API calls
  static bool isAuthenticated() {
    return TokenStorageService.isAuthenticated();
  }

  /// Get current user info for API calls
  static Map<String, String?> getUserInfo() {
    return {
      'userId': TokenStorageService.getUserId(),
      'phoneNumber': TokenStorageService.getPhoneNumber(),
      'verificationId': TokenStorageService.getVerificationId(),
    };
  }

  /// Send FCM token to backend
  static Future<Map<String, dynamic>> sendFcmToken(String fcmToken) async {
    const endpoint = '/auth/fcm-token/';
    final data = {'fcm_token': fcmToken};

    print('=== SENDING FCM TOKEN ===');
    print('📤 FCM Token: $fcmToken');
    print('📤 Request Body: $data');
    print('=== END FCM TOKEN REQUEST ===');

    try {
      final response = await post(endpoint, data);

      print('=== FCM TOKEN RESPONSE ===');
      print('📥 Response: $response');
      print('=== END FCM TOKEN RESPONSE ===');

      return response;
    } catch (e) {
      print('=== FCM TOKEN ERROR ===');
      print('❌ Error: $e');
      print('=== END FCM TOKEN ERROR ===');
      rethrow;
    }
  }

  /// Logout user from backend
  static Future<Map<String, dynamic>> logout() async {
    const endpoint = '/auth/logout/';

    print('=== LOGOUT REQUEST ===');
    print('🌐 Making POST request to: $baseUrl$endpoint');
    print('=== END LOGOUT REQUEST ===');

    try {
      final response = await post(endpoint, {});

      print('=== LOGOUT RESPONSE ===');
      print('📥 Response Status: ${response['status'] ?? 'Success'}');
      print('📥 Response: $response');
      print('=== END LOGOUT RESPONSE ===');

      return response;
    } catch (e) {
      print('=== LOGOUT ERROR ===');
      print('❌ Error: $e');
      print('=== END LOGOUT ERROR ===');
      rethrow;
    }
  }
}
