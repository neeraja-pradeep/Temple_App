import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/home_providers.dart';
import '../data/models/home_pooja_category_model.dart';
import '../services/audio_service.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // Initialize audio when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAudio();
    });
  }

  @override
  void dispose() {
    // Stop audio when leaving the home page
    final audioService = ref.read(audioServiceProvider.notifier);
    audioService.stop();
    super.dispose();
  }

  void _initializeAudio() {
    final songAsync = ref.read(songProvider);
    final audioService = ref.read(audioServiceProvider.notifier);

    songAsync.when(
      data: (songResponse) {
        audioService.playBackgroundMusic(songResponse.song.streamUrl);
      },
      loading: () {
        // Song is loading
      },
      error: (error, stackTrace) {
        print('Error loading song: $error');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(homePoojaCategoriesProvider);
    final profileAsync = ref.watch(profileProvider);
    final audioState = ref.watch(audioServiceProvider);
    final audioService = ref.read(audioServiceProvider.notifier);

    return WillPopScope(
      onWillPop: () async {
        // Stop audio when navigating back
        final audioService = ref.read(audioServiceProvider.notifier);
        audioService.stop();
        return true;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // Full screen cards - no background needed
            categoriesAsync.when(
              data: (categoryResponse) {
                if (categoryResponse.results.isEmpty) {
                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black,
                    child: const Center(
                      child: Text(
                        'No categories available',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }

                return PageView.builder(
                  itemCount: categoryResponse.results.length,
                  itemBuilder: (context, index) {
                    final category = categoryResponse.results[index];
                    return _buildCategoryCard(category, context);
                  },
                );
              },
              loading: () => _buildLoadingCards(),
              error: (error, stackTrace) => Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 48.sp,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Failed to load categories',
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        error.toString(),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Top bar with hamburger menu and bell icon
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Hamburger menu
                      GestureDetector(
                        onTap: () {
                          // TODO: Implement drawer/sidebar
                          Scaffold.of(context).openDrawer();
                        },
                        child: Container(
                          width: 40.w,
                          height: 40.h,
                          child: Image.asset(
                            'assets/menu.png',
                            width: 24.w,
                            height: 24.h,
                          ),
                        ),
                      ),

                      // Center - Malayalam date and nakshatram
                      Expanded(
                        child: profileAsync.when(
                          data: (profileResponse) {
                            final profile = profileResponse.profile;
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Malayalam date
                                Text(
                                  profile.malayalamDate,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'NotoSansMalayalam',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 2.h),
                                // Nakshatram
                                Text(
                                  profile.nakshatram.name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'NotoSansMalayalam',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            );
                          },
                          loading: () => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 80.w,
                                height: 14.h,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Container(
                                width: 60.w,
                                height: 12.h,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              ),
                            ],
                          ),
                          error: (error, stackTrace) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Date Loading...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Bell icon
                      GestureDetector(
                        onTap: () {
                          // TODO: Implement notifications
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notifications coming soon!'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        },
                        child: Container(
                          width: 40.w,
                          height: 40.h,
                          child: Image.asset(
                            'assets/bell.png',
                            width: 24.w,
                            height: 24.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Speaker icon in bottom left
            Positioned(
              bottom: 30.h,
              left: 20.w,
              child: GestureDetector(
                onTap: () {
                  audioService.toggleMute();
                },
                child: Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(25.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    audioState.isMuted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(HomePoojaCategory category, BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(),
      child: Stack(
        children: [
          // Background image - full screen
          Positioned.fill(
            child: Image.network(
              category.homeMediaUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Shimmer.fromColors(
                  baseColor: Colors.grey[800]!,
                  highlightColor: Colors.grey[600]!,
                  child: Container(color: Colors.grey[800]),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.white54,
                      size: 48,
                    ),
                  ),
                );
              },
            ),
          ),

          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),

          // Category name

          // Tap to explore
        ],
      ),
    );
  }

  Widget _buildLoadingCards() {
    return PageView.builder(
      itemCount: 3, // Show 3 loading cards
      itemBuilder: (context, index) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(color: Colors.grey[800]),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[800]!,
            highlightColor: Colors.grey[600]!,
            child: Container(
              decoration: BoxDecoration(color: Colors.grey[800]),
            ),
          ),
        );
      },
    );
  }
}
