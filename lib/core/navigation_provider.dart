import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to manage navigation state
final navigationIndexProvider = StateProvider<int>(
  (ref) => 2,
); // Default to home (index 2)

// Provider to trigger navigation
final navigationTriggerProvider = StateProvider<int?>((ref) => null);

