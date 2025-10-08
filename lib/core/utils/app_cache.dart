import 'package:hive/hive.dart';

class AppCache {
  static const String globalUpdateBox = 'globalUpdateBox';
  static const String lastUpdatedKey = 'lastUpdated';

  static Future<void> saveLastUpdated(String timestamp) async {
    final box = await Hive.openBox(globalUpdateBox);
    await box.put(lastUpdatedKey, timestamp);
  }

  static Future<String?> getLastUpdated() async {
    final box = await Hive.openBox(globalUpdateBox);
    return box.get(lastUpdatedKey);
  }
}
