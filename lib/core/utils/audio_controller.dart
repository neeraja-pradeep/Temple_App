import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class AudioController {
  static final AudioController instance = AudioController._internal();
  final List<AudioPlayer> _players = [];
  AudioSession? _session;

  AudioController._internal();

  /// Initialize audio session (call this once at app start)
  Future<void> init() async {
    _session ??= await AudioSession.instance;
    await _session!.configure(AudioSessionConfiguration.music());
  }

  void register(AudioPlayer player) {
    if (!_players.contains(player)) _players.add(player);
  }

  void unregister(AudioPlayer player) {
    _players.remove(player);
  }

  /// Stops all other internal players and requests audio focus
  Future<void> stopAllExcept(AudioPlayer active) async {
    // Request audio focus (pauses external apps automatically)
    if (_session != null) {
      final hasFocus = await _session!.setActive(true);
      if (!hasFocus) {
        print('❌ Could not gain audio focus');
      }
    }

    // Stop all other internal players
    for (var player in _players) {
      if (player != active) {
        try {
          await player.stop();
        } catch (e) {
          print('❌ Error stopping player: $e');
        }
      }
    }
  }

  /// Call this when your app audio stops, to release focus
  Future<void> releaseFocus() async {
    if (_session != null) {
      await _session!.setActive(false);
    }
  }

  /// Dispose all players and release session (call on logout/app close)
  Future<void> dispose() async {
    for (var player in _players) {
      try {
        await player.stop();
        await player.dispose();
      } catch (e) {
        print('❌ Error disposing player: $e');
      }
    }
    _players.clear();

    if (_session != null) {
      await _session!.setActive(false);
      _session = null;
    }

    print('✅ AudioController disposed');
  }
}
