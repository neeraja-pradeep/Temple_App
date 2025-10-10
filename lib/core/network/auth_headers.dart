import 'dart:async';

import 'package:temple_app/core/services/token_auto_refresh_service.dart';

import '../services/token_storage_service.dart';

/// Shared helpers for building authenticated request headers.
class AuthHeaders {
  AuthHeaders._();

  /// Returns a bearer token header, refreshing the underlying token if needed.
  static Future<String> requireToken() async {
    final existing = TokenStorageService.getAuthorizationHeader();
    if (existing != null) {
      return existing;
    }

    final refreshedToken = await TokenAutoRefreshService.getValidToken();
    if (refreshedToken == null) {
      throw Exception(
        'No valid authentication token found. Please login again.',
      );
    }

    final refreshedHeader = TokenStorageService.getAuthorizationHeader();
    return refreshedHeader ?? 'Bearer $refreshedToken';
  }

  /// Headers for JSON read/write calls based on a previously retrieved token.
  static Map<String, String> jsonFromHeader(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': token,
      };

  /// Minimal headers for read-only requests based on an existing token.
  static Map<String, String> readFromHeader(String token) => {
        'Accept': 'application/json',
        'Authorization': token,
      };

  /// Convenience helper to build JSON headers after ensuring a valid token.
  static Future<Map<String, String>> json() async =>
      jsonFromHeader(await requireToken());

  /// Convenience helper to build read-only headers after ensuring a valid token.
  static Future<Map<String, String>> read() async =>
      readFromHeader(await requireToken());
}
