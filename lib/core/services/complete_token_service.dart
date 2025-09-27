import 'token_storage_service.dart';
import 'token_refresh_service.dart';
import 'firebase_rest_auth_service.dart';

class CompleteTokenService {
  /// Get a refresh token and store it for future use
  static Future<String?> getAndStoreRefreshToken() async {
    try {
      // Try to get refresh token from Firebase REST API
      final result = await FirebaseRestAuthService.getRefreshToken();

      if (result != null && result["refreshToken"] != null) {
        final refreshToken = result["refreshToken"] as String;

        // Store the refresh token
        await TokenStorageService.saveAllAuthData(
          idToken: TokenStorageService.getIdToken() ?? '',
          verificationId: TokenStorageService.getVerificationId() ?? '',
          refreshToken: refreshToken, // Store the real refresh token
          userId: TokenStorageService.getUserId() ?? '',
          phoneNumber: TokenStorageService.getPhoneNumber() ?? '',
          tokenExpiry:
              TokenStorageService.getTokenExpiry() ??
              DateTime.now().add(const Duration(hours: 1)),
          userRole: TokenStorageService.getUserRole(),
        );

        return refreshToken;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Get a valid bearer token (refresh if needed using stored refresh token)
  static Future<String?> getValidBearerToken() async {
    try {
      // Check if current token is expired
      if (TokenRefreshService.isTokenExpired()) {
        // Get stored refresh token
        final storedRefreshToken = TokenStorageService.getRefreshToken();

        if (storedRefreshToken != null && storedRefreshToken.isNotEmpty) {
          // Use manual refresh with stored refresh token
          final refreshResult =
              await TokenRefreshService.refreshIdTokenManually(
                storedRefreshToken,
              );

          if (refreshResult != null) {
            return refreshResult["idToken"];
          }
        } else {
          // Try to get a new refresh token
          final newRefreshToken = await getAndStoreRefreshToken();
          if (newRefreshToken != null) {
            // Try refresh again with new token
            final refreshResult =
                await TokenRefreshService.refreshIdTokenManually(
                  newRefreshToken,
                );
            if (refreshResult != null) {
              return refreshResult["idToken"];
            }
          }
        }

        // Fallback to automatic refresh
        return await TokenRefreshService.getValidToken();
      } else {
        return TokenStorageService.getIdToken();
      }
    } catch (e) {
      return null;
    }
  }

  /// Get authorization header with automatic token refresh
  static Future<String?> getAuthorizationHeader() async {
    final bearerToken = await getValidBearerToken();
    if (bearerToken != null) {
      return 'Bearer $bearerToken';
    }
    return null;
  }
}
