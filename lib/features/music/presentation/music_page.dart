import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple_app/core/app_colors.dart';
import 'package:temple_app/core/utils/audio_controller.dart';
import 'package:temple_app/features/music/providers/music_providers.dart';
import 'package:temple_app/features/music/data/song_model.dart';
import 'package:temple_app/features/music/presentation/music_player_page.dart';

class MusicPage extends ConsumerStatefulWidget {
  const MusicPage({super.key});

  @override
  ConsumerState<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends ConsumerState<MusicPage> {
  @override
  void initState() {
    super.initState();
    final player = ref.read(audioPlayerProvider);

    // Register this player to the coordinator
    AudioController.instance.register(player);

    _setupAutoPlay();
  }

  void _setupAutoPlay() {
    // Listen to player completion events for auto-play
    ref.read(audioPlayerProvider).playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        _playNextSong();
      }
    });
  }

  Future<void> _playNextSong() async {
    final queue = ref.read(queueProvider);
    if (queue.isEmpty) return;

    final currentIndex = ref.read(queueIndexProvider);
    final nextIndex = (currentIndex + 1) % queue.length;

    // If we're at the last song, loop back to first song
    if (nextIndex == 0 && currentIndex == queue.length - 1) {
      // Loop back to first song
      await _playAt(ref, 0);
    } else {
      // Play next song
      await _playAt(ref, nextIndex);
    }
  }

  Future<void> _playAt(WidgetRef ref, int index) async {
    final queue = ref.read(queueProvider);
    if (index < 0 || index >= queue.length) return;
    final song = queue[index];

    // Set providers immediately for UI updates
    ref.read(queueIndexProvider.notifier).state = index;
    ref.read(currentlyPlayingIdProvider.notifier).state = song.id;

    final player = ref.read(audioPlayerProvider);
    final String originalUrl = song.streamUrl;
    final String url = _normalizeStreamUrl(originalUrl);
    try {
      debugPrint('=== AUDIO LOAD START ===');
      debugPrint('Original URL: $originalUrl');
      debugPrint('Normalized URL: $url');
      await player.setAudioSource(
        AudioSource.uri(
          Uri.parse(url),
          headers: const {
            'Accept': '*/*',
            'User-Agent': 'TemplePlayer/1.0 (JustAudio/ExoPlayer)',
          },
        ),
      );
      await player.seek(Duration.zero);
      await AudioController.instance.stopAllExcept(player);
      await player.play();
      ref.read(isPlayingProvider.notifier).state = true;
      debugPrint('=== AUDIO PLAY STARTED ===');
    } catch (e, st) {
      debugPrint('=== AUDIO LOAD ERROR ===');
      debugPrint('Error: $e');
      debugPrint(st.toString());
      debugPrint('Will retry once with https (if applicable) and no headers');
      try {
        final String httpsUrl = url.startsWith('http://')
            ? url.replaceFirst('http://', 'https://')
            : url;
        await player.setAudioSource(AudioSource.uri(Uri.parse(httpsUrl)));
        await player.seek(Duration.zero);
        await AudioController.instance.stopAllExcept(player);
        await player.play();
        ref.read(isPlayingProvider.notifier).state = true;
        debugPrint('Retry succeeded');
      } catch (e2, st2) {
        debugPrint('Retry failed: $e2');
        debugPrint(st2.toString());
      }
      debugPrint('=== END AUDIO LOAD ERROR ===');
    }
  }

  Future<bool> _isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _showOfflineDialog(BuildContext context) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          backgroundColor: Colors.white,
          titlePadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
          contentPadding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
          actionsPadding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
          title: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: AppColors.selected.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.wifi_off,
                  color: AppColors.selected,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'ഇന്റർനെറ്റ് ബന്ധം ഇല്ല',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    fontFamily: 'NotoSansMalayalam',
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'മ്യൂസിക് ഉപയോഗിക്കാൻ ഇന്‍റര്‍നെറ്റ് ഓണാക്കുക.',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w400,
              fontFamily: 'NotoSansMalayalam',
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.selected,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  elevation: 0,
                ),
                child: Text(
                  'ശരി',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final songsAsync = ref.watch(songsProvider);
    final currentlyPlayingId = ref.watch(currentlyPlayingIdProvider);
    final queue = ref.watch(queueProvider);
    final queueIndex = ref.watch(queueIndexProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 60.h,
        leadingWidth: 64.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 0.w),
          // child: Image.asset(
          //   'assets/icons/playlist.png',
          //   width: 24.w,
          //   height: 24.h,
          //   color: AppColors.selected,
          // ),
        ),
        title: Text(
          'Playlist',
          style: TextStyle(
            color: AppColors.selected,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: SizedBox(width: 24.w, height: 24.h),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: songsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, __) => Center(child: Text('Failed to load songs: $e')),
              data: (songs) {
                return ListView.separated(
                  padding: EdgeInsets.only(
                    top: 16.h,
                    bottom: 16.h,
                    left: 16.w,
                    right: 16.w,
                  ),
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return _SongTile(
                      song: song,
                      onOpen: () async {
                        // Check connectivity before opening player
                        final online = await _isOnline();
                        if (!online) {
                          await _showOfflineDialog(context);
                          return;
                        }
                        // Open full player immediately on first tap
                        final songsList = ref.read(songsProvider).requireValue;
                        ref.read(queueProvider.notifier).state = songsList;
                        final tappedIndex = songsList.indexWhere(
                          (s) => s.id == song.id,
                        );
                        ref.read(queueIndexProvider.notifier).state =
                            tappedIndex < 0 ? 0 : tappedIndex;
                        // Set currently playing ID immediately for mini player visibility
                        ref.read(currentlyPlayingIdProvider.notifier).state =
                            song.id;
                        // Navigate first to avoid any delay from audio setup
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const MusicPlayerPage(),
                          ),
                        );
                        // Then set up and start playback asynchronously
                        Future.microtask(() async {
                          final player = ref.read(audioPlayerProvider);
                          try {
                            final String originalUrl = song.streamUrl;
                            final String url = _normalizeStreamUrl(originalUrl);
                            debugPrint('=== AUDIO LOAD (list tap) ===');
                            debugPrint('Original URL: $originalUrl');
                            debugPrint('Normalized URL: $url');
                            await player.setAudioSource(
                              AudioSource.uri(
                                Uri.parse(url),
                                headers: const {
                                  'Accept': '*/*',
                                  'User-Agent':
                                      'TemplePlayer/1.0 (JustAudio/ExoPlayer)',
                                },
                              ),
                            );
                            await player.seek(Duration.zero);
                            await AudioController.instance.stopAllExcept(player);
                            await player.play();
                            ref.read(isPlayingProvider.notifier).state = true;
                          } catch (e, st) {
                            debugPrint('AUDIO LOAD ERROR (list tap): $e');
                            debugPrint(st.toString());
                            try {
                              final String httpsUrl =
                                  song.streamUrl.startsWith('http://')
                                  ? song.streamUrl.replaceFirst(
                                      'http://',
                                      'https://',
                                    )
                                  : song.streamUrl;
                              await player.setAudioSource(
                                AudioSource.uri(Uri.parse(httpsUrl)),
                              );
                              await player.seek(Duration.zero);
                              await AudioController.instance.stopAllExcept(player);
                              await player.play();
                              ref.read(isPlayingProvider.notifier).state = true;
                            } catch (e2, st2) {
                              debugPrint('Retry failed (list tap): $e2');
                              debugPrint(st2.toString());
                            }
                          }
                        });
                      },
                    );
                  },
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemCount: songs.length,
                );
              },
            ),
          ),
          // Mini player at bottom - show when there's a current song, regardless of playing state
          if (currentlyPlayingId != null &&
              queue.isNotEmpty &&
              queueIndex >= 0 &&
              queueIndex < queue.length)
            _MiniPlayer(
              song: queue[queueIndex],
              onTap: () async {
                final online = await _isOnline();
                if (!online) {
                  await _showOfflineDialog(context);
                  return;
                }
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MusicPlayerPage()),
                );
              },
            ),
        ],
      ),
    );
  }
}

// Prefer https when possible and trim whitespace
String _normalizeStreamUrl(String url) {
  final String trimmed = url.trim();
  if (trimmed.startsWith('http://res.cloudinary.com/')) {
    return trimmed.replaceFirst('http://', 'https://');
  }
  return trimmed;
}

class _SongTile extends StatelessWidget {
  final SongItem song;
  final VoidCallback onOpen;

  const _SongTile({required this.song, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
        padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    song.artist,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.6),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w300,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            SizedBox(
              width: 52.w,
              child: Text(
                song.duration,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniPlayer extends ConsumerWidget {
  final SongItem song;
  final VoidCallback onTap;

  const _MiniPlayer({required this.song, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(audioPlayerProvider);

    return Container(
      margin: EdgeInsets.all(0.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.selected,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          // Song thumbnail
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.r),
              color: Colors.white.withOpacity(0.1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: Image.network(
                song.media ?? song.homeMedia ?? '',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.white.withOpacity(0.1),
                  child: Icon(
                    Icons.music_note,
                    color: Colors.white.withOpacity(0.6),
                    size: 20.sp,
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.white.withOpacity(0.1),
                    child: Center(
                      child: SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Song info
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    song.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    song.artist,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w300,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Play/Pause button
          StreamBuilder<bool>(
            stream: player.playingStream,
            initialData: player.playing,
            builder: (context, snap) {
              final bool isPlaying = snap.data ?? false;
              return GestureDetector(
                onTap: () async {
                  if (isPlaying) {
                    await player.pause();
                    ref.read(isPlayingProvider.notifier).state = false;
                  } else {
                    await AudioController.instance.stopAllExcept(player);
                    await player.play();
                    ref.read(isPlayingProvider.notifier).state = true;
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    isPlaying
                        ? 'assets/icons/play.png'
                        : 'assets/icons/pause.png',
                    width: 20.w,
                    height: 20.w,
                    color: AppColors.selected,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
