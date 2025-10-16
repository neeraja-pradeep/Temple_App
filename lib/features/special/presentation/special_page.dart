import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:temple_app/core/app_colors.dart';
import '../providers/special_pooja_provider.dart';
import '../data/special_pooja_model.dart';
import '../../booking/presentation/booking_page.dart';
import 'dart:async';
import '../../booking/providers/booking_page_providers.dart';

// Provider for managing selected card across both sections
final selectedCardProvider = StateProvider<SpecialPooja?>((ref) => null);

// Section-specific selection providers
final selectedWeeklyPoojaProvider = StateProvider<SpecialPooja?>((ref) => null);
final selectedSpecialPoojaProvider = StateProvider<SpecialPooja?>(
  (ref) => null,
);

class SpecialPage extends ConsumerStatefulWidget {
  const SpecialPage({super.key});

  @override
  ConsumerState<SpecialPage> createState() => _SpecialPageState();
}

class _SpecialPageState extends ConsumerState<SpecialPage> {
  late final PageController _pageController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final currentPage = ref.read(specialBannerPageProvider);
    _pageController = PageController(
      viewportFraction: 1.0, // Only one banner fully visible
      initialPage: currentPage,
    );
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      final poojas = ref
          .read(specialPoojasProvider)
          .maybeWhen(data: (poojas) => poojas, orElse: () => []);
      if (poojas.isEmpty) return;
      final nextPage = (_pageController.page?.round() ?? 0) + 1;
      if (nextPage < poojas.length) {
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        ref.read(specialBannerPageProvider.notifier).state = nextPage;
      } else {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        ref.read(specialBannerPageProvider.notifier).state = 0;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh(WidgetRef ref) async {
    ref.invalidate(specialPoojasProvider);
    ref.invalidate(weeklyPoojasProvider);
    ref.invalidate(specialPrayersProvider);
  }

  @override
  Widget build(BuildContext context) {
    final asyncPoojas = ref.watch(specialPoojasProvider);
    final cachedPoojas = ref.watch(specialPoojasCacheProvider);
    final asyncWeeklyPoojas = ref.watch(weeklyPoojasProvider);
    final cachedWeeklyPoojas = ref.watch(weeklyPoojasCacheProvider);
    final asyncSpecialPrayers = ref.watch(specialPrayersProvider);
    final cachedSpecialPrayers = ref.watch(specialPrayersCacheProvider);
    final currentPage = ref.watch(specialBannerPageProvider);

    // If the number of poojas changes, restart the timer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timer?.cancel();
      _startAutoScroll();
    });

    return _buildPage(
      context,
      ref,
      asyncPoojas,
      cachedPoojas,
      asyncWeeklyPoojas,
      cachedWeeklyPoojas,
      asyncSpecialPrayers,
      cachedSpecialPrayers,
      _pageController,
      currentPage,
    );
  }

  Widget _buildPage(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<SpecialPooja>> asyncPoojas,
    AsyncValue<List<SpecialPooja>> cachedPoojas,
    AsyncValue<List<SpecialPooja>> asyncWeeklyPoojas,
    AsyncValue<List<SpecialPooja>> cachedWeeklyPoojas,
    AsyncValue<List<SpecialPooja>> asyncSpecialPrayers,
    AsyncValue<List<SpecialPooja>> cachedSpecialPrayers,
    PageController pageController,
    int currentPage,
  ) {
    final selectedCard = ref.watch(selectedCardProvider);

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () => _onRefresh(ref),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Banner Section - Independent loading/error handling
                _buildBannerSection(
                  context,
                  ref,
                  asyncPoojas,
                  cachedPoojas,
                  pageController,
                  currentPage,
                ),

                // 2. Today's Prayers Section - Independent loading/error handling
                _buildWeeklyPoojasSection(
                  context,
                  ref,
                  asyncWeeklyPoojas,
                  cachedWeeklyPoojas,
                ),

                // 3. Today's Special Section - Independent loading/error handling
                _buildSpecialPrayersSection(
                  context,
                  ref,
                  asyncSpecialPrayers,
                  cachedSpecialPrayers,
                ),
                if (selectedCard != null) SizedBox(height: 50.h),
              ],
            ),
          ),
        ),
        // Fixed Book button at bottom
        if (selectedCard != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8.r,
                      offset: Offset(0, -2.h),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: 342.w,
                  height: 40.h,
                  child: ElevatedButton(
                    onPressed: () {
                      // Clear date-related booking state before entering booking
                      try {
                        ref.read(selectedCalendarDateProvider.notifier).state =
                            null;
                      } catch (_) {}
                      try {
                        ref.read(showCalendarProvider.notifier).state = false;
                      } catch (_) {}
                      // Navigate to booking page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingPage(
                            poojaId: selectedCard.id,
                            userId: 2,
                            source:
                                'special', // Indicate this is from SpecialPage
                            malayalamDate:
                                null, // No Malayalam date needed for SpecialPage
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.selected,
                      foregroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'ബുക്ക്',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // 1. Banner Section - Independent loading/error handling
  Widget _buildBannerSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<SpecialPooja>> asyncPoojas,
    AsyncValue<List<SpecialPooja>> cachedPoojas,
    PageController pageController,
    int currentPage,
  ) {
    return asyncPoojas.when(
      data: (poojas) {
        if (poojas.isEmpty) {
          return cachedPoojas.when(
            data: (cache) => cache.isEmpty
                ? _buildBannerErrorWidget('No special poojas available.')
                : _buildBannerContent(
                    context,
                    ref,
                    cache,
                    pageController,
                    currentPage,
                  ),
            loading: () => _buildBannerSkeleton(),
            error: (e, st) =>
                _buildBannerErrorWidget('Unable to load special poojas'),
          );
        }
        return _buildBannerContent(
          context,
          ref,
          poojas,
          pageController,
          currentPage,
        );
      },
      loading: () => _buildBannerSkeleton(),
      error: (e, st) {
        return cachedPoojas.when(
          data: (cache) => cache.isEmpty
              ? _buildBannerErrorWidget('Unable to load special poojas')
              : _buildBannerContent(
                  context,
                  ref,
                  cache,
                  pageController,
                  currentPage,
                ),
          loading: () => _buildBannerSkeleton(),
          error: (e, st) =>
              _buildBannerErrorWidget('Unable to load special poojas'),
        );
      },
    );
  }

  // 2. Weekly Poojas Section - Independent loading/error handling
  Widget _buildWeeklyPoojasSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<SpecialPooja>> asyncWeeklyPoojas,
    AsyncValue<List<SpecialPooja>> cachedWeeklyPoojas,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          Text(
            "ഇന്നത്തെ പൂജകൾ",
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          asyncWeeklyPoojas.when(
            data: (poojas) {
              if (poojas.isEmpty) {
                return cachedWeeklyPoojas.when(
                  data: (cache) => cache.isEmpty
                      ? _buildWeeklyPoojasErrorWidget('No prayers available.')
                      : _buildWeeklyPoojasList(context, ref, cache, null),
                  loading: () => _buildWeeklyPoojasSkeleton(),
                  error: (e, st) =>
                      _buildWeeklyPoojasErrorWidget('Unable to load prayers'),
                );
              }
              return _buildWeeklyPoojasList(
                context,
                ref,
                poojas,
                cachedWeeklyPoojas,
              );
            },
            loading: () => _buildWeeklyPoojasSkeleton(),
            error: (e, st) {
              return cachedWeeklyPoojas.when(
                data: (cache) => cache.isEmpty
                    ? _buildWeeklyPoojasErrorWidget('Unable to load prayers')
                    : _buildWeeklyPoojasList(context, ref, cache, null),
                loading: () => _buildWeeklyPoojasSkeleton(),
                error: (e, st) =>
                    _buildWeeklyPoojasErrorWidget('Unable to load prayers'),
              );
            },
          ),
        ],
      ),
    );
  }

  // 3. Special Prayers Section - Independent loading/error handling
  Widget _buildSpecialPrayersSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<SpecialPooja>> asyncSpecialPrayers,
    AsyncValue<List<SpecialPooja>> cachedSpecialPrayers,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h, left: 16.w, right: 16.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 24.h),
          Text(
            "പ്രത്യേക പൂജകൾ",
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
          ),
          asyncSpecialPrayers.when(
            data: (prayers) {
              if (prayers.isEmpty) {
                return cachedSpecialPrayers.when(
                  data: (cache) => cache.isEmpty
                      ? _buildSpecialPrayersErrorWidget(
                          'No special prayers available.',
                        )
                      : _buildSpecialPrayersGrid(context, ref, cache, null),
                  loading: () => _buildSpecialPrayersSkeleton(),
                  error: (e, st) => _buildSpecialPrayersErrorWidget(
                    'Unable to load special prayers',
                  ),
                );
              }
              return _buildSpecialPrayersGrid(
                context,
                ref,
                prayers,
                cachedSpecialPrayers,
              );
            },
            loading: () => _buildSpecialPrayersSkeleton(),
            error: (e, st) {
              return cachedSpecialPrayers.when(
                data: (cache) => cache.isEmpty
                    ? _buildSpecialPrayersErrorWidget(
                        'Unable to load special prayers',
                      )
                    : _buildSpecialPrayersGrid(context, ref, cache, null),
                loading: () => _buildSpecialPrayersSkeleton(),
                error: (e, st) => _buildSpecialPrayersErrorWidget(
                  'Unable to load special prayers',
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPoojasList(
    BuildContext context,
    WidgetRef ref,
    List<SpecialPooja> poojas,
    AsyncValue<List<SpecialPooja>>? cachedWeeklyPoojas,
  ) {
    return SizedBox(
      height: 190.h,

      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: poojas.length,
        separatorBuilder: (context, i) =>
            SizedBox(width: 11.w), // spacing between cards
        itemBuilder: (context, index) {
          final pooja = poojas[index];
          final isSelected =
              ref.watch(selectedWeeklyPoojaProvider)?.id == pooja.id;
          return GestureDetector(
            onTap: () {
              // Clear other section selection first
              ref.read(selectedSpecialPoojaProvider.notifier).state = null;
              // Set this section selection
              ref.read(selectedWeeklyPoojaProvider.notifier).state = isSelected
                  ? null
                  : pooja;
              // Update main selection provider
              ref.read(selectedCardProvider.notifier).state = isSelected
                  ? null
                  : pooja;
            },
            child: Container(
              width: 150.w,
              height: 220.h, // card width
              margin: EdgeInsets.only(bottom: 6.h), // Add space for shadow
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: isSelected
                      ? Border.all(color: AppColors.selected, width: 2.w)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        0.1,
                      ), // Increased shadow opacity
                      blurRadius: 6.r, // Increased blur radius
                      offset: Offset(0.w, 1.h), // Increased offset
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.network(
                              _normalizeImageUrl(pooja.mediaUrl),
                              width: 134.w,
                              height: 80.h,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return _buildShimmerBox(134.w, 80.h, 8.r);
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    width: 134.w,
                                    height: 80.h,
                                    child: const Icon(Icons.broken_image),
                                  ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            pooja.name,
                            style: TextStyle(
                              fontFamily: 'NotoSansMalayalam',
                              fontWeight: FontWeight.w700,
                              fontSize: 12.sp,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          // SizedBox(height: 4.h),
                          Text(
                            pooja.categoryName,
                            style: TextStyle(
                              fontFamily: 'NotoSansMalayalam',
                              fontWeight: FontWeight.w500,
                              fontSize: 12.sp,
                              color: Colors.grey[700],
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                      Text(
                        '₹${pooja.price}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpecialPrayersGrid(
    BuildContext context,
    WidgetRef ref,
    List<SpecialPooja> prayers,
    AsyncValue<List<SpecialPooja>>? cachedSpecialPrayers,
  ) {
    return GridView.builder(
      padding: EdgeInsets.only(top: 14),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16.h,
        crossAxisSpacing: 16.w,
        mainAxisExtent: 200.h,
      ),
      itemCount: prayers.length,
      itemBuilder: (context, index) {
        final pooja = prayers[index];
        final isSelected =
            ref.watch(selectedSpecialPoojaProvider)?.id == pooja.id;
        return GestureDetector(
          onTap: () {
            // Clear other section selection first
            ref.read(selectedWeeklyPoojaProvider.notifier).state = null;
            // Set this section selection
            ref.read(selectedSpecialPoojaProvider.notifier).state = isSelected
                ? null
                : pooja;
            // Update main selection provider
            ref.read(selectedCardProvider.notifier).state = isSelected
                ? null
                : pooja;
          },
          child: Container(
            width: 163.w,
            height: 200.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: isSelected
                  ? Border.all(color: AppColors.selected, width: 2.w)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 16.r,
                  offset: Offset(0, 6.h),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      _normalizeImageUrl(pooja.mediaUrl),
                      width: 146.w,
                      height: 80.h,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return _buildShimmerBox(146.w, 80.h, 8.r);
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        width: 146.w,
                        height: 80.h,
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.w, right: 8.w, top: 8.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pooja.name,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              // SizedBox(height: 4.h),
                              Text(
                                pooja.categoryName,
                                style: TextStyle(
                                  fontFamily: 'NotoSansMalayalam',
                                  fontSize: 12.sp,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                          Text(
                            '₹${pooja.price}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper methods for Banner Section
  Widget _buildBannerContent(
    BuildContext context,
    WidgetRef ref,
    List<SpecialPooja> poojas,
    PageController pageController,
    int currentPage,
  ) {
    return Column(
      children: [
        SizedBox(height: 50.h),
        SizedBox(
          width: 343.w,
          height: 142.h,
          child: PageView.builder(
            itemCount: poojas.length,
            controller: pageController,
            onPageChanged: (i) =>
                ref.read(specialBannerPageProvider.notifier).state = i,
            itemBuilder: (context, index) {
              final pooja = poojas[index];
              final date = pooja.specialPoojaDates.isNotEmpty
                  ? (pooja.specialPoojaDates.first.date.isNotEmpty
                        ? pooja.specialPoojaDates.first.date
                        : pooja.specialPoojaDates.first.malayalamDate)
                  : '';
              return Container(
                height: 142.h,
                margin: EdgeInsets.only(
                  top: 0.h,
                  bottom: 12.h,
                  left: 8.w,
                  right: 8.w,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 4.r,
                      offset: Offset(0.w, 4.h),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.network(
                        _normalizeImageUrl(pooja.bannerUrl),
                        width: 343.w,
                        height: 142.h,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return _buildShimmerBox(343.w, 142.h, 8.r);
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey,
                          width: 343.w,
                          height: 142.h,
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12.w,
                      top: 12.h,
                      right: 12.w,
                      bottom: 12.h,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pooja.name,
                                style: TextStyle(
                                  fontFamily: 'NotoSansMalayalam',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20.sp,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 6.r,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                pooja.categoryName,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.4),
                                      blurRadius: 4.r,
                                    ),
                                  ],
                                ),
                              ),
                              if (pooja.captionsDesc.isNotEmpty) ...[
                                SizedBox(height: 4.h),
                                Text(
                                  pooja.captionsDesc,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 3.r,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (date.isNotEmpty) ...[
                            Text(
                              date,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 3.r,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Only show dots if there are more than 1 banner
        if (poojas.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(poojas.length > 3 ? 3 : poojas.length, (
              index,
            ) {
              final int dotCount = poojas.length > 3 ? 3 : poojas.length;
              final bool isActive = (currentPage % dotCount) == index;
              return AnimatedContainer(
                duration: Duration(milliseconds: 200),
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: isActive ? 35.w : 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.selected : AppColors.unselected,
                  borderRadius: BorderRadius.circular(12.w),
                ),
              );
            }),
          ),
      ],
    );
  }

  Widget _buildBannerSkeleton() {
    return Column(
      children: [
        SizedBox(height: 50.h),
        Container(
          width: 343.w,
          height: 142.h,
          margin: EdgeInsets.only(
            top: 0.h,
            bottom: 12.h,
            left: 8.w,
            right: 8.w,
          ),
          child: _buildShimmerBox(343.w, 142.h, 8.r),
        ),
        // Show 3 dots in skeleton loading state
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (index) => Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.w),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerErrorWidget(String message) {
    return Column(
      children: [
        SizedBox(height: 50.h),
        Container(
          width: 343.w,
          height: 142.h,
          margin: EdgeInsets.only(
            top: 0.h,
            bottom: 12.h,
            left: 8.w,
            right: 8.w,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.grey[600], size: 32.sp),
                SizedBox(height: 8.h),
                Text(
                  message,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods for Weekly Poojas Section
  Widget _buildWeeklyPoojasSkeleton() {
    return SizedBox(
      height: 190.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (context, i) => SizedBox(width: 11.w),
        itemBuilder: (context, index) {
          return _buildPoojaCardShimmer(
            width: 150.w,
            height: 220.h,
            imageHeight: 80.h,
            radius: 12.r,
            padding: 8.0,
          );
        },
      ),
    );
  }

  Widget _buildWeeklyPoojasErrorWidget(String message) {
    return SizedBox(
      height: 190.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.grey[600], size: 32.sp),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for Special Prayers Section
  Widget _buildSpecialPrayersSkeleton() {
    return GridView.builder(
      padding: EdgeInsets.only(top: 14),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16.h,
        crossAxisSpacing: 16.w,
        mainAxisExtent: 200.h,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return _buildPoojaCardShimmer(
          width: 163.w,
          height: 200.h,
          imageHeight: 80.h,
          radius: 12.r,
          padding: 8.0,
        );
      },
    );
  }

  Widget _buildSpecialPrayersErrorWidget(String message) {
    return SizedBox(
      height: 200.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.grey[600], size: 32.sp),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Ensures image URLs have a scheme; defaults to https
String _normalizeImageUrl(String url) {
  final String trimmed = (url).trim();
  if (trimmed.isEmpty) return trimmed;
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  return 'https://$trimmed';
}

// Shimmer placeholder box
Widget _buildShimmerBox(double width, double height, double radius) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    ),
  );
}

// Reusable shimmer skeleton matching the pooja card layout
Widget _buildPoojaCardShimmer({
  required double width,
  required double height,
  required double imageHeight,
  required double radius,
  required double padding,
}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Container(
      width: width,
      height: height,
      margin: EdgeInsets.only(bottom: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image placeholder
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    width: width - (padding * 2),
                    height: imageHeight,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                // Title line
                Container(
                  width: width * 0.7,
                  height: 12.h,
                  color: Colors.white,
                ),
                SizedBox(height: 6.h),
                // Subtitle line
                Container(
                  width: width * 0.5,
                  height: 12.h,
                  color: Colors.white,
                ),
              ],
            ),
            // Price line
            Container(width: width * 0.3, height: 14.h, color: Colors.white),
          ],
        ),
      ),
    ),
  );
}
