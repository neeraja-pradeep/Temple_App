import 'package:flutter_riverpod/flutter_riverpod.dart';

// Providers for booking page state management
final isParticipatingPhysicallyProvider = StateProvider<bool>((ref) => false);
final isAgentCodeProvider = StateProvider<bool>((ref) => false);
final agentCodeProvider = StateProvider<String>((ref) => '');
final showCalendarProvider = StateProvider<bool>((ref) => false);
final selectedCalendarDateProvider = StateProvider<String?>((ref) => null);

// One-time reset flag for BookingPage per user session
final bookingPageResetProvider = StateProvider.family<bool, int>(
  (ref, userId) => false,
);
