import 'package:hive_flutter/hive_flutter.dart';
import 'package:temple/features/pooja/data/models/malayalam_date_model.dart';
import 'package:temple/features/pooja/data/models/pooja_category_model.dart';
import 'package:temple/features/pooja/data/models/pooja_model.dart';
import 'package:temple/features/special/data/special_pooja_model.dart';

Future<void> initHive() async {
  await Hive.initFlutter();

  // Register all hive adapters
  Hive.registerAdapter(SpecialPoojaAdapter());
  Hive.registerAdapter(SpecialPoojaDateAdapter());
  Hive.registerAdapter(PoojaCategoryAdapter());
  Hive.registerAdapter(PoojaAdapter());
  Hive.registerAdapter(MalayalamDateModelAdapter());
  
}
