import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temple_app/features/global_api_notifer/data/repository/sync_repository.dart';

final syncRepositoryProvider = Provider((ref) => SyncRepository());

/// Periodic background check (every 30 seconds)
final syncTimerProvider = Provider.autoDispose((ref) {
  final repo = ref.read(syncRepositoryProvider);

  print('🚀 Starting 30-second sync timer...');
  print('⏰ First sync check will happen immediately');

  Timer.periodic(const Duration(minutes: 1), (timer) async {
    print('⏰ 30-second timer triggered - starting sync check...');
    await repo.checkForUpdates(ref);
  });

  // Optional: immediate check when app opens
  print('🔄 Performing immediate sync check...');
  repo.checkForUpdates(ref);
});

/// For manual refresh via UI button
final manualSyncProvider = FutureProvider<void>((ref) async {
  final repo = ref.read(syncRepositoryProvider);
  await repo.checkForUpdates(ref);
});
