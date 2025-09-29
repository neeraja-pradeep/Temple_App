import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shimmer/shimmer.dart';
import 'package:temple_app/core/app_colors.dart';
import 'package:temple_app/core/services/fcm_token_service.dart';
import 'package:temple_app/core/services/logout_service.dart';
import 'package:temple_app/core/theme/color/colors.dart';
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
                        _handleLogout(context, ref);
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
          style: TextStyle(fontSize: 16.sp, color: primaryThemeColor),
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

  /// Handle user logout
  static Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    try {
      // Show confirmation dialog
      final shouldLogout = await _showLogoutConfirmationDialog(context);
      if (!shouldLogout) return;

      // Show loading indicator
      _showLogoutLoadingDialog(context);

      // Get user info before logout (for debugging)
      final userInfo = LogoutService.getUserInfoBeforeLogout();
      print('=== USER INFO BEFORE LOGOUT ===');
      print('User ID: ${userInfo['userId']}');
      print('Phone: ${userInfo['phoneNumber']}');
      print('Role: ${userInfo['userRole']}');
      print('Has FCM Token: ${userInfo['hasFcmToken']}');
      print('Is Authenticated: ${userInfo['isAuthenticated']}');
      print('=== END USER INFO ===');

      // Perform logout
      final success = await LogoutService.logout(
        ProviderScope.containerOf(context),
      );

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
      }

      if (success) {
        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged out successfully'),
              backgroundColor: primaryThemeColor,
            ),
          );
        }
        // Navigate explicitly to login and clear stack
        if (context.mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      } else {
        // Show error message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logout completed with some issues'),
              backgroundColor: primaryThemeColor,
            ),
          );
        }
        // Navigate to login even if there were issues
        if (context.mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      }
    } catch (e) {
      print('❌ Logout error: $e');

      // Close loading dialog if still open
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: primaryThemeColor,
          ),
        );
      }
    }
  }

  /// Show logout confirmation dialog
  static Future<bool> _showLogoutConfirmationDialog(
    BuildContext context,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Logout'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /// Show logout loading dialog
  static void _showLogoutLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Logging out...'),
            ],
          ),
        );
      },
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

    // Send FCM token to backend when user reaches home page
    _sendFcmTokenToBackend();
  }

  /// Send FCM token to backend after user reaches home page
  Future<void> _sendFcmTokenToBackend() async {
    try {
      print('=== HOME PAGE FCM TOKEN HANDLING ===');
      await FcmTokenService.handleFcmTokenAfterLogin();
      print('=== END HOME PAGE FCM TOKEN HANDLING ===');
    } catch (e) {
      print('❌ Error in home page FCM token handling: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      player.stop();
    }
  }

  @override
  void dispose() {
    player.stop();
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
                                backgroundColor: primaryThemeColor,
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        print('❌ Audio playback error: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Audio playback failed: $e'),
                            backgroundColor: primaryThemeColor,
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
