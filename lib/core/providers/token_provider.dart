import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/token_storage_service.dart';

/// Provider for token storage service
final tokenStorageProvider = Provider<TokenStorageService>((ref) {
  return TokenStorageService();
});

/// Provider for current authentication status
final isAuthenticatedProvider = StateProvider<bool>((ref) {
  return TokenStorageService.isAuthenticated();
});

/// Provider for current ID token
final idTokenProvider = StateProvider<String?>((ref) {
  return TokenStorageService.getIdToken();
});

/// Provider for current verification ID
final verificationIdProvider = StateProvider<String?>((ref) {
  return TokenStorageService.getVerificationId();
});

/// Provider for current user ID
final userIdProvider = StateProvider<String?>((ref) {
  return TokenStorageService.getUserId();
});

/// Provider for current phone number
final phoneNumberProvider = StateProvider<String?>((ref) {
  return TokenStorageService.getPhoneNumber();
});

/// Provider for current user role
final userRoleProvider = StateProvider<String?>((ref) {
  return TokenStorageService.getUserRole();
});

/// Provider for authorization header
final authorizationHeaderProvider = StateProvider<String?>((ref) {
  return TokenStorageService.getAuthorizationHeader();
});

/// Token controller for managing authentication state
class TokenController extends StateNotifier<bool> {
  TokenController(this.ref) : super(TokenStorageService.isAuthenticated());

  final Ref ref;

  /// Update authentication status
  void updateAuthStatus() {
    final isAuth = TokenStorageService.isAuthenticated();
    state = isAuth;
    ref.read(isAuthenticatedProvider.notifier).state = isAuth;
    ref.read(idTokenProvider.notifier).state = TokenStorageService.getIdToken();
    ref.read(verificationIdProvider.notifier).state =
        TokenStorageService.getVerificationId();
    ref.read(userIdProvider.notifier).state = TokenStorageService.getUserId();
    ref.read(phoneNumberProvider.notifier).state =
        TokenStorageService.getPhoneNumber();
    ref.read(userRoleProvider.notifier).state =
        TokenStorageService.getUserRole();
    ref.read(authorizationHeaderProvider.notifier).state =
        TokenStorageService.getAuthorizationHeader();
  }

  /// Save authentication data and update state
  Future<void> saveAuthData({
    required String idToken,
    required String verificationId,
    required String refreshToken,
    required String userId,
    required String phoneNumber,
    required DateTime tokenExpiry,
    String? userRole,
  }) async {
    await TokenStorageService.saveAllAuthData(
      idToken: idToken,
      verificationId: verificationId,
      refreshToken: refreshToken,
      userId: userId,
      phoneNumber: phoneNumber,
      tokenExpiry: tokenExpiry,
      userRole: userRole,
    );
    updateAuthStatus();
  }

  /// Clear all tokens and update state
  Future<void> clearAllTokens() async {
    await TokenStorageService.clearAllTokens();
    updateAuthStatus();
  }

  /// Get authorization header for API calls
  String? getAuthorizationHeader() {
    return TokenStorageService.getAuthorizationHeader();
  }

  /// Check if token is expired
  bool isTokenExpired() {
    return TokenStorageService.isTokenExpired();
  }
}

/// Token controller provider
final tokenControllerProvider = StateNotifierProvider<TokenController, bool>((
  ref,
) {
  return TokenController(ref);
});
