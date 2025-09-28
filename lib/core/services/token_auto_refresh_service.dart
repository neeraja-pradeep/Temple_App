import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:temple_app/core/services/token_storage_service.dart';

/// Service to automatically refresh tokens based on expiry time
class TokenAutoRefreshService {
  static Timer? _refreshTimer;
  static bool _isRefreshing = false;

  // Refresh token when it has 5 minutes left to expire
  static const Duration _refreshThreshold = Duration(minutes: 5);

  // Check token status every 2 minutes
  static const Duration _checkInterval = Duration(minutes: 2);

  /// Start automatic token refresh monitoring
  static void startTokenMonitoring() {
    print('🔄 Starting token auto-refresh monitoring...');

    // Cancel any existing timer
    stopTokenMonitoring();

    // Start periodic token checking
    _refreshTimer = Timer.periodic(_checkInterval, (timer) {
      _checkAndRefreshToken();
    });

    // Also check immediately
    _checkAndRefreshToken();
  }

  /// Stop automatic token refresh monitoring
  static void stopTokenMonitoring() {
    print('⏹️ Stopping token auto-refresh monitoring...');
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Check if token needs refresh and refresh if necessary
  static Future<void> _checkAndRefreshToken() async {
    if (_isRefreshing) {
      print('⏳ Token refresh already in progress, skipping...');
      return;
    }

    try {
      final tokenExpiry = TokenStorageService.getTokenExpiry();
      if (tokenExpiry == null) {
        print('⚠️ No token expiry found, skipping refresh check');
        return;
      }

      final now = DateTime.now();
      final timeUntilExpiry = tokenExpiry.difference(now);

      print('🔍 Token expiry check:');
      print('   Current time: $now');
      print('   Token expires: $tokenExpiry');
      print('   Time until expiry: ${timeUntilExpiry.inMinutes} minutes');
      print('   Refresh threshold: ${_refreshThreshold.inMinutes} minutes');

      // Check if token is expired or about to expire
      if (timeUntilExpiry <= _refreshThreshold) {
        print(
          '🔄 Token needs refresh (${timeUntilExpiry.inMinutes} minutes left)',
        );
        await _refreshToken();
      } else {
        print(
          '✅ Token is still valid (${timeUntilExpiry.inMinutes} minutes left)',
        );
      }
    } catch (e) {
      print('❌ Error in token refresh check: $e');
    }
  }

  /// Refresh the token using Firebase
  static Future<bool> _refreshToken() async {
    if (_isRefreshing) {
      print('⏳ Token refresh already in progress');
      return false;
    }

    _isRefreshing = true;
    print('🔄 Starting token refresh...');

    try {
      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ No current user found for token refresh');
        return false;
      }

      // Force refresh the ID token
      final idToken = await user.getIdToken(true);
      final idTokenResult = await user.getIdTokenResult(true);

      if (idToken == null || idTokenResult.token == null) {
        print('❌ Failed to get refreshed token');
        return false;
      }

      print('✅ Token refreshed successfully');
      print('   New expiry: ${idTokenResult.expirationTime}');
      print('   New token preview: ${idToken.substring(0, 20)}...');

      // Update stored token data
      await TokenStorageService.saveAllAuthData(
        idToken: idTokenResult.token!,
        verificationId: TokenStorageService.getVerificationId() ?? '',
        refreshToken: user.refreshToken ?? '',
        userId: user.uid,
        phoneNumber: user.phoneNumber ?? '',
        tokenExpiry:
            idTokenResult.expirationTime ??
            DateTime.now().add(const Duration(hours: 1)),
        userRole: TokenStorageService.getUserRole(),
      );

      print('💾 Refreshed token data saved to storage');
      return true;
    } catch (e) {
      print('❌ Token refresh failed: $e');
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Manually refresh token (can be called from UI)
  static Future<bool> refreshTokenNow() async {
    print('🔄 Manual token refresh requested...');
    return await _refreshToken();
  }

  /// Get token status information
  static Map<String, dynamic> getTokenStatus() {
    final tokenExpiry = TokenStorageService.getTokenExpiry();
    final now = DateTime.now();

    if (tokenExpiry == null) {
      return {
        'hasToken': false,
        'isExpired': true,
        'timeUntilExpiry': null,
        'needsRefresh': true,
        'status': 'No token found',
      };
    }

    final timeUntilExpiry = tokenExpiry.difference(now);
    final isExpired = timeUntilExpiry.isNegative;
    final needsRefresh = timeUntilExpiry <= _refreshThreshold;

    return {
      'hasToken': true,
      'isExpired': isExpired,
      'timeUntilExpiry': timeUntilExpiry,
      'needsRefresh': needsRefresh,
      'expiryTime': tokenExpiry,
      'status': isExpired
          ? 'Expired'
          : needsRefresh
          ? 'Needs refresh'
          : 'Valid',
    };
  }

  /// Check if user is authenticated with valid token
  static bool isAuthenticated() {
    return TokenStorageService.isAuthenticated();
  }

  /// Get time until token expires in a readable format
  static String getTimeUntilExpiry() {
    final tokenExpiry = TokenStorageService.getTokenExpiry();
    if (tokenExpiry == null) return 'No token';

    final now = DateTime.now();
    final timeUntilExpiry = tokenExpiry.difference(now);

    if (timeUntilExpiry.isNegative) {
      return 'Expired';
    }

    final hours = timeUntilExpiry.inHours;
    final minutes = timeUntilExpiry.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Force refresh token and return new token
  static Future<String?> getValidToken() async {
    try {
      // Check if current token is valid
      if (TokenStorageService.isAuthenticated()) {
        final token = TokenStorageService.getIdToken();
        if (token != null) {
          print('✅ Using existing valid token');
          return token;
        }
      }

      // Try to refresh token
      print('🔄 Current token invalid, attempting refresh...');
      final success = await refreshTokenNow();

      if (success) {
        return TokenStorageService.getIdToken();
      } else {
        print('❌ Failed to refresh token');
        return null;
      }
    } catch (e) {
      print('❌ Error getting valid token: $e');
      return null;
    }
  }
}
