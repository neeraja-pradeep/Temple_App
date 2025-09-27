import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/services/firebase_auth_service.dart';

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

// Auth controller
class AuthController extends StateNotifier<bool> {
  AuthController(this.ref) : super(false);

  final Ref ref;

  Future<void> sendOTP(BuildContext context, String phoneNumber) async {
    _setLoading(true);
    try {
      await FirebaseAuthService.sendOTP(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed
          final userCredential = await FirebaseAuth.instance
              .signInWithCredential(credential);
          if (userCredential.user != null) {
            _handleLoginSuccess(context);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          _handleError(context, 'Verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          ref.read(verificationIdProvider.notifier).state = verificationId;
          ref.read(otpSentProvider.notifier).state = true;
          _setLoading(false);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP sent successfully')),
            );
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          ref.read(verificationIdProvider.notifier).state = verificationId;
        },
      );
    } catch (e) {
      _handleError(context, 'Failed to send OTP: $e');
    }
  }

  Future<void> verifyOTP(BuildContext context, String otp) async {
    final verificationId = ref.read(verificationIdProvider);
    if (verificationId == null) {
      _handleError(context, 'Verification ID not found');
      return;
    }

    _setLoading(true);
    try {
      final userCredential = await FirebaseAuthService.verifyOTP(
        verificationId: verificationId,
        otp: otp,
      );

      if (userCredential?.user != null) {
        _handleLoginSuccess(context);
      } else {
        _handleError(context, 'Invalid OTP');
      }
    } catch (e) {
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
      // Send OTP first
      await sendOTP(context, phoneNumber);
    } else {
      // Verify OTP and proceed to user details
      await verifyOTP(context, otp);
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/user/basic');
      }
    }
  }

  void _handleLoginSuccess(BuildContext context) async {
    _setLoading(false);
    if (!context.mounted) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      log("idToken: $idToken");
      final sessionInfo = ref.read(verificationIdProvider);
      final otp = ref.read(loginOtpControllerProvider).text.trim();

      if (sessionInfo != null && otp.isNotEmpty) {
        final tokenData = await FirebaseTokenService.signInWithPhone(
          sessionInfo,
          otp,
        );

        log("idToken: ${tokenData['idToken']}");
        log("refreshToken: ${tokenData['refreshToken']}");
        log("expiresIn: ${tokenData["expiresIn"]}");
      } else {
        log("Could not fetch refreshToken because sessionInfo/otp is missing.");
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login successful')));

      Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
      _handleError(context, "Login failed: $e");
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
}

final authControllerProvider = StateNotifierProvider<AuthController, bool>(
  (ref) => AuthController(ref),
);

class FirebaseTokenService {
  static const String apiKey =
      "AIzaSyAs3a1OCrtUx8C_6ja3vzswjBQPTZwFmjc"; // replace with your key

  static Future<Map<String, dynamic>> signInWithPhone(
    String sessionInfo,
    String otp,
  ) async {
    final url =
        "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPhoneNumber?key=$apiKey";

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"code": otp, "sessionInfo": sessionInfo}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        "idToken": data["idToken"],
        "refreshToken": data["refreshToken"],
        "expiresIn": data["expiresIn"],
        "localId": data["localId"],
        "phoneNumber": data["phoneNumber"],
      };
    } else {
      throw Exception(
        "Failed to sign in: ${response.statusCode} ${response.body}",
      );
    }
  }

  static Future<Map<String, dynamic>> refreshIdToken(
    String refreshToken,
  ) async {
    final url = "https://securetoken.googleapis.com/v1/token?key=$apiKey";

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {"grant_type": "refresh_token", "refresh_token": refreshToken},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        "idToken": data["id_token"],
        "refreshToken": data["refresh_token"],
        "expiresIn": data["expires_in"],
        "userId": data["user_id"],
      };
    } else {
      throw Exception(
        "Failed to refresh token: ${response.statusCode} ${response.body}",
      );
    }
  }
}
