import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple/core/app_colors.dart';
import 'package:temple/widgets/weekly_pooja_skeleton.dart';
import 'package:temple/widgets/special_page_skeleton.dart';
import '../providers/special_pooja_provider.dart';
import '../data/special_pooja_model.dart';

class SpecialPage extends ConsumerWidget {
  const SpecialPage({super.key});

  Future<void> _onRefresh(WidgetRef ref) async {
    ref.invalidate(specialPoojasProvider);
    ref.invalidate(weeklyPoojasProvider);
    ref.invalidate(specialPrayersProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPoojas = ref.watch(specialPoojasProvider);
    final cachedPoojas = ref.watch(specialPoojasCacheProvider);
    final asyncWeeklyPoojas = ref.watch(weeklyPoojasProvider);
    final cachedWeeklyPoojas = ref.watch(weeklyPoojasCacheProvider);
    final asyncSpecialPrayers = ref.watch(specialPrayersProvider);
    final cachedSpecialPrayers = ref.watch(specialPrayersCacheProvider);
    final currentPage = ref.watch(specialBannerPageProvider);
    final pageController = PageController(
      viewportFraction: 0.9,
      initialPage: currentPage,
    );

    return asyncPoojas.when(
      data: (poojas) {
        if (poojas.isEmpty) {
          return cachedPoojas.when(
            data: (cache) => cache.isEmpty
                ? const Center(child: Text('No special poojas available.'))
                : _buildPage(
                    context,
                    ref,
                    cache,
                    cachedWeeklyPoojas,
                    cachedSpecialPrayers,
                    pageController,
                    currentPage,
                  ),
            loading: () => const SpecialPageSkeleton(),
            error: (e, st) =>
                const Center(child: Text('No special poojas available.')),
          );
        }
        return _buildPage(
          context,
          ref,
          poojas,
          asyncWeeklyPoojas,
          asyncSpecialPrayers,
          pageController,
          currentPage,
        );
      },
      loading: () => const SpecialPageSkeleton(),
      error: (e, st) {
        return cachedPoojas.when(
          data: (cache) => cache.isEmpty
              ? const Center(child: Text('No special poojas available.'))
              : _buildPage(
                  context,
                  ref,
                  cache,
                  cachedWeeklyPoojas,
                  cachedSpecialPrayers,
                  pageController,
                  currentPage,
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) =>
              const Center(child: Text('No special poojas available.')),
        );
      },
    );
  }

  Widget _buildPage(
    BuildContext context,
    WidgetRef ref,
    List<SpecialPooja> poojas,
    AsyncValue<List<SpecialPooja>> weeklyPoojas,
    AsyncValue<List<SpecialPooja>> specialPrayers,
    PageController pageController,
    int currentPage, {
    AsyncValue<List<SpecialPooja>>? cachedWeeklyPoojas,
    AsyncValue<List<SpecialPooja>>? cachedSpecialPrayers,
  }) {
    return RefreshIndicator(
      onRefresh: () => _onRefresh(ref),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Banner Section
            Column(
              children: [
                SizedBox(height: 64.h),
                SizedBox(
                  width: 343.w,
                  height: 142.h,
                  child: PageView.builder(
                    itemCount: poojas.length,
                    controller: PageController(
                      viewportFraction: 1.0,
                      initialPage: currentPage,
                    ),
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
                        width: 343.w,
                        height: 142.h,
                        margin: EdgeInsets.only(
                          top: 0.h,
                          bottom: 12.h,
                          left: 8,
                          right: 8,
                          // Keep bottom margin for shadow
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 16.r,
                              offset: Offset(8.w, 8.h),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Image.network(
                                pooja.bannerUrl,
                                width: 343.w,
                                height: 142.h,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                              color: Colors.black.withOpacity(
                                                0.5,
                                              ),
                                              blurRadius: 6.r,
                                            ),
                                          ],
                                        ),
                                      ),
                                      // SizedBox(height: 4.h),
                                      Text(
                                        pooja.categoryName,
                                        style: TextStyle(
                                          fontSize: 20.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(
                                                0.4,
                                              ),
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
                                                color: Colors.black.withOpacity(
                                                  0.3,
                                                ),
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
                                            color: Colors.black.withOpacity(
                                              0.3,
                                            ),
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
                // SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    poojas.length >= 3 ? poojas.length : 3,
                    (index) => AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      width: currentPage == index ? 35.w : 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: currentPage == index
                            ? AppColors.selected
                            : AppColors.unselected,
                        borderRadius: BorderRadius.circular(12.w),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 2. Today's Prayers Section
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24.h),
                  Text(
                    "ഇന്നത്തെ പൂജകൾ",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  weeklyPoojas.when(
                    data: (poojas) {
                      if (poojas.isEmpty) {
                        return cachedWeeklyPoojas?.when(
                              data: (cache) => cache.isEmpty
                                  ? const Center(
                                      child: Text('No prayers available.'),
                                    )
                                  : _buildWeeklyPoojasList(cache, null),
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              error: (e, st) => const Center(
                                child: Text('No prayers available.'),
                              ),
                            ) ??
                            const Center(child: Text('No prayers available.'));
                      }
                      return _buildWeeklyPoojasList(poojas, cachedWeeklyPoojas);
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, st) {
                      return cachedWeeklyPoojas?.when(
                            data: (cache) => cache.isEmpty
                                ? const Center(
                                    child: Text('No prayers available.'),
                                  )
                                : _buildWeeklyPoojasList(cache, null),
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (e, st) => const Center(
                              child: Text('No prayers available.'),
                            ),
                          ) ??
                          const Center(child: Text('No prayers available.'));
                    },
                  ),
                ],
              ),
            ),

            // 3. Today's Special Section
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 16.w),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 24.h),
                  Text(
                    "പ്രത്യേക പൂജകൾ",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  specialPrayers.when(
                    data: (prayers) {
                      if (prayers.isEmpty) {
                        return cachedSpecialPrayers?.when(
                              data: (cache) => cache.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No special prayers available.',
                                      ),
                                    )
                                  : _buildSpecialPrayersGrid(cache, null),
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              error: (e, st) => const Center(
                                child: Text('No special prayers available.'),
                              ),
                            ) ??
                            const Center(
                              child: Text('No special prayers available.'),
                            );
                      }
                      return _buildSpecialPrayersGrid(
                        prayers,
                        cachedSpecialPrayers,
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, st) {
                      return cachedSpecialPrayers?.when(
                            data: (cache) => cache.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No special prayers available.',
                                    ),
                                  )
                                : _buildSpecialPrayersGrid(cache, null),
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (e, st) => const Center(
                              child: Text('No special prayers available.'),
                            ),
                          ) ??
                          const Center(
                            child: Text('No special prayers available.'),
                          );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyPoojasList(
    List<SpecialPooja> poojas,
    AsyncValue<List<SpecialPooja>>? cachedWeeklyPoojas,
  ) {
    return SizedBox(
      height: 180.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: poojas.length,
        separatorBuilder: (context, i) =>
            SizedBox(width: 11.w), // spacing between cards
        itemBuilder: (context, index) {
          final pooja = poojas[index];
          return Container(
            width: 150.w,
            height: 216.h, // card width
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 16.r,
                  offset: Offset(0, 6.h),
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
                          pooja.mediaUrl,
                          width: 134.w,
                          height: 80.h,
                          fit: BoxFit.cover,
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
                      SizedBox(height: 4.h),
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
          );
        },
      ),
    );
  }

  Widget _buildSpecialPrayersGrid(
    List<SpecialPooja> prayers,
    AsyncValue<List<SpecialPooja>>? cachedSpecialPrayers,
  ) {
    return GridView.builder(
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
        return Container(
          width: 163.w,
          height: 200.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
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
                    pooja.mediaUrl,
                    width: 146.w,
                    height: 80.h,
                    fit: BoxFit.cover,
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
        );
      },
    );
  }
}
