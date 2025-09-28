import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shimmer/shimmer.dart';
import 'package:temple_app/core/app_colors.dart';
import 'package:temple_app/features/home/providers/home_providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();

  static Widget buildDrawerContent(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return profileAsync.when(
      data: (profile) {
        // Print profile details to console when drawer is opened
        print('=== PROFILE DETAILS FROM DRAWER ===');
        print('Name: ${profile.name}');
        print('Phone: ${profile.phone}');
        print('Email: ${profile.email}');
        print('Date of Birth: ${profile.dob}');
        print('Time: ${profile.time}');
        print('Nakshatram: ${profile.nakshatram}');
        print('Malayalam Date: ${profile.malayalamDate}');
        print('=== END PROFILE DETAILS ===');

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFDF8EF), // rgba(253, 248, 239, 1)
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20.r),
              bottomRight: Radius.circular(20.r),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section with greeting and user info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.h),
                    Text(
                      "നമസ്കാരം",
                      style: TextStyle(
                        fontFamily: "NotoSansMalayalam",
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600, // semibold
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      profile.name,
                      style: TextStyle(
                        fontFamily: "NotoSansMalayalam",
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w300,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      profile.nakshatram,
                      style: TextStyle(
                        fontFamily: "NotoSansMalayalam",
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w300,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // Divider
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Container(height: 1.h, color: Colors.grey.shade300),
                ),

                SizedBox(height: 20.h),

                // Main menu items
                Expanded(
                  child: Column(
                    children: [
                      _buildMenuItem("Pooja Booking", () {}),
                      SizedBox(height: 12.h),
                      _buildMenuItem("Store Orders", () {}),
                      SizedBox(height: 12.h),
                      _buildMenuItem("Saved members list", () {}),
                      SizedBox(height: 12.h),
                      _buildMenuItem("Saved Addresses", () {}),

                      SizedBox(height: 20.h),

                      // Divider after the four main items
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Container(
                          height: 1.h,
                          color: Colors.grey.shade300,
                        ),
                      ),

                      const Spacer(),

                      // Bottom menu items at the very bottom
                      _buildMenuItem(
                        "Contact Us",
                        () {},
                        fontWeight: FontWeight.w400,
                      ),
                      SizedBox(height: 12.h),
                      _buildMenuItem("Log out", () {
                        // Add logout functionality here
                        Navigator.of(context).pushReplacementNamed('/login');
                      }, fontWeight: FontWeight.w700),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      error: (err, _) => Container(
        padding: EdgeInsets.all(20.w),
        child: Text(
          "Error loading profile",
          style: TextStyle(fontSize: 16.sp, color: Colors.red),
        ),
      ),
      loading: () => Container(
        padding: EdgeInsets.all(20.w),
        child: const CircularProgressIndicator(),
      ),
    );
  }

  static Widget _buildMenuItem(
    String title,
    VoidCallback onTap, {
    FontWeight? fontWeight,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: fontWeight ?? FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver {
  late final AudioPlayer player;
  late final StreamSubscription<PlayerState> _playerSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    player = ref.read(audioPlayerProvider);

    _playerSub = player.playerStateStream.listen(
      (state) {
        ref.read(isPlayingProvider.notifier).state = state.playing;
      },
      onError: (error) {
        print('❌ Audio player state error: $error');
        ref.read(isPlayingProvider.notifier).state = false;
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      player.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _playerSub.cancel(); // cancel stream
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final godCategories = ref.watch(godCategoriesProvider);
    final profileAsync = ref.watch(profileProvider);
    final isPlaying = ref.watch(isPlayingProvider);
    final musicAsync = ref.watch(songProvider);

    return godCategories.when(
      data: (categories) {
        if (categories.isEmpty) return const Center(child: Text("ERROR"));

        return Stack(
          fit: StackFit.expand,
          children: [
            // PageView carousel
            PageView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Image.network(
                  _ensureHttps(category.homemediaUrl),
                  fit: BoxFit.cover,
                  errorBuilder: (context, _, __) =>
                      Image.asset("assets/fallBack.png", fit: BoxFit.cover),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _shimmerLoader();
                  },
                );
              },
            ),

            // Drawer button
            Positioned(
              top: 10.h,
              left: 4.w,
              child: IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: Image.asset(
                  "assets/icons/menu.png",
                  height: 24.h,
                  width: 30.w,
                ),
              ),
            ),

            // Notifications
            Positioned(
              top: 10.h,
              right: 5.w,
              child: IconButton(
                onPressed: () {},
                icon: Image.asset(
                  "assets/icons/bell.png",
                  height: 24.h,
                  width: 21.76.w,
                ),
              ),
            ),

            // Profile
            Positioned(
              top: 15.h,
              right: 110.w,
              child: profileAsync.when(
                data: (profile) {
                  final formatted = formatMalayalamDate(profile.malayalamDate);
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        formatted,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: "NotoSansMalayalam",
                        ),
                      ),
                      Text(
                        profile.nakshatram,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                          fontFamily: "NotoSansMalayalam",
                        ),
                      ),
                    ],
                  );
                },
                error: (err, _) => const Text("നമസ്കാരം"),
                loading: () => const Text("നമസ്കാരം"),
              ),
            ),

            // song
            Positioned(
              bottom: 10.h,
              left: 5.w,
              child: musicAsync.when(
                data: (song) {
                  print('🎵 Song data received: ${song.streamUrl}');
                  return IconButton(
                    onPressed: () async {
                      try {
                        if (isPlaying) {
                          await player.pause();
                        } else {
                          // Validate URL before setting
                          print('🎵 Attempting to play: ${song.streamUrl}');
                          if (song.streamUrl.isNotEmpty &&
                              Uri.tryParse(song.streamUrl) != null) {
                            // Convert HTTP to HTTPS for better security
                            String audioUrl = song.streamUrl;
                            if (audioUrl.startsWith('http://')) {
                              audioUrl = audioUrl.replaceFirst(
                                'http://',
                                'https://',
                              );
                              print('🔄 Converted HTTP to HTTPS: $audioUrl');
                            }

                            if (player.audioSource == null ||
                                (player.audioSource is ProgressiveAudioSource &&
                                    (player.audioSource
                                                as ProgressiveAudioSource)
                                            .uri
                                            .toString() !=
                                        audioUrl)) {
                              await player.setUrl(audioUrl);
                            }
                            await player.play();
                          } else {
                            print('❌ Invalid audio URL: ${song.streamUrl}');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Invalid audio URL'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        print('❌ Audio playback error: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Audio playback failed: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: isPlaying
                        ? Image.asset(
                            "assets/icons/sound.png",
                            height: 24.h,
                            width: 29.76.w,
                          )
                        : Image.asset(
                            "assets/icons/mute.png",
                            color: const Color.fromARGB(154, 255, 255, 255),
                            height: 24.h,
                            width: 29.76.w,
                          ),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Icon(Icons.error),
              ),
            ),
          ],
        );
      },
      loading: () => _shimmerLoader(),
      error: (err, _) => const Center(child: Text("ERROR")),
    );
  }

  Widget _shimmerLoader() {
    return Shimmer.fromColors(
      baseColor: AppColors.navBarBackground.withOpacity(0.8),
      highlightColor: Colors.white.withOpacity(0.8),
      child: Container(color: AppColors.navBarBackground),
    );
  }

  String _ensureHttps(String? url) {
    if (url == null || url.trim().isEmpty) return "";
    final trimmed = url.trim();
    if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
      return trimmed;
    }
    return "https://$trimmed";
  }

  String formatMalayalamDate(String rawDate) {
    final parts = rawDate.split(',');
    if (parts.length < 2) return rawDate;

    final weekday = parts[0].trim();
    final rest = parts[1].trim();

    final restParts = rest.split(' ');
    if (restParts.length < 2) return rawDate;

    final day = restParts[0];
    final month = restParts[1];

    return "$month $day, $weekday";
  }
}
