import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

class HiveSyncCache {
  static const String _syncBox = 'syncBox';
  static const String _lastUpdateKey = 'lastUpdated';

  static Future<void> saveLastUpdated(String timestamp) async {
    try {
      final box = await Hive.openBox(_syncBox);
      // Clear old timestamp and save new one (Hive.put automatically overwrites)
      await box.put(_lastUpdateKey, timestamp);
      debugPrint(
        '✅ [HiveSyncCache] Cleared old timestamp and saved new: $timestamp',
      );
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

      // const forcedTimestamp = '2025-10-14T20:00:00.000000+05:30';
      // debugPrint('📦 [HiveSyncCache] Returning forced timestamp: $forcedTimestamp');
      // return forcedTimestamp;
    } catch (e) {
      debugPrint('❌ [HiveSyncCache] Failed to get timestamp: $e');
      return null;
    }
  }

  static Future<void> clearTimestamp() async {
    try {
      final box = await Hive.openBox(_syncBox);
      await box.delete(_lastUpdateKey);
      debugPrint('🧹 [HiveSyncCache] Cleared timestamp only');
    } catch (e) {
      debugPrint('❌ [HiveSyncCache] Failed to clear timestamp: $e');
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
