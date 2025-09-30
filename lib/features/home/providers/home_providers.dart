import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:temple_app/features/home/data/models/god_category_model.dart';
import 'package:temple_app/features/home/data/models/profile_model.dart';
import 'package:temple_app/features/home/data/models/song_model.dart';
import 'package:temple_app/features/home/data/repositories/home_repositories.dart';

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => HomeRepository(),
);

final godCategoriesProvider = FutureProvider<List<GodCategory>>((ref) async {
  print('🚀🚀🚀 GOD CATEGORIES PROVIDER CALLED 🚀🚀🚀');

  // Wait a bit to ensure token is available after login
  print('⏳ Waiting 200ms for token to be available...');
  await Future.delayed(const Duration(milliseconds: 200));
  print('✅ Wait completed, proceeding with API call');

  final repo = ref.read(homeRepositoryProvider);
  print('📞 Calling fetchGodCategories from repository...');
  return repo.fetchGodCategories();
});

final profileProvider = FutureProvider<Profile>((ref) async {
  final repo = ref.read(homeRepositoryProvider);
  return repo.fetchProfile();
});

final songProvider = FutureProvider<Song>((ref) async {
  final repo = ref.read(homeRepositoryProvider);
  return repo.fetchSong();
});

final audioPlayerProvider = Provider<AudioPlayer>((ref) => AudioPlayer());
final isPlayingProvider = StateProvider<bool>((ref) => false);
