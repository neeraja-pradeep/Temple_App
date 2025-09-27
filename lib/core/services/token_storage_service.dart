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

  static Box<String>? _box;

  /// Initialize the token storage box
  static Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
    debugPrint('🔐 Token storage initialized');
  }

  /// Save ID Token (Bearer Token)
  static Future<void> saveIdToken(String idToken) async {
    await _ensureBoxOpen();
    await _box!.put(_idTokenKey, idToken);
    debugPrint('💾 ID Token saved');
  }

  /// Save Verification ID (Session ID)
  static Future<void> saveVerificationId(String verificationId) async {
    await _ensureBoxOpen();
    await _box!.put(_verificationIdKey, verificationId);
    debugPrint('💾 Verification ID saved');
  }

  /// Save Refresh Token
  static Future<void> saveRefreshToken(String refreshToken) async {
    await _ensureBoxOpen();
    await _box!.put(_refreshTokenKey, refreshToken);
    debugPrint('💾 Refresh Token saved');
  }

  /// Save User ID
  static Future<void> saveUserId(String userId) async {
    await _ensureBoxOpen();
    await _box!.put(_userIdKey, userId);
    debugPrint('💾 User ID saved');
  }

  /// Save Phone Number
  static Future<void> savePhoneNumber(String phoneNumber) async {
    await _ensureBoxOpen();
    await _box!.put(_phoneNumberKey, phoneNumber);
    debugPrint('💾 Phone Number saved');
  }

  /// Save Token Expiry Time
  static Future<void> saveTokenExpiry(DateTime expiryTime) async {
    await _ensureBoxOpen();
    await _box!.put(_tokenExpiryKey, expiryTime.toIso8601String());
    debugPrint('💾 Token Expiry saved: $expiryTime');
  }

  /// Save User Role
  static Future<void> saveUserRole(String userRole) async {
    await _ensureBoxOpen();
    await _box!.put(_userRoleKey, userRole);
    debugPrint('💾 User Role saved: $userRole');
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

    debugPrint('💾 All authentication data saved');
    _logStoredTokens();
  }

  /// Get ID Token (Bearer Token)
  static String? getIdToken() {
    final token = _box?.get(_idTokenKey);
    debugPrint(
      '🔍 Retrieved ID Token: ${token != null ? 'Present' : 'Not found'}',
    );
    return token;
  }

  /// Get Verification ID (Session ID)
  static String? getVerificationId() {
    final verificationId = _box?.get(_verificationIdKey);
    debugPrint(
      '🔍 Retrieved Verification ID: ${verificationId != null ? 'Present' : 'Not found'}',
    );
    return verificationId;
  }

  /// Get Refresh Token
  static String? getRefreshToken() {
    final refreshToken = _box?.get(_refreshTokenKey);
    debugPrint(
      '🔍 Retrieved Refresh Token: ${refreshToken != null ? 'Present' : 'Not found'}',
    );
    return refreshToken;
  }

  /// Get User ID
  static String? getUserId() {
    final userId = _box?.get(_userIdKey);
    debugPrint(
      '🔍 Retrieved User ID: ${userId != null ? 'Present' : 'Not found'}',
    );
    return userId;
  }

  /// Get Phone Number
  static String? getPhoneNumber() {
    final phoneNumber = _box?.get(_phoneNumberKey);
    debugPrint(
      '🔍 Retrieved Phone Number: ${phoneNumber != null ? 'Present' : 'Not found'}',
    );
    return phoneNumber;
  }

  /// Get User Role
  static String? getUserRole() {
    final userRole = _box?.get(_userRoleKey);
    debugPrint(
      '🔍 Retrieved User Role: ${userRole != null ? 'Present' : 'Not found'}',
    );
    return userRole;
  }

  /// Get Token Expiry Time
  static DateTime? getTokenExpiry() {
    final expiryString = _box?.get(_tokenExpiryKey);
    if (expiryString != null) {
      try {
        final expiry = DateTime.parse(expiryString);
        debugPrint('🔍 Retrieved Token Expiry: $expiry');
        return expiry;
      } catch (e) {
        debugPrint('❌ Error parsing token expiry: $e');
        return null;
      }
    }
    debugPrint('🔍 Retrieved Token Expiry: Not found');
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

    debugPrint(
      '🔍 User authenticated: $isAuth (hasToken: $hasToken, notExpired: $notExpired)',
    );
    return isAuth;
  }

  /// Get Authorization Header for API calls
  static String? getAuthorizationHeader() {
    final token = getIdToken();
    if (token != null && !isTokenExpired()) {
      final header = 'Bearer $token';
      debugPrint('🔍 Authorization Header: Bearer [TOKEN_PRESENT]');
      return header;
    }
    debugPrint(
      '🔍 Authorization Header: Not available (token missing or expired)',
    );
    return null;
  }

  /// Clear all stored tokens (logout)
  static Future<void> clearAllTokens() async {
    await _ensureBoxOpen();
    await _box!.clear();
    debugPrint('🗑️ All authentication tokens cleared');
  }

  /// Log all stored tokens (for debugging)
  static void _logStoredTokens() {
    debugPrint('=== STORED AUTHENTICATION TOKENS ===');
    debugPrint('ID Token: ${getIdToken() != null ? 'Present' : 'Not found'}');
    debugPrint(
      'Verification ID: ${getVerificationId() != null ? 'Present' : 'Not found'}',
    );
    debugPrint(
      'Refresh Token: ${getRefreshToken() != null ? 'Present' : 'Not found'}',
    );
    debugPrint('User ID: ${getUserId() ?? 'Not found'}');
    debugPrint('Phone Number: ${getPhoneNumber() ?? 'Not found'}');
    debugPrint('User Role: ${getUserRole() ?? 'Not found'}');
    debugPrint('Token Expiry: ${getTokenExpiry() ?? 'Not found'}');
    debugPrint('Is Authenticated: ${isAuthenticated()}');
    debugPrint('=== END STORED TOKENS ===');
  }

  /// Ensure box is open
  static Future<void> _ensureBoxOpen() async {
    if (_box == null || !_box!.isOpen) {
      await init();
    }
  }

  /// Get all stored data for debugging
  static Map<String, String?> getAllStoredData() {
    return {
      'idToken': getIdToken(),
      'verificationId': getVerificationId(),
      'refreshToken': getRefreshToken(),
      'userId': getUserId(),
      'phoneNumber': getPhoneNumber(),
      'userRole': getUserRole(),
      'tokenExpiry': getTokenExpiry()?.toIso8601String(),
      'isAuthenticated': isAuthenticated().toString(),
    };
  }
}
