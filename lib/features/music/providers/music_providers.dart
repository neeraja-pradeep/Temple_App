import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../data/music_repository.dart';
import '../data/song_model.dart';

// Repository provider
final musicRepositoryProvider = Provider<MusicRepository>((ref) {
  return MusicRepository();
});

// Songs provider - fetches songs from API
final songsProvider = FutureProvider<List<SongItem>>((ref) async {
  final repository = ref.read(musicRepositoryProvider);
  return await repository.fetchSongs();
});

// Audio player provider
final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  return AudioPlayer();
});

// Queue provider - holds the current playlist
final queueProvider = StateProvider<List<SongItem>>((ref) {
  return [];
});

// Queue index provider - current song index in queue
final queueIndexProvider = StateProvider<int>((ref) {
  return 0;
});

// Mute state provider
final isMutedProvider = StateProvider<bool>((ref) {
  return false;
});

// Playing state provider
final isPlayingProvider = StateProvider<bool>((ref) {
  return false;
});

// Currently playing song ID provider
final currentlyPlayingIdProvider = StateProvider<int?>((ref) {
  return null;
});

