import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

/// Secure token storage service using Hive
class TokenStorageService {
  static const String _boxName = 'auth_tokens';
  static const String _idTokenKey = 'id_token';
  static const String _verificationIdKey = 'verification_id';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _phoneNumberKey = 'phone_number';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _userRoleKey = 'user_role';
  static const String _fcmTokenKey = 'fcm_token';

  static Box<String>? _box;

  /// Initialize the token storage box
  static Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  /// Save ID Token (Bearer Token)
  static Future<void> saveIdToken(String idToken) async {
    await _ensureBoxOpen();
    await _box!.put(_idTokenKey, idToken);
  }

  /// Save Verification ID (Session ID)
  static Future<void> saveVerificationId(String verificationId) async {
    await _ensureBoxOpen();
    await _box!.put(_verificationIdKey, verificationId);
  }

  /// Save Refresh Token
  static Future<void> saveRefreshToken(String refreshToken) async {
    await _ensureBoxOpen();
    await _box!.put(_refreshTokenKey, refreshToken);
  }

  /// Save User ID
  static Future<void> saveUserId(String userId) async {
    await _ensureBoxOpen();
    await _box!.put(_userIdKey, userId);
  }

  /// Save Phone Number
  static Future<void> savePhoneNumber(String phoneNumber) async {
    await _ensureBoxOpen();
    await _box!.put(_phoneNumberKey, phoneNumber);
  }

  /// Save Token Expiry Time
  static Future<void> saveTokenExpiry(DateTime expiryTime) async {
    await _ensureBoxOpen();
    await _box!.put(_tokenExpiryKey, expiryTime.toIso8601String());
  }

  /// Save User Role
  static Future<void> saveUserRole(String userRole) async {
    await _ensureBoxOpen();
    await _box!.put(_userRoleKey, userRole);
  }

  /// Save FCM Token
  static Future<void> saveFcmToken(String fcmToken) async {
    await _ensureBoxOpen();
    await _box!.put(_fcmTokenKey, fcmToken);
  }

  /// Save all authentication data at once
  static Future<void> saveAllAuthData({
    required String idToken,
    required String verificationId,
    required String refreshToken,
    required String userId,
    required String phoneNumber,
    required DateTime tokenExpiry,
    String? userRole,
  }) async {
    await _ensureBoxOpen();

    final data = {
      _idTokenKey: idToken,
      _verificationIdKey: verificationId,
      _refreshTokenKey: refreshToken,
      _userIdKey: userId,
      _phoneNumberKey: phoneNumber,
      _tokenExpiryKey: tokenExpiry.toIso8601String(),
    };

    if (userRole != null) {
      data[_userRoleKey] = userRole;
    }

    await _box!.putAll(data);
  }

  /// Get ID Token (Bearer Token)
  static String? getIdToken() {
    final token = _box?.get(_idTokenKey);
    return token;
  }

  /// Get Verification ID (Session ID)
  static String? getVerificationId() {
    final verificationId = _box?.get(_verificationIdKey);
    return verificationId;
  }

  /// Get Refresh Token
  static String? getRefreshToken() {
    final refreshToken = _box?.get(_refreshTokenKey);
    return refreshToken;
  }

  /// Get User ID
  static String? getUserId() {
    final userId = _box?.get(_userIdKey);
    return userId;
  }

  /// Get Phone Number
  static String? getPhoneNumber() {
    final phoneNumber = _box?.get(_phoneNumberKey);
    return phoneNumber;
  }

  /// Get User Role
  static String? getUserRole() {
    final userRole = _box?.get(_userRoleKey);
    return userRole;
  }

  /// Get FCM Token
  static String? getFcmToken() {
    final token = _box?.get(_fcmTokenKey);
    return token;
  }

  /// Get Token Expiry Time
  static DateTime? getTokenExpiry() {
    final expiryString = _box?.get(_tokenExpiryKey);
    if (expiryString != null) {
      try {
        final expiry = DateTime.parse(expiryString);
        return expiry;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Check if token is expired
  static bool isTokenExpired() {
    final expiry = getTokenExpiry();
    if (expiry == null) return true;

    final isExpired = DateTime.now().isAfter(expiry);
    debugPrint('🔍 Token expired: $isExpired (expires at: $expiry)');
    return isExpired;
  }

  /// Check if user is authenticated (has valid token)
  static bool isAuthenticated() {
    final hasToken = getIdToken() != null;
    final notExpired = !isTokenExpired();
    final isAuth = hasToken && notExpired;

    return isAuth;
  }

  /// Get Authorization Header for API calls
  static String? getAuthorizationHeader() {
    final token = getIdToken();
     final expired = isTokenExpired();
    print('Token: $token, expired: $expired');
    if (token != null && !isTokenExpired()) {
      final header = 'Bearer $token';
       print('-----------------------Authorization header: $header');
      return header;
    }
    return null;
  }

  /// Clear all stored tokens (logout)
  static Future<void> clearAllTokens() async {
    await _ensureBoxOpen();
    await _box!.clear();
  }

  /// Ensure box is open
  static Future<void> _ensureBoxOpen() async {
    if (_box == null || !_box!.isOpen) {
      await init();
    }
  }
}
