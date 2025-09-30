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
      print('🔍 Checking token validity...');

      // First, check if we have a token at all
      final currentToken = TokenStorageService.getIdToken();
      if (currentToken == null) {
        print('❌ No token found in storage');
        return null;
      }

      // Check if token is actually expired (not just about to expire)
      final isActuallyExpired = TokenStorageService.isTokenExpired();
      print('🔍 Token actually expired: $isActuallyExpired');

      if (isActuallyExpired) {
        print('🔄 Token is actually expired, attempting refresh...');

        // Get stored refresh token
        final storedRefreshToken = TokenStorageService.getRefreshToken();

        if (storedRefreshToken != null && storedRefreshToken.isNotEmpty) {
          // Use manual refresh with stored refresh token
          final refreshResult =
              await TokenRefreshService.refreshIdTokenManually(
                storedRefreshToken,
              );

          if (refreshResult != null) {
            print('✅ Token refreshed successfully');
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
              print('✅ Token refreshed successfully with new refresh token');
              return refreshResult["idToken"];
            }
          }
        }

        // Fallback to automatic refresh
        final fallbackToken = await TokenRefreshService.getValidToken();
        if (fallbackToken != null) {
          print('✅ Token refreshed via fallback method');
          return fallbackToken;
        }

        print('❌ All token refresh attempts failed');
        return null;
      } else {
        print('✅ Token is still valid, returning current token');
        return currentToken;
      }
    } catch (e) {
      print('❌ Error in getValidBearerToken: $e');
      return null;
    }
  }

  /// Get authorization header with automatic token refresh
  static Future<String?> getAuthorizationHeader() async {
    try {
      print('🔐 Getting authorization header...');
      final bearerToken = await getValidBearerToken();
      print(
        '🔍 Bearer token result: ${bearerToken != null ? '${bearerToken.substring(0, 20)}...' : 'null'}',
      );
      if (bearerToken != null) {
        final header = 'Bearer $bearerToken';
        print('✅ Authorization header generated successfully');
        return header;
      } else {
        print('❌ No valid bearer token available');
        return null;
      }
    } catch (e) {
      print('❌ Error getting authorization header: $e');
      return null;
    }
  }
}
