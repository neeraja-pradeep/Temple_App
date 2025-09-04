import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shimmer/shimmer.dart';
import 'package:temple/core/app_colors.dart';
import 'package:temple/features/home/providers/home_providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();

  static Widget buildDrawerContent(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return profileAsync.when(
      data: (profile) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30.w,
                  ),
                  SizedBox(width: 20.w,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("നമസ്കാരം",
                      style: TextStyle(
                        fontFamily: "NotoSansMalayalam",
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold
                      ),),
                      Text(profile.name, 
                      style: TextStyle(
                        fontFamily: "NotoSansMalayalam",
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w300
                      )),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 15.h,),
              Text("അക്കൗണ്ട് സെറ്റിംഗ്സ്", style: TextStyle( fontSize: 16.sp, fontFamily: "NotoSansMalayalam", fontWeight: FontWeight.w500), ),
              SizedBox(height: 6.h,),
              Divider(color: Colors.grey,),
              SizedBox(height: 6.h,),

              Text("ഹോം സ്ക്രീൻ", style: TextStyle( fontSize: 16.sp, fontFamily: "NotoSansMalayalam", fontWeight: FontWeight.w500),),
              Text("ദൈനംദിന പൂജ സമയങ്ങൾ", style: TextStyle( fontSize: 16.sp, fontFamily: "NotoSansMalayalam", fontWeight: FontWeight.w500),),
              Text("ക്ഷേത്ര ചടങ്ങുകൾ", style: TextStyle( fontSize: 16.sp, fontFamily: "NotoSansMalayalam", fontWeight: FontWeight.w500),),
              SizedBox(height: 6.h,),
              Divider(color: Colors.grey,),
              SizedBox(height: 6.h,),

              Text("പൂജ ബുക്ക് ചെയ്യുക", style: TextStyle( fontSize: 16.sp, fontFamily: "NotoSansMalayalam", fontWeight: FontWeight.w500),),
              Text("പ്രസാദം വാങ്ങുക", style: TextStyle( fontSize: 16.sp, fontFamily: "NotoSansMalayalam", fontWeight: FontWeight.w500),),
              Text("സംഭാവന ചെയ്യുക വിപണി", style: TextStyle( fontSize: 16.sp, fontFamily: "NotoSansMalayalam", fontWeight: FontWeight.w500),),
              SizedBox(height: 6.h,),
              Divider(color: Colors.grey,),
              SizedBox(height: 6.h,),

              Text("പൗർണമി / അമാവാസ്യാ ദിവസം ", style: TextStyle( fontSize: 16.sp, fontFamily: "NotoSansMalayalam", fontWeight: FontWeight.w500),),
              Text("ഉത്സവങ്ങൾ", style: TextStyle( fontSize: 16.sp, fontFamily: "NotoSansMalayalam", fontWeight: FontWeight.w500),),
              Text("ഇന്ന് രാഹുകാലം", style: TextStyle( fontSize: 16.sp, fontFamily: "NotoSansMalayalam", fontWeight: FontWeight.w500),),
              Text("നക്ഷത്രം / ജാതകം (ഐച്ഛികം)", style: TextStyle( fontSize: 16.sp, fontFamily: "NotoSansMalayalam", fontWeight: FontWeight.w500),),
              SizedBox(height: 6.h,),
              Divider(color: Colors.grey,),
              SizedBox(height: 6.h,),

              Text("ഞങ്ങളെ ബന്ധപ്പെടുക", style: TextStyle( fontSize: 16.sp, fontFamily: "NotoSansMalayalam", fontWeight: FontWeight.w300),),
              Text("ക്ഷേത്രം വിവരങ്ങൾ", style: TextStyle( fontSize: 16.sp, fontFamily: "NotoSansMalayalam", fontWeight: FontWeight.w300),),
              
              
            ],
          ),
        );
      },
      error: (err, _) => const Text(""),
      loading: () =>const Text(""),
    );
  }
}

class _HomePageState extends ConsumerState<HomePage> {
  late final AudioPlayer player;

  @override
  void initState() {
    super.initState();
    player = ref.read(audioPlayerProvider);

    player.playerStateStream.listen((state) {
      ref.read(isPlayingProvider.notifier).state = state.playing;
    });
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
                  category.homemediaUrl ?? "",
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
                data: (song) => IconButton(
                  onPressed: () async {
                    if (isPlaying) {
                      await player.pause();
                    } else {
                      if (player.audioSource == null ||
                          (player.audioSource is ProgressiveAudioSource &&
                              (player.audioSource as ProgressiveAudioSource)
                                      .uri
                                      .toString() !=
                                  song.streamUrl)) {
                        await player.setUrl(song.streamUrl);
                      }
                      await player.play();
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
                ),
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
