import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'token_storage_service.dart';

class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Send OTP to phone number
  static Future<void> sendOTP({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 60),
    );
  }

  // Verify OTP and sign in
  static Future<UserCredential?> verifyOTP({
    required String verificationId,
    required String otp,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Log all authentication data
      _logAuthenticationData(userCredential);

      return userCredential;
    } catch (e) {
      debugPrint('OTP verification error: $e');
      return null;
    }
  }

  // Log comprehensive authentication data
  static void _logAuthenticationData(UserCredential userCredential) {
    print('=== FIREBASE AUTHENTICATION DATA ===');

    // User Information
    final user = userCredential.user;
    if (user != null) {
      print('User ID: ${user.uid}');
      print('Phone Number: ${user.phoneNumber}');
      print('Email: ${user.email}');
      print('Display Name: ${user.displayName}');
      print('Photo URL: ${user.photoURL}');
      print('Email Verified: ${user.emailVerified}');
      print('Is Anonymous: ${user.isAnonymous}');
      print('Creation Time: ${user.metadata.creationTime}');
      print('Last Sign In Time: ${user.metadata.lastSignInTime}');
      print('Provider Data: ${user.providerData}');
      print(
        'Refresh Token: ${user.refreshToken ?? "Not available (Firebase handles internally)"}',
      );
      print('Tenant ID: ${user.tenantId}');
      print('Multi Factor: ${user.multiFactor}');
    }

    // Credential Information
    final credential = userCredential.credential;
    if (credential != null) {
      print('Credential Provider ID: ${credential.providerId}');
      print('Credential Sign In Method: ${credential.signInMethod}');
      print('Credential Token: ${credential.token}');
      print('Credential Access Token: ${credential.accessToken}');
    }

    // Additional User Data
    final additionalUserInfo = userCredential.additionalUserInfo;
    if (additionalUserInfo != null) {
      print('Is New User: ${additionalUserInfo.isNewUser}');
      print('Provider ID: ${additionalUserInfo.providerId}');
      print('Profile: ${additionalUserInfo.profile}');
      print('Username: ${additionalUserInfo.username}');
    }

    // Get ID Token and save it
    user
        ?.getIdToken()
        .then((idToken) {
          print('ID Token: $idToken');
          if (idToken != null) {
            TokenStorageService.saveIdToken(idToken);
          }
        })
        .catchError((error) {
          print('Error getting ID Token: $error');
        });

    // Get ID Token Result (includes refresh token) and save all data
    user
        ?.getIdTokenResult()
        .then((idTokenResult) {
          print('ID Token Result:');
          print('  Token: ${idTokenResult.token}');
          print('  Auth Time: ${idTokenResult.authTime}');
          print('  Expiration Time: ${idTokenResult.expirationTime}');
          print('  Issued At Time: ${idTokenResult.issuedAtTime}');
          print('  Sign In Provider: ${idTokenResult.signInProvider}');
          print('  Claims: ${idTokenResult.claims}');

          // Save all authentication data
          if (idTokenResult.token != null) {
            TokenStorageService.saveAllAuthData(
              idToken: idTokenResult.token!,
              verificationId: '', // Will be set by the calling method
              refreshToken: user.refreshToken ?? '',
              userId: user.uid,
              phoneNumber: user.phoneNumber ?? '',
              tokenExpiry:
                  idTokenResult.expirationTime ??
                  DateTime.now().add(const Duration(hours: 1)),
            );
            print('💾 All authentication data saved to storage');
          }
        })
        .catchError((error) {
          print('Error getting ID Token Result: $error');
        });

    print('=== END AUTHENTICATION DATA ===');
  }

  // Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if user is signed in
  static bool isSignedIn() {
    return _auth.currentUser != null;
  }
}
