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
import 'package:hive_flutter/adapters.dart';
import 'package:temple/features/special/data/models/special_pooja_adapters.dart';
import 'package:temple/features/special/data/models/special_pooja_model.dart';
import 'core/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(SpecialPoojaAdapter());
  Hive.registerAdapter(SpecialPoojaDateAdapter());

  await Hive.openBox<SpecialPooja>('special_poojas');

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
