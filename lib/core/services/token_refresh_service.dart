import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'token_storage_service.dart';
import '../config/firebase_config.dart';

class TokenRefreshService {
  // Get Firebase Web API Key from secure configuration
  static String get _firebaseApiKey => FirebaseConfig.getApiKey();

  /// Refresh the ID token using Firebase REST API
  /// This is useful when the token is about to expire or has expired
  static Future<Map<String, dynamic>?> refreshIdToken() async {
    try {
      // Get the current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ No current user found');
        return null;
      }

      // Get a fresh ID token (this will refresh it if needed)
      final idToken = await user.getIdToken(true); // Force refresh
      final idTokenResult = await user.getIdTokenResult(true);

      if (idToken == null) {
        print('❌ Failed to get ID token');
        return null;
      }

      print('🔄 Token refreshed successfully');
      print('📅 New expiration time: ${idTokenResult.expirationTime}');

      // Update stored tokens
      await TokenStorageService.saveAllAuthData(
        idToken: idToken,
        verificationId: TokenStorageService.getVerificationId() ?? '',
        refreshToken: '', // Firebase handles this internally
        userId: user.uid,
        phoneNumber: user.phoneNumber ?? '',
        tokenExpiry:
            idTokenResult.expirationTime ??
            DateTime.now().add(const Duration(hours: 1)),
        userRole: TokenStorageService.getUserRole() ?? '',
      );

      return {
        "idToken": idToken,
        "expiresIn": idTokenResult.expirationTime?.millisecondsSinceEpoch,
        "userId": user.uid,
        "phoneNumber": user.phoneNumber,
      };
    } catch (e) {
      print('❌ Error refreshing token: $e');
      return null;
    }
  }

  /// Check if token is expired or about to expire (within 5 minutes)
  static bool isTokenExpired() {
    final expiry = TokenStorageService.getTokenExpiry();
    if (expiry == null) return true;

    final now = DateTime.now();
    final fiveMinutesFromNow = now.add(const Duration(minutes: 5));

    return expiry.isBefore(fiveMinutesFromNow);
  }

  /// Get a valid token (refresh if needed)
  static Future<String?> getValidToken() async {
    try {
      // Check if token is expired
      if (isTokenExpired()) {
        print('🔄 Token expired or about to expire, refreshing...');
        final refreshResult = await refreshIdToken();
        if (refreshResult != null) {
          return refreshResult['idToken'];
        }
      }

      // Return current token
      return TokenStorageService.getIdToken();
    } catch (e) {
      print('❌ Error getting valid token: $e');
      return null;
    }
  }

  /// Manual refresh using Firebase REST API (your friend's approach)
  /// This requires a refresh token from Firebase Auth REST API
  static Future<Map<String, dynamic>?> refreshIdTokenManually(
    String refreshToken,
  ) async {
    if (_firebaseApiKey == "YOUR_FIREBASE_WEB_API_KEY_HERE" ||
        _firebaseApiKey.isEmpty) {
      print('❌ Please set your Firebase Web API Key in TokenRefreshService');
      return null;
    }

    final url = Uri.parse(
      "https://securetoken.googleapis.com/v1/token?key=$_firebaseApiKey",
    );

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"grant_type": "refresh_token", "refresh_token": refreshToken},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Update stored tokens
        await TokenStorageService.saveAllAuthData(
          idToken: data["id_token"],
          verificationId: TokenStorageService.getVerificationId() ?? '',
          refreshToken: data["refresh_token"],
          userId: data["user_id"],
          phoneNumber: TokenStorageService.getPhoneNumber() ?? '',
          tokenExpiry: DateTime.now().add(
            Duration(seconds: int.parse(data["expires_in"])),
          ),
          userRole: TokenStorageService.getUserRole(),
        );

        return {
          "idToken": data["id_token"],
          "refreshToken": data["refresh_token"],
          "expiresIn": data["expires_in"],
          "userId": data["user_id"],
        };
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
