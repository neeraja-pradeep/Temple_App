import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../config/firebase_config.dart';

class FirebaseRestAuthService {
  // Get Firebase Web API Key from secure configuration
  static String get _firebaseApiKey => FirebaseConfig.getApiKey();

  /// Get a refresh token using Firebase Auth REST API
  /// For phone authentication, we need to use the token exchange endpoint
  static Future<Map<String, dynamic>?> getRefreshToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ No current user found');
        return null;
      }

      // Get the current ID token
      final idToken = await user.getIdToken();
      if (idToken == null) {
        print('❌ Failed to get ID token');
        return null;
      }

      // Use Firebase Auth REST API to exchange ID token for refresh token
      // This endpoint is specifically for getting refresh tokens
      final url = Uri.parse(
        "https://securetoken.googleapis.com/v1/token?key=$_firebaseApiKey",
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
          "assertion": idToken,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final refreshToken = data["refresh_token"];

        if (refreshToken != null) {
          print('✅ Successfully obtained refresh token');
          return {
            "refreshToken": refreshToken,
            "idToken": data["id_token"],
            "expiresIn": data["expires_in"],
            "userId": data["user_id"],
          };
        }
      } else {
        print(
          '❌ Failed to get refresh token: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error getting refresh token: $e');
    }

    return null;
  }

  /// Alternative method: Use Firebase Auth REST API with phone number
  /// This might work better for phone authentication
  static Future<Map<String, dynamic>?> getRefreshTokenWithPhone() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ No current user found');
        return null;
      }

      final phoneNumber = user.phoneNumber;
      if (phoneNumber == null) {
        print('❌ No phone number found');
        return null;
      }

      // Note: This is a simplified example. The actual implementation would require
      // the verification code and other parameters
    } catch (e) {
      print('❌ Error getting refresh token with phone: $e');
    }

    return null;
  }
}
