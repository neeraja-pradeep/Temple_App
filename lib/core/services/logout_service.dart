import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temple_app/core/services/api_service.dart';
import 'package:temple_app/core/services/token_storage_service.dart';
import 'package:temple_app/core/services/firebase_auth_service.dart';
import 'package:temple_app/core/services/token_auto_refresh_service.dart';
import 'package:temple_app/features/auth/providers/auth_providers.dart';
import 'package:temple_app/features/auth/providers/auth_state_provider.dart';

/// Service to handle user logout operations
class LogoutService {
  /// Perform complete logout process
  static Future<bool> logout([ProviderContainer? container]) async {
    try {
      print('=== LOGOUT SERVICE START ===');

      // Step 1: Call backend logout API
      await _callLogoutApi();

      // Step 2: Sign out from Firebase
      await _signOutFromFirebase();

      // Step 3: Clear all stored data from Hive
      await _clearAllStoredData();

      // Step 4: Stop token auto-refresh monitoring
      TokenAutoRefreshService.stopTokenMonitoring();

      // Step 5: Reset auth state providers
      if (container != null) {
        _resetAuthStateProviders(container);

        // Set auth state to not authenticated
        container.read(authStateProvider.notifier).setNotAuthenticated();
      }

      print('✅ Logout completed successfully');
      print('=== LOGOUT SERVICE END ===');

      return true;
    } catch (e) {
      print('❌ Logout failed: $e');
      print('=== LOGOUT SERVICE END (ERROR) ===');

      // Even if API call fails, we should still clear local data
      try {
        await _signOutFromFirebase();
        await _clearAllStoredData();
        print('✅ Local data cleared despite API error');
      } catch (clearError) {
        print('❌ Failed to clear local data: $clearError');
      }

      return false;
    }
  }

  /// Call backend logout API
  static Future<void> _callLogoutApi() async {
    try {
      print('📡 Calling logout API...');
      await ApiService.logout();
      print('✅ Logout API call successful');
    } catch (e) {
      print('⚠️ Logout API call failed: $e');
      // Don't rethrow - we want to continue with local cleanup
    }
  }

  /// Sign out from Firebase
  static Future<void> _signOutFromFirebase() async {
    try {
      print('🔥 Signing out from Firebase...');
      await FirebaseAuthService.signOut();
      print('✅ Firebase sign out successful');
    } catch (e) {
      print('❌ Firebase sign out failed: $e');
      rethrow;
    }
  }

  /// Clear all stored data from Hive
  static Future<void> _clearAllStoredData() async {
    try {
      print('🗑️ Clearing all stored data...');

      // Clear all tokens and user data
      await TokenStorageService.clearAllTokens();

      print('✅ All stored data cleared');
      print('📋 Cleared data includes:');
      print('   - Bearer token');
      print('   - Verification ID');
      print('   - Refresh token');
      print('   - User ID');
      print('   - Phone number');
      print('   - User role');
      print('   - FCM token');
      print('   - Token expiry');
    } catch (e) {
      print('❌ Failed to clear stored data: $e');
      rethrow;
    }
  }

  /// Check if user is currently logged in
  static bool isLoggedIn() {
    return TokenStorageService.isAuthenticated();
  }

  /// Get current user info before logout (for debugging)
  static Map<String, String?> getUserInfoBeforeLogout() {
    return {
      'userId': TokenStorageService.getUserId(),
      'phoneNumber': TokenStorageService.getPhoneNumber(),
      'userRole': TokenStorageService.getUserRole(),
      'hasFcmToken': TokenStorageService.getFcmToken() != null ? 'Yes' : 'No',
      'isAuthenticated': TokenStorageService.isAuthenticated().toString(),
    };
  }

  /// Reset all auth state providers
  static void _resetAuthStateProviders(ProviderContainer container) {
    try {
      print('🔄 Resetting auth state providers...');

      // Reset OTP sent state
      container.read(otpSentProvider.notifier).state = false;

      // Reset verification ID
      container.read(verificationIdProvider.notifier).state = null;

      // Reset signin response
      container.read(signinResponseProvider.notifier).state = null;

      // Reset auth loading state
      container.read(authLoadingProvider.notifier).state = false;

      // Clear text controllers
      container.read(loginPhoneControllerProvider).clear();
      container.read(loginOtpControllerProvider).clear();

      print('✅ Auth state providers reset successfully');
      print('📋 Reset providers:');
      print('   - otpSentProvider: false');
      print('   - verificationIdProvider: null');
      print('   - signinResponseProvider: null');
      print('   - authLoadingProvider: false');
      print('   - Text controllers cleared');
    } catch (e) {
      print('❌ Failed to reset auth state providers: $e');
    }
  }
}
