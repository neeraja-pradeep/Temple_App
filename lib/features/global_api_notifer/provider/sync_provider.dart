import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temple_app/features/global_api_notifer/data/repository/sync_repository.dart';

final syncRepositoryProvider = Provider((ref) => SyncRepository());

/// Periodic background check (every 30 mins)
final syncTimerProvider = Provider.autoDispose((ref) {
  final repo = ref.read(syncRepositoryProvider);

  Timer.periodic(const Duration(seconds:30 ), (_) async {
    await repo.checkForUpdates(ref );
  });

  // Optional: immediate check when app opens
  repo.checkForUpdates(ref );
});

/// For manual refresh via UI button
final manualSyncProvider = FutureProvider<void>((ref) async {
  final repo = ref.read(syncRepositoryProvider);
  await repo.checkForUpdates(ref);
});
