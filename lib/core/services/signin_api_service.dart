import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'complete_token_service.dart';

/// Service for handling signin API calls
class SigninApiService {
  static const String baseUrl = 'http://templerun.click/api';
  static const String signinEndpoint = '/auth/signin/';

  /// Call signin API after successful OTP verification
  static Future<SigninResponse> signin(String phoneNumber) async {
    final url = Uri.parse('$baseUrl$signinEndpoint');

    final body = {'phone': phoneNumber};

    // Get authorization header with bearer token (auto-refresh if needed)
    final authHeader = await CompleteTokenService.getAuthorizationHeader();
    if (authHeader == null) {
      throw SigninException(
        'No valid authentication token found. Please login again.',
      );
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': authHeader,
    };

    debugPrint('🌐 Making signin API call to: $url');
    debugPrint('📤 Request body: $body');
    debugPrint('🔐 Authorization header: $authHeader');

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      debugPrint('📥 Signin API Response Status: ${response.statusCode}');
      debugPrint('📥 Signin API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return SigninResponse.fromJson(responseData);
      } else {
        throw SigninException(
          'Signin failed with status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('❌ Signin API Error: $e');
      throw SigninException('Failed to signin: $e');
    }
  }
}

/// Response model for signin API
class SigninResponse {
  final String message;
  final String role;
  final String phoneNumber;
  final bool newUser;

  SigninResponse({
    required this.message,
    required this.role,
    required this.phoneNumber,
    required this.newUser,
  });

  factory SigninResponse.fromJson(Map<String, dynamic> json) {
    return SigninResponse(
      message: json['message'] as String,
      role: json['role'] as String,
      phoneNumber: json['phone_number'] as String,
      newUser: json['new_user'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'role': role,
      'phone_number': phoneNumber,
      'new_user': newUser,
    };
  }

  @override
  String toString() {
    return 'SigninResponse(message: $message, role: $role, phoneNumber: $phoneNumber, newUser: $newUser)';
  }
}

/// Exception for signin API errors
class SigninException implements Exception {
  final String message;

  SigninException(this.message);

  @override
  String toString() => 'SigninException: $message';
}
