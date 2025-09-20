import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:temple/core/app_colors.dart';
import 'package:temple/core/navigation_provider.dart';
import '../data/song_model.dart';
import '../providers/music_providers.dart';

class MusicPlayerPage extends ConsumerStatefulWidget {
  const MusicPlayerPage({super.key});

  @override
  ConsumerState<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends ConsumerState<MusicPlayerPage> {
  Stream<Duration> get _positionStream =>
      ref.read(audioPlayerProvider).positionStream;
  Stream<Duration?> get _durationStream =>
      ref.read(audioPlayerProvider).durationStream;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(audioPlayerProvider);
    final queue = ref.watch(queueProvider);
    final index = ref.watch(queueIndexProvider);
    final isMuted = ref.watch(isMutedProvider);
    final SongItem? current =
        queue.isNotEmpty && index >= 0 && index < queue.length
        ? queue[index]
        : null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: current == null
          ? const SafeArea(
              child: Center(
                child: Text(
                  'No song selected',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                // Full screen background image
                Image.network(
                  current.media ?? current.homeMedia ?? '',
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey.shade800,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) {
                    print('=== IMAGE LOAD ERROR ===');
                    print(
                      'Trying to load image from: ${current.media ?? current.homeMedia ?? 'NO IMAGE URL'}',
                    );
                    print('Song: ${current.title} by ${current.artist}');
                    print('Media URL: ${current.media}');
                    print('Home Media URL: ${current.homeMedia}');
                    print('=== END IMAGE ERROR ===');
                    return Container(color: Colors.black);
                  },
                ),
                // Dark overlay for better text visibility
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                // Content with SafeArea
                SafeArea(
                  child: Column(
                    children: [
                      // Top bar
                      // Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 16.w),
                      //   child: Row(
                      //     children: [
                      //       IconButton(
                      //         icon: Icon(
                      //           Icons.arrow_back,
                      //           color: Colors.white,
                      //           size: 24.sp,
                      //         ),
                      //         onPressed: () => Navigator.of(context).pop(),
                      //       ),
                      //       const Spacer(),
                      //     ],
                      //   ),
                      // ),

                      // Spacer to push content to bottom
                      const Spacer(),

                      // Bottom content container
                      Container(
                        padding: EdgeInsets.only(
                          left: 24.w,
                          right: 24.w,
                          bottom: 0.h,
                        ),
                        child: Column(
                          children: [
                            // Title / Artist
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,

                              children: [
                                Text(
                                  current.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  current.artist,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 0),

                            // Progress + slider
                            StreamBuilder<Duration?>(
                              stream: _durationStream,
                              builder: (context, durationSnap) {
                                final total =
                                    durationSnap.data ?? Duration.zero;
                                return StreamBuilder<Duration>(
                                  stream: _positionStream,
                                  builder: (context, positionSnap) {
                                    final pos =
                                        positionSnap.data ?? Duration.zero;
                                    final clamped = pos > total ? total : pos;
                                    return Column(
                                      children: [
                                        SliderTheme(
                                          data: SliderTheme.of(context)
                                              .copyWith(
                                                trackHeight: 3,
                                                activeTrackColor: Colors.white,
                                                inactiveTrackColor:
                                                    Colors.white,
                                                thumbColor: Colors.white,
                                                overlayColor:
                                                    Colors.transparent,
                                                thumbShape:
                                                    const RoundSliderThumbShape(
                                                      enabledThumbRadius: 10,
                                                      elevation: 0,
                                                      pressedElevation: 0,
                                                    ),
                                                trackShape:
                                                    const _ThinTrackShape(
                                                      activeThickness: 3,
                                                      inactiveThickness: 1,
                                                    ),
                                              ),
                                          child: Slider(
                                            value: clamped.inMilliseconds
                                                .toDouble(),
                                            min: 0,
                                            max:
                                                (total.inMilliseconds == 0
                                                        ? 1
                                                        : total.inMilliseconds)
                                                    .toDouble(),
                                            onChanged: (v) async {
                                              await player.seek(
                                                Duration(
                                                  milliseconds: v.toInt(),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _fmt(clamped),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                            Text(
                                              _fmt(total),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),

                            SizedBox(height: 0),

                            // Controls
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 0.w,
                                vertical: 8.h,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: Image.asset(
                                      isMuted
                                          ? 'assets/icons/mute.png'
                                          : 'assets/icons/sound.png',
                                      width: 28.w,
                                      height: 28.w,
                                    ),
                                    iconSize: 28.sp,
                                    onPressed: () async {
                                      final muteNotifier = ref.read(
                                        isMutedProvider.notifier,
                                      );
                                      muteNotifier.state = !muteNotifier.state;
                                      await player.setVolume(
                                        muteNotifier.state ? 0 : 1,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Image.asset(
                                      'assets/icons/back.png',
                                      width: 36.w,
                                      height: 36.w,
                                    ),
                                    iconSize: 36.sp,
                                    onPressed: () async => _prev(ref),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.selected,
                                      shape: BoxShape.circle,
                                    ),
                                    width: 80.w,
                                    height: 80.w,
                                    child: StreamBuilder<bool>(
                                      stream: player.playingStream,
                                      initialData: player.playing,
                                      builder: (context, snap) {
                                        final bool isPlaying =
                                            snap.data ?? false;
                                        return IconButton(
                                          icon: Image.asset(
                                            isPlaying
                                                ? 'assets/icons/play.png'
                                                : 'assets/icons/pause.png',
                                            width: 36.w,
                                            height: 36.w,
                                          ),
                                          iconSize: 36.sp,
                                          onPressed: () async {
                                            if (isPlaying) {
                                              await player.pause();
                                            } else {
                                              await player.play();
                                            }
                                            ref
                                                    .read(
                                                      isPlayingProvider
                                                          .notifier,
                                                    )
                                                    .state =
                                                !isPlaying;
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: Image.asset(
                                      'assets/icons/next.png',
                                      width: 36.w,
                                      height: 36.w,
                                    ),
                                    iconSize: 36.sp,
                                    onPressed: () async => _next(ref),
                                  ),
                                  IconButton(
                                    icon: Image.asset(
                                      'assets/icons/playlist.png',
                                      width: 28.w,
                                      height: 28.w,
                                      color: Colors.white,
                                    ),
                                    iconSize: 28.sp,
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70.h,
          decoration: BoxDecoration(
            color: AppColors.navBarBackground,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8.r,
                offset: Offset(0, -2.h),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Special
              _buildNavItem(0, 'assets/bottomNavBar/bn1.png', 'പ്രത്യകം'),
              // Pooja
              _buildNavItem(1, 'assets/bottomNavBar/bn2.png', 'പൂജ'),
              // Home
              _buildNavItem(2, 'assets/bottomNavBar/bn3.png', 'ദർശനം'),
              // Shop
              _buildNavItem(3, 'assets/bottomNavBar/bn4.png', 'വിപണി'),
              // Music (selected)
              _buildSelectedNavItem(4, 'assets/bottomNavBar/bn5.png', 'സംഗീതം'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String iconPath, String label) {
    return GestureDetector(
      onTap: () {
        // Navigate to the selected page
        // Pop all routes until we reach the main screen
        Navigator.of(context).popUntil((route) => route.isFirst);
        // Trigger navigation to the selected page
        ref.read(navigationTriggerProvider.notifier).state = index;
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            height: 26.h,
            width: 26.w,
            color: AppColors.unselected,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedNavItem(int index, String iconPath, String label) {
    return Container(
      width: 65.w,
      height: 50.h,
      decoration: BoxDecoration(
        color: AppColors.selectedBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.selectedBackground, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(140, 0, 26, 0.16),
            offset: Offset(0, 4.h),
            blurRadius: 16.r,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            width: 28.w,
            height: 28.w,
            color: AppColors.selected,
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.selected,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _next(WidgetRef ref) async {
    final queue = ref.read(queueProvider);
    if (queue.isEmpty) return;
    final idxNotifier = ref.read(queueIndexProvider.notifier);
    final next = (idxNotifier.state + 1) % queue.length;
    await _playAt(ref, next);
  }

  Future<void> _prev(WidgetRef ref) async {
    final queue = ref.read(queueProvider);
    if (queue.isEmpty) return;
    final idxNotifier = ref.read(queueIndexProvider.notifier);
    final prev = (idxNotifier.state - 1) < 0
        ? queue.length - 1
        : idxNotifier.state - 1;
    await _playAt(ref, prev);
  }

  Future<void> _playAt(WidgetRef ref, int index) async {
    final queue = ref.read(queueProvider);
    if (index < 0 || index >= queue.length) return;
    final song = queue[index];

    // Set providers immediately for UI updates
    ref.read(queueIndexProvider.notifier).state = index;
    ref.read(currentlyPlayingIdProvider.notifier).state = song.id;

    final player = ref.read(audioPlayerProvider);
    await player.setAudioSource(AudioSource.uri(Uri.parse(song.streamUrl)));
    await player.play();
    ref.read(isPlayingProvider.notifier).state = true;
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }
}

class _ThinTrackShape extends SliderTrackShape {
  final double activeThickness;
  final double inactiveThickness;

  const _ThinTrackShape({this.activeThickness = 3, this.inactiveThickness = 1});

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
    Offset offset = Offset.zero,
  }) {
    final double trackHeight = activeThickness > inactiveThickness
        ? activeThickness
        : inactiveThickness;
    final double thumbWidth =
        sliderTheme.thumbShape?.getPreferredSize(isEnabled, isDiscrete).width ??
        0;
    final double trackLeft = offset.dx + thumbWidth / 2;
    final double trackRight = parentBox.size.width - thumbWidth / 2;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    return Rect.fromLTWH(
      trackLeft,
      trackTop,
      trackRight - trackLeft,
      trackHeight,
    );
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    bool isDiscrete = false,
    bool isEnabled = false,
    TextDirection textDirection = TextDirection.ltr,
    Offset? secondaryOffset,
  }) {
    final Canvas canvas = context.canvas;
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
      offset: offset,
    );

    final Color activeColor = sliderTheme.activeTrackColor!;
    final Color inactiveColor = sliderTheme.inactiveTrackColor!;

    final bool ltr = textDirection == TextDirection.ltr;
    final Rect leftRect = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx,
      trackRect.bottom,
    );
    final Rect rightRect = Rect.fromLTRB(
      thumbCenter.dx,
      trackRect.top,
      trackRect.right,
      trackRect.bottom,
    );

    final double activeTop = trackRect.center.dy - activeThickness / 2;
    final double inactiveTop = trackRect.center.dy - inactiveThickness / 2;

    final RRect activeRRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        (ltr ? leftRect.left : rightRect.left),
        activeTop,
        (ltr ? leftRect.right : rightRect.right),
        activeTop + activeThickness,
      ),
      Radius.circular(activeThickness / 2),
    );

    final RRect inactiveRRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        (ltr ? rightRect.left : leftRect.left),
        inactiveTop,
        (ltr ? rightRect.right : leftRect.right),
        inactiveTop + inactiveThickness,
      ),
      Radius.circular(inactiveThickness / 2),
    );

    final Paint activePaint = Paint()..color = activeColor;
    final Paint inactivePaint = Paint()..color = inactiveColor;

    canvas.drawRRect(activeRRect, activePaint);
    canvas.drawRRect(inactiveRRect, inactivePaint);
  }
}
