import 'package:firebase_auth/firebase_auth.dart';
import 'package:temple_app/core/services/token_storage_service.dart';

/// Service to check authentication state on app startup
class AuthStateChecker {
  /// Check if user is authenticated and handle token refresh if needed
  static Future<AuthState> checkAuthenticationState() async {
    print('🔍 Checking authentication state on app startup...');

    try {
      // Step 1: Check if we have a stored token
      final storedToken = TokenStorageService.getIdToken();
      if (storedToken == null) {
        print('❌ No stored token found');
        return AuthState.notAuthenticated;
      }

      // Step 2: Check if token is expired
      final isExpired = TokenStorageService.isTokenExpired();
      if (!isExpired) {
        print('✅ Valid token found, user is authenticated');
        return AuthState.authenticated;
      }

      print('⚠️ Token is expired, attempting to refresh...');

      // Step 3: Try to refresh the token
      final refreshSuccess = await _attemptTokenRefresh();
      if (refreshSuccess) {
        print('✅ Token refreshed successfully, user is authenticated');
        return AuthState.authenticated;
      } else {
        print('❌ Token refresh failed, user needs to login');
        return AuthState.notAuthenticated;
      }
    } catch (e) {
      print('❌ Error checking authentication state: $e');
      return AuthState.notAuthenticated;
    }
  }

  /// Attempt to refresh the token using Firebase
  static Future<bool> _attemptTokenRefresh() async {
    try {
      // Check if Firebase user exists
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ No Firebase user found for token refresh');
        return false;
      }

      // Try to get a fresh token
      final idToken = await user.getIdToken(true); // Force refresh
      final idTokenResult = await user.getIdTokenResult(true);

      if (idToken == null || idTokenResult.token == null) {
        print('❌ Failed to get refreshed token from Firebase');
        return false;
      }

      print('🔄 Token refresh successful');
      print('   New expiry: ${idTokenResult.expirationTime}');

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
    }
  }

  /// Get detailed authentication status for debugging
  static Map<String, dynamic> getDetailedAuthStatus() {
    final hasToken = TokenStorageService.getIdToken() != null;
    final isExpired = TokenStorageService.isTokenExpired();
    final tokenExpiry = TokenStorageService.getTokenExpiry();
    final userId = TokenStorageService.getUserId();
    final phoneNumber = TokenStorageService.getPhoneNumber();
    final userRole = TokenStorageService.getUserRole();
    final firebaseUser = FirebaseAuth.instance.currentUser;

    return {
      'hasStoredToken': hasToken,
      'isTokenExpired': isExpired,
      'tokenExpiry': tokenExpiry?.toIso8601String(),
      'userId': userId,
      'phoneNumber': phoneNumber,
      'userRole': userRole,
      'hasFirebaseUser': firebaseUser != null,
      'firebaseUserId': firebaseUser?.uid,
      'firebasePhoneNumber': firebaseUser?.phoneNumber,
      'isFirebaseSignedIn': firebaseUser != null,
    };
  }

  /// Clear all authentication data (for logout)
  static Future<void> clearAuthenticationData() async {
    print('🗑️ Clearing all authentication data...');

    // Sign out from Firebase
    await FirebaseAuth.instance.signOut();

    // Clear stored tokens
    await TokenStorageService.clearAllTokens();

    print('✅ Authentication data cleared');
  }
}

/// Authentication states
enum AuthState {
  authenticated, // User has valid token
  notAuthenticated, // User needs to login
  checking, // Currently checking auth state
}

/// Extension to get user-friendly descriptions
extension AuthStateExtension on AuthState {
  String get description {
    switch (this) {
      case AuthState.authenticated:
        return 'User is authenticated';
      case AuthState.notAuthenticated:
        return 'User needs to login';
      case AuthState.checking:
        return 'Checking authentication...';
    }
  }
}
