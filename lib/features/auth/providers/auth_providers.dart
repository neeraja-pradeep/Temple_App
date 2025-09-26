import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

// Auth controller
class AuthController extends StateNotifier<bool> {
  AuthController(this.ref) : super(false);

  final Ref ref;

  Future<void> login(BuildContext context) async {
    final formKey = ref.read(loginFormKeyProvider);
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    _setLoading(true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      // TODO: Integrate real login logic (API / Firebase)
      if (context.mounted) {
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Logged in')));
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(BuildContext context) async {
    final formKey = ref.read(registerFormKeyProvider);
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    _setLoading(true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      // TODO: Integrate real register logic (API / Firebase)
      if (context.mounted) {
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Account created')));
      }
    } finally {
      _setLoading(false);
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
