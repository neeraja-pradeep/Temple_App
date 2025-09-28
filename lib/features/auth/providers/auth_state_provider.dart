import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temple_app/core/services/auth_state_checker.dart';

/// Provider for authentication state
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((
  ref,
) {
  return AuthStateNotifier();
});

/// Notifier for managing authentication state
class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier() : super(AuthState.checking) {
    _checkInitialAuthState();
  }

  /// Check authentication state on app startup
  Future<void> _checkInitialAuthState() async {
    try {
      print('🔍 Checking initial authentication state...');

      final authState = await AuthStateChecker.checkAuthenticationState();
      state = authState;

      print('✅ Initial auth state set: ${authState.description}');
    } catch (e) {
      print('❌ Error checking initial auth state: $e');
      state = AuthState.notAuthenticated;
    }
  }

  /// Manually check authentication state
  Future<void> checkAuthState() async {
    state = AuthState.checking;

    try {
      final authState = await AuthStateChecker.checkAuthenticationState();
      state = authState;
    } catch (e) {
      print('❌ Error checking auth state: $e');
      state = AuthState.notAuthenticated;
    }
  }

  /// Set user as authenticated (after successful login)
  void setAuthenticated() {
    state = AuthState.authenticated;
  }

  /// Set user as not authenticated (after logout)
  void setNotAuthenticated() {
    state = AuthState.notAuthenticated;
  }

  /// Clear authentication data and set as not authenticated
  Future<void> logout() async {
    try {
      await AuthStateChecker.clearAuthenticationData();
      state = AuthState.notAuthenticated;
    } catch (e) {
      print('❌ Error during logout: $e');
      state = AuthState.notAuthenticated;
    }
  }
}
