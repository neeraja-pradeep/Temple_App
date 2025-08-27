// Project structure:
// lib/
//   core/         - App-level core utilities and root widgets
//   features/     - Feature modules (counter, etc.)
//     <feature>/
//       presentation/ - UI widgets/screens for the feature
//       providers/    - Riverpod providers for the feature
//   main.dart     - Entry point
//
// Add more features by following the same pattern in features/.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/app.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => const App(),
    );
  }
}
