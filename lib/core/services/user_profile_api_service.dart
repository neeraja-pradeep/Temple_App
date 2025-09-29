import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'complete_token_service.dart';

/// Service for handling user profile API calls
class UserProfileApiService {
  static const String baseUrl = 'http://templerun.click/api';
  static const String profileEndpoint = '/user/profile/me/';

  /// Update user profile with basic details
  static Future<ProfileUpdateResponse> updateProfile({
    String? name,
    String? email,
    String? dob,
    String? time,
    int? nakshatram,
  }) async {
    final url = Uri.parse('$baseUrl$profileEndpoint');

    // Build request body with only provided fields
    final Map<String, dynamic> body = {};
    if (name != null && name.isNotEmpty) body['name'] = name;
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (dob != null && dob.isNotEmpty) body['DOB'] = dob;
    if (time != null && time.isNotEmpty) body['time'] = time;
    if (nakshatram != null) body['nakshatram'] = nakshatram;

    // Get authorization header with bearer token (auto-refresh if needed)
    final authHeader = await CompleteTokenService.getAuthorizationHeader();
    if (authHeader == null) {
      throw ProfileUpdateException(
        'No valid authentication token found. Please login again.',
      );
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': authHeader,
    };

    debugPrint('🌐 Making profile update API call to: $url');
    debugPrint('📤 Request body: ${jsonEncode(body)}');
    debugPrint('🔐 Authorization header: $authHeader');

    try {
      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      debugPrint(
        '📥 Profile Update API Response Status: ${response.statusCode}',
      );
      debugPrint('📥 Profile Update API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return ProfileUpdateResponse.fromJson(responseData);
      } else {
        throw ProfileUpdateException(
          'Profile update failed with status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('❌ Profile Update API Error: $e');
      if (e is ProfileUpdateException) {
        rethrow;
      }
      throw ProfileUpdateException('Failed to update profile: $e');
    }
  }
}

/// Response model for profile update API
class ProfileUpdateResponse {
  final String message;
  final bool success;
  final Map<String, dynamic>? data;

  ProfileUpdateResponse({
    required this.message,
    required this.success,
    this.data,
  });

  factory ProfileUpdateResponse.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateResponse(
      message: json['message'] as String? ?? 'Profile updated successfully',
      success: json['success'] as bool? ?? true,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'success': success,
      if (data != null) 'data': data,
    };
  }

  @override
  String toString() {
    return 'ProfileUpdateResponse(message: $message, success: $success, data: $data)';
  }
}

/// Exception for profile update API errors
class ProfileUpdateException implements Exception {
  final String message;

  ProfileUpdateException(this.message);

  @override
  String toString() => 'ProfileUpdateException: $message';
}
