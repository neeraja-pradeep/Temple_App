import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudioService extends StateNotifier<AudioState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isInitialized = false;

  AudioService() : super(const AudioState()) {
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    try {
      // Set audio to loop
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);

      // Set volume to 0.3 (30%) for background music
      await _audioPlayer.setVolume(0.3);

      // Set player mode for better streaming
      await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);

      _isInitialized = true;
      state = state.copyWith(isInitialized: true);
    } catch (e) {
      print('Error initializing audio: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> playBackgroundMusic(String streamUrl) async {
    if (!_isInitialized) return;

    try {
      if (state.isPlaying) {
        await _audioPlayer.stop();
      }

      await _audioPlayer.play(UrlSource(streamUrl));
      state = state.copyWith(isPlaying: true, isMuted: false, error: null);
    } catch (e) {
      print('Error playing audio: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleMute() async {
    if (!_isInitialized) return;

    try {
      if (state.isMuted) {
        await _audioPlayer.setVolume(0.3);
        state = state.copyWith(isMuted: false);
      } else {
        await _audioPlayer.setVolume(0.0);
        state = state.copyWith(isMuted: true);
      }
    } catch (e) {
      print('Error toggling mute: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> stop() async {
    if (!_isInitialized) return;

    try {
      await _audioPlayer.stop();
      state = state.copyWith(isPlaying: false, isMuted: false);
    } catch (e) {
      print('Error stopping audio: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

class AudioState {
  final bool isPlaying;
  final bool isMuted;
  final bool isInitialized;
  final String? error;

  const AudioState({
    this.isPlaying = false,
    this.isMuted = false,
    this.isInitialized = false,
    this.error,
  });

  AudioState copyWith({
    bool? isPlaying,
    bool? isMuted,
    bool? isInitialized,
    String? error,
  }) {
    return AudioState(
      isPlaying: isPlaying ?? this.isPlaying,
      isMuted: isMuted ?? this.isMuted,
      isInitialized: isInitialized ?? this.isInitialized,
      error: error,
    );
  }
}

final audioServiceProvider = StateNotifierProvider<AudioService, AudioState>((
  ref,
) {
  return AudioService();
});
