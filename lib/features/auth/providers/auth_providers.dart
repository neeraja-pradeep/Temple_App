import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/token_provider.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../../core/services/signin_api_service.dart';
import '../../../core/services/token_storage_service.dart';

// Form keys
final loginFormKeyProvider = Provider<GlobalKey<FormState>>((ref) {
  return GlobalKey<FormState>();
});

final registerFormKeyProvider = Provider<GlobalKey<FormState>>((ref) {
  return GlobalKey<FormState>();
});

// User basic details form key
final userBasicFormKeyProvider = Provider<GlobalKey<FormState>>((ref) {
  return GlobalKey<FormState>();
});

// User address details form key
final userAddressFormKeyProvider = Provider<GlobalKey<FormState>>((ref) {
  return GlobalKey<FormState>();
});

// Text controllers (autoDispose to clean up automatically)
final loginPhoneControllerProvider = AutoDisposeProvider<TextEditingController>(
  (ref) {
    final controller = TextEditingController();
    ref.onDispose(controller.dispose);
    return controller;
  },
);

final loginOtpControllerProvider = AutoDisposeProvider<TextEditingController>((
  ref,
) {
  final controller = TextEditingController();
  ref.onDispose(controller.dispose);
  return controller;
});

final registerNameControllerProvider =
    AutoDisposeProvider<TextEditingController>((ref) {
      final controller = TextEditingController();
      ref.onDispose(controller.dispose);
      return controller;
    });

final registerPhoneControllerProvider =
    AutoDisposeProvider<TextEditingController>((ref) {
      final controller = TextEditingController();
      ref.onDispose(controller.dispose);
      return controller;
    });

final registerOtpControllerProvider =
    AutoDisposeProvider<TextEditingController>((ref) {
      final controller = TextEditingController();
      ref.onDispose(controller.dispose);
      return controller;
    });

// User basic details controllers
final userBasicNameControllerProvider =
    AutoDisposeProvider<TextEditingController>((ref) {
      final controller = TextEditingController();
      ref.onDispose(controller.dispose);
      return controller;
    });

final userBasicPhoneControllerProvider =
    AutoDisposeProvider<TextEditingController>((ref) {
      final controller = TextEditingController();
      ref.onDispose(controller.dispose);
      return controller;
    });

final userBasicDobControllerProvider =
    AutoDisposeProvider<TextEditingController>((ref) {
      final controller = TextEditingController();
      ref.onDispose(controller.dispose);
      return controller;
    });

// Nakshatra state and list
final userBasicNakshatraProvider = StateProvider<String?>((ref) => null);

final userBasicNakshatraListProvider = Provider<List<String>>(
  (ref) => const [
    'Ashwini',
    'Bharani',
    'Krittika',
    'Rohini',
    'Mrigashirsha',
    'Ardra',
    'Punarvasu',
    'Pushya',
    'Ashlesha',
    'Magha',
    'Purva Phalguni',
    'Uttara Phalguni',
    'Hasta',
    'Chitra',
    'Swati',
    'Vishakha',
    'Anuradha',
    'Jyeshtha',
    'Mula',
    'Purva Ashadha',
    'Uttara Ashadha',
    'Shravana',
    'Dhanishta',
    'Shatabhisha',
    'Purva Bhadrapada',
    'Uttara Bhadrapada',
    'Revati',
  ],
);

// User address controllers
final userAddressNameControllerProvider =
    AutoDisposeProvider<TextEditingController>((ref) {
      final controller = TextEditingController();
      ref.onDispose(controller.dispose);
      return controller;
    });

final userAddressLine1ControllerProvider =
    AutoDisposeProvider<TextEditingController>((ref) {
      final controller = TextEditingController();
      ref.onDispose(controller.dispose);
      return controller;
    });

final userAddressLine2ControllerProvider =
    AutoDisposeProvider<TextEditingController>((ref) {
      final controller = TextEditingController();
      ref.onDispose(controller.dispose);
      return controller;
    });

final userAddressCityStateControllerProvider =
    AutoDisposeProvider<TextEditingController>((ref) {
      final controller = TextEditingController();
      ref.onDispose(controller.dispose);
      return controller;
    });

final userAddressPinControllerProvider =
    AutoDisposeProvider<TextEditingController>((ref) {
      final controller = TextEditingController();
      ref.onDispose(controller.dispose);
      return controller;
    });

// Loading state
final authLoadingProvider = StateProvider<bool>((ref) => false);

// Verification ID for OTP
final verificationIdProvider = StateProvider<String?>((ref) => null);

// Track if OTP has been sent
final otpSentProvider = StateProvider<bool>((ref) => false);

// Store signin response for navigation decisions
final signinResponseProvider = StateProvider<SigninResponse?>((ref) => null);

// Auth controller
class AuthController extends StateNotifier<bool> {
  AuthController(this.ref) : super(false);

  final Ref ref;

  Future<void> sendOTP(BuildContext context, String phoneNumber) async {
    print('=== SENDING OTP ===');
    print('Phone Number: $phoneNumber');

    _setLoading(true);
    try {
      await FirebaseAuthService.sendOTP(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('=== AUTO VERIFICATION COMPLETED ===');
          print('Credential Provider ID: ${credential.providerId}');
          print('Credential Sign In Method: ${credential.signInMethod}');

          // Auto-verification completed
          final userCredential = await FirebaseAuth.instance
              .signInWithCredential(credential);

          print(
            'Auto-verification UserCredential: ${userCredential.user != null}',
          );
          if (userCredential.user != null) {
            print('Auto-verification successful!');
            _handleLoginSuccess(context);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print('=== VERIFICATION FAILED ===');
          print('Error Code: ${e.code}');
          print('Error Message: ${e.message}');
          print('Error Details: ${e.toString()}');
          _handleError(context, 'Verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          print('=== OTP CODE SENT ===');
          print('Verification ID: $verificationId');
          print('Resend Token: $resendToken');

          ref.read(verificationIdProvider.notifier).state = verificationId;
          ref.read(otpSentProvider.notifier).state = true;

          // Save verification ID to storage
          TokenStorageService.saveVerificationId(verificationId);

          _setLoading(false);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP sent successfully')),
            );
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('=== AUTO RETRIEVAL TIMEOUT ===');
          print('Verification ID: $verificationId');
          ref.read(verificationIdProvider.notifier).state = verificationId;
        },
      );
    } catch (e) {
      print('=== SEND OTP ERROR ===');
      print('Error: $e');
      _handleError(context, 'Failed to send OTP: $e');
    }
  }

  Future<void> verifyOTP(BuildContext context, String otp) async {
    final verificationId = ref.read(verificationIdProvider);
    if (verificationId == null) {
      _handleError(context, 'Verification ID not found');
      return;
    }

    print('=== OTP VERIFICATION START ===');
    print('Verification ID: $verificationId');
    print('OTP: $otp');

    _setLoading(true);
    try {
      final userCredential = await FirebaseAuthService.verifyOTP(
        verificationId: verificationId,
        otp: otp,
      );

      print('=== OTP VERIFICATION RESULT ===');
      print('UserCredential received: ${userCredential != null}');

      if (userCredential?.user != null) {
        print('User authentication successful!');
        _handleLoginSuccess(context);
      } else {
        print('User authentication failed - no user in credential');
        _handleError(context, 'Invalid OTP');
      }
    } catch (e) {
      print('=== OTP VERIFICATION ERROR ===');
      print('Error: $e');
      _handleError(context, 'OTP verification failed: $e');
    }
  }

  void resetOTPState() {
    ref.read(otpSentProvider.notifier).state = false;
    ref.read(verificationIdProvider.notifier).state = null;
    ref.read(loginOtpControllerProvider).clear();
  }

  Future<void> login(BuildContext context) async {
    final formKey = ref.read(loginFormKeyProvider);
    final otpController = ref.read(loginOtpControllerProvider);

    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final otp = otpController.text.trim();

    // Verify OTP (this method is called when OTP field is visible)
    await verifyOTP(context, otp);
  }

  Future<void> register(BuildContext context) async {
    final formKey = ref.read(registerFormKeyProvider);
    final phoneController = ref.read(registerPhoneControllerProvider);
    final otpController = ref.read(registerOtpControllerProvider);

    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final phoneNumber = phoneController.text.trim();
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      // Send OTP first - format phone number with +91 country code
      String cleanPhoneNumber = phoneNumber
          .replaceAll('+91', '')
          .replaceAll(' ', '')
          .trim();
      // Add +91 prefix for Firebase
      String formattedPhoneNumber = '+91$cleanPhoneNumber';
      await sendOTP(context, formattedPhoneNumber);
    } else {
      // Verify OTP and proceed to user details
      await verifyOTP(context, otp);
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/user/basic');
      }
    }
  }
void _handleLoginSuccess(BuildContext context) async {
  print('=== LOGIN SUCCESS HANDLER ===');

  final currentUser = FirebaseAuthService.getCurrentUser();
  if (currentUser != null) {
    print('Current User ID: ${currentUser.uid}');
    print('Current User Phone: ${currentUser.phoneNumber}');
    print('Is Signed In: ${FirebaseAuthService.isSignedIn()}');

    try {
      final idTokenResult = await currentUser.getIdTokenResult(true);

      if (idTokenResult.token != null) {
        await TokenStorageService.saveAllAuthData(
          idToken: idTokenResult.token!,
          verificationId: ref.read(verificationIdProvider) ?? '',
          refreshToken: currentUser.refreshToken ?? '',
          userId: currentUser.uid,
          phoneNumber: currentUser.phoneNumber ?? '',
          tokenExpiry: idTokenResult.expirationTime ??
              DateTime.now().add(const Duration(hours: 1)),
        );
        print('💾 Token data saved before signin API call');
      }

      // 👉 Call signin API and wait for response
      final signinResponse = await _callSigninApi(
        currentUser.phoneNumber ?? '',
        context,
      );

      if (signinResponse != null) {
        ref.read(signinResponseProvider.notifier).state = signinResponse;
      }

      _setLoading(false);

      if (context.mounted) {
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login successful')));

        // 👉 Navigate AFTER API response is saved
        _handlePostLoginNavigation(context);
      }
    } catch (e) {
      print('Error in login success handler: $e');
      _handleError(context, 'Unexpected error: $e');
    }
  }
}


  /// Call signin API after successful OTP verification
  Future<SigninResponse?> _callSigninApi(
    String phoneNumber,
    BuildContext context,
  ) async {
    try {
      print('=== CALLING SIGNIN API ===');
      print('Phone Number: $phoneNumber');

      final signinResponse = await SigninApiService.signin(phoneNumber);

      print('=== SIGNIN API SUCCESS ===');
      print('Message: ${signinResponse.message}');
      print('Role: ${signinResponse.role}');
      print('Phone Number: ${signinResponse.phoneNumber}');
      print('New User: ${signinResponse.newUser}');

      // Save user role to storage
      await TokenStorageService.saveUserRole(signinResponse.role);

      print('💾 User role saved: ${signinResponse.role}');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome! Role: ${signinResponse.role}'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Return the signin response to handle navigation
      return signinResponse;
    } catch (e) {
      print('=== SIGNIN API ERROR ===');
      print('Error: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signin API failed: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return null;
    }
  }

  void _handleError(BuildContext context, String message) {
    _setLoading(false);
    if (context.mounted) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _setLoading(bool value) {
    state = value;
    ref.read(authLoadingProvider.notifier).state = value;
  }

  /// Handle navigation after successful login based on new user status
  void _handlePostLoginNavigation(BuildContext context) {
    final signinResponse = ref.read(signinResponseProvider);
    log("====================== _handlePostLoginNavigation=============================");
log("signinResponse =============== : ${signinResponse?.newUser??"dfsdfsdf"}");
 if (signinResponse != null && signinResponse.newUser) {
    print('🆕 New user detected, navigating to user details flow');
    Navigator.pushReplacementNamed(context, '/user/basic');
  } else {
    print('👤 Existing user, navigating to main app');
    Navigator.pushReplacementNamed(context, '/main');
  }
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, bool>(
  (ref) => AuthController(ref),
);
