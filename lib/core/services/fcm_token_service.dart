import 'package:temple_app/core/services/api_service.dart';
import 'package:temple_app/core/services/token_storage_service.dart';

/// Service to handle FCM token operations
class FcmTokenService {
  /// Send FCM token to backend after successful login
  static Future<bool> sendFcmTokenToBackend() async {
    try {
      // Get FCM token from storage
      final fcmToken = TokenStorageService.getFcmToken();

      if (fcmToken == null || fcmToken.isEmpty) {
        print('⚠️ No FCM token found in storage');
        return false;
      }

      print('=== FCM TOKEN SERVICE ===');
      print('🔑 Retrieved FCM Token: $fcmToken');
      print('=== END FCM TOKEN SERVICE ===');

      // Send token to backend
      await ApiService.sendFcmToken(fcmToken);

      print('✅ FCM token successfully sent to backend');
      return true;
    } catch (e) {
      print('❌ Failed to send FCM token to backend: $e');
      return false;
    }
  }

  /// Check if FCM token needs to be sent (e.g., after login)
  static Future<void> handleFcmTokenAfterLogin() async {
    try {
      // Wait a bit to ensure authentication is complete
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if user is authenticated
      if (!ApiService.isAuthenticated()) {
        print('⚠️ User not authenticated, skipping FCM token send');
        return;
      }

      // Send FCM token to backend
      final success = await sendFcmTokenToBackend();

      if (success) {
        print('🎉 FCM token handling completed successfully');
      } else {
        print('⚠️ FCM token handling failed');
      }
    } catch (e) {
      print('❌ Error in FCM token handling: $e');
    }
  }
}
