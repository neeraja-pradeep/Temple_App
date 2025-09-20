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
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:temple/core/hive/hive_init_provider.dart';
import 'package:temple/features/shop/cart/data/repositories/cart_repository.dart';

import 'core/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // 📦 Initialize Hive
  await Hive.initFlutter();
  await HiveInitializer.init(); // 👈 register all adapters
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Call the function once
    Future.microtask(()async {
     await CartRepository().getinitStateCartFromAPi();
    });
  }

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

  