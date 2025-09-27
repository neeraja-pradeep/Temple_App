import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:temple_app/features/home/data/models/god_category_model.dart';
import 'package:temple_app/features/home/data/models/profile_model.dart';
import 'package:temple_app/features/home/data/models/song_model.dart';
import 'package:temple_app/features/home/data/repositories/home_repositories.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) => HomeRepository());


final godCategoriesProvider = FutureProvider<List<GodCategory>>((ref) async {
  final repo = ref.read(homeRepositoryProvider);
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


