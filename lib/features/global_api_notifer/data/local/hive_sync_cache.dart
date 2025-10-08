import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

class HiveSyncCache {
  static const String _syncBox = 'syncBox';
  static const String _lastUpdateKey = 'lastUpdated';

  static Future<void> saveLastUpdated(String timestamp) async {
    try {
      final box = await Hive.openBox(_syncBox);
      await box.put(_lastUpdateKey, timestamp);
      debugPrint('✅ [HiveSyncCache] Saved last update timestamp: $timestamp');
    } catch (e) {
      debugPrint('❌ [HiveSyncCache] Failed to save timestamp: $e');
    }
  }

  static Future<String?> getLastUpdated() async {
    try {
      final box = await Hive.openBox(_syncBox);
      final data = box.get(_lastUpdateKey);
      debugPrint('📦 [HiveSyncCache] Retrieved timestamp: $data');
      return data;
    } catch (e) {
      debugPrint('❌ [HiveSyncCache] Failed to get timestamp: $e');
      return null;
    }
  }

  static Future<void> clear() async {
    try {
      final box = await Hive.openBox(_syncBox);
      await box.clear();
      debugPrint('🧹 [HiveSyncCache] Cleared sync box');
    } catch (e) {
      debugPrint('❌ [HiveSyncCache] Failed to clear cache: $e');
    }
  }
}
