import 'package:flutter_riverpod/flutter_riverpod.dart';

// Providers for booking page state management
final isParticipatingPhysicallyProvider = StateProvider<bool>((ref) => false);
final isAgentCodeProvider = StateProvider<bool>((ref) => false);
final agentCodeProvider = StateProvider<String>((ref) => '');
final showCalendarProvider = StateProvider<bool>((ref) => false);
final selectedCalendarDateProvider = StateProvider<String?>((ref) => null);
