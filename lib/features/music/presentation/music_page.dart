import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple/core/app_colors.dart';
import 'package:temple/features/music/providers/music_providers.dart';
import 'package:temple/features/music/data/song_model.dart';
import 'package:temple/features/music/presentation/music_player_page.dart';

class MusicPage extends ConsumerWidget {
  const MusicPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(songsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 60.h,
        leadingWidth: 64.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 0.w),
          child: Image.asset(
            'assets/icons/playlist.png',
            width: 24.w,
            height: 24.h,
            color: AppColors.selected,
          ),
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
      body: songsAsync.when(
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
                  // Open full player immediately on first tap
                  final songsList = ref.read(songsProvider).requireValue;
                  ref.read(queueProvider.notifier).state = songsList;
                  final tappedIndex = songsList.indexWhere(
                    (s) => s.id == song.id,
                  );
                  ref.read(queueIndexProvider.notifier).state = tappedIndex < 0
                      ? 0
                      : tappedIndex;
                  // Navigate first to avoid any delay from audio setup
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MusicPlayerPage()),
                  );
                  // Then set up and start playback asynchronously
                  Future.microtask(() async {
                    final player = ref.read(audioPlayerProvider);
                    try {
                      await player.setAudioSource(
                        AudioSource.uri(Uri.parse(song.streamUrl)),
                      );
                      await player.seek(Duration.zero);
                      await player.play();
                      ref.read(currentlyPlayingIdProvider.notifier).state =
                          song.id;
                      ref.read(isPlayingProvider.notifier).state = true;
                    } catch (_) {}
                  });
                },
                durationTextFuture: _getOrLoadDuration(song),
              );
            },
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemCount: songs.length,
          );
        },
      ),
    );
  }

  Future<String> _getOrLoadDuration(SongItem song) async {
    final box = await Hive.openBox("song_durations");
    final cached = box.get(song.id.toString());
    if (cached is String) return cached;
    final player = AudioPlayer();
    try {
      await player.setAudioSource(AudioSource.uri(Uri.parse(song.streamUrl)));
      final duration = await player.load();
      final total = duration ?? player.duration;
      final text = _formatDuration(total);
      if (text != null) {
        await box.put(song.id.toString(), text);
        return text;
      }
    } catch (_) {}
    return "--:--";
  }

  String? _formatDuration(Duration? d) {
    if (d == null) return null;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}

class _SongTile extends StatelessWidget {
  final SongItem song;
  final VoidCallback onOpen;
  final Future<String> durationTextFuture;

  const _SongTile({
    required this.song,
    required this.onOpen,
    required this.durationTextFuture,
  });

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
            FutureBuilder<String>(
              future: durationTextFuture,
              builder: (context, snapshot) {
                final text = snapshot.data ?? '...';
                return SizedBox(
                  width: 52.w,
                  child: Text(
                    text,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
