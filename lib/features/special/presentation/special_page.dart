import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple/core/app_colors.dart';
import '../providers/special_pooja_provider.dart';

class SpecialPage extends ConsumerWidget {
  const SpecialPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPoojas = ref.watch(specialPoojasProvider);
    final currentPage = ref.watch(specialBannerPageProvider);
    final pageController = PageController(
      viewportFraction: 1.0,
      initialPage: currentPage,
    );
    return asyncPoojas.when(
      data: (poojas) {
        if (poojas.isEmpty) {
          return const Center(child: Text('No special poojas available.'));
        }
        return RefreshIndicator(
          color: AppColors.selected,
          onRefresh: () async {
             ref.refresh(specialPoojasProvider);
             ref.read(specialBannerPageProvider.notifier).state = 0;
             await ref.read(specialPoojasProvider.future);
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),  // needed for refresh indicator
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Banner Section
                Column(
                  children: [
                    SizedBox(
                      height: 200.h,
                      child: PageView.builder(
                        itemCount: poojas.length,
                        controller: pageController,
                        onPageChanged: (i) =>
                            ref.read(specialBannerPageProvider.notifier).state =
                                i,
                        itemBuilder: (context, index) {
                          final pooja = poojas[index];
                          final date = pooja.specialPoojaDates.isNotEmpty
                              ? (pooja.specialPoojaDates.first.date.isNotEmpty
                                    ? pooja.specialPoojaDates.first.malayalamDate
                                    : pooja.specialPoojaDates.first.date)
                              : '';
                          return Padding(
                            padding: EdgeInsets.only(
                              top: 50.h,
                              left: 16.w,
                              right: 16.w,
                              bottom: 10.h,
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: Image.network(
                                    pooja.bannerUrl,
                                    width: double.infinity,
                                    height: 200.h,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                          color: Colors.grey,
                                          width: double.infinity,
                                          height: 200.h,
                                          child: const Icon(Icons.broken_image),
                                        ),
                                  ),
                                ),
                                Positioned(
                                  left: 16.w,
                                  top: 16.h,
                                  right: 16.w,
                                  bottom: 16.h,
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
                                              fontSize: 20.sp,
                                              fontWeight: FontWeight.bold,
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
                                          SizedBox(height: 4.h),
                                          Text(
                                            pooja.categoryName,
                                            style: TextStyle(
                                              fontSize: 16.sp,
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
                                          SizedBox(height: 4.h),
                                          if (pooja.captionsDesc.isNotEmpty) ...[
                                            SizedBox(height: 4.h),
                                            Text(
                                              pooja.captionsDesc,
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w400,
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.black
                                                        .withOpacity(0.3),
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
                                            fontSize: 14.sp,
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
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        poojas.length > 3 ? poojas.length : 3,
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
                  padding: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w ,),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ഇന്നത്തെ പൂജകൾ",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Consumer(
                        builder: (context, ref, _) {
                          final asyncWeeklyPoojas = ref.watch(
                            weeklyPoojasProvider,
                          );
                          return asyncWeeklyPoojas.when(
                            data: (poojas) {
                              if (poojas.isEmpty) {
                                return const Center(
                                  child: Text('No prayers available.'),
                                );
                              }
                              return SizedBox(
                                height: 216.h,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: poojas.length,
                                  separatorBuilder: (context, i) =>
                                      SizedBox(width: 20.w),
                                  itemBuilder: (context, index) {
                                    final pooja = poojas[index];
                                    return Container(
                                      width: 150.w,
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
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(10.r),
                                                child: Image.network(
                                                  pooja.mediaUrl,
                                                  width: 134.w,
                                                  height: 80.h,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey[200],
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12.r,
                                                              ),
                                                        ),
                                                        width: 180.w,
                                                        height: 80.h,
                                                        child: const Icon(
                                                          Icons.broken_image,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.w),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  pooja.name,
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.left,
                                                ),
                                                SizedBox(height: 4.h),
                                                Text(
                                                  pooja.categoryName,
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color: Colors.grey[700],
                                                  ),
                                                  textAlign: TextAlign.left,
                                                ),
                                                SizedBox(height: 4.h),
                                                Text(
                                                  '₹${pooja.price}',
                                                  style: TextStyle(
                                                    fontSize: 13.sp,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                            loading: () => SizedBox(
                              height: 180.h,
                              child: Center(child: CircularProgressIndicator(
                                color: AppColors.selected,
                              )),
                            ),
                            error: (e, st) => SizedBox(
                              height: 180.h,
                              child: Center(child: Text('Error: $e')),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
          
                // 3. Today's Special Section
                Padding(
                  padding: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w),
          
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "പ്രത്യേക പൂജകൾ",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Consumer(
                        builder: (context, ref, _) {
                          final asyncSpecialPrayers = ref.watch(
                            specialPrayersProvider,
                          );
                          return asyncSpecialPrayers.when(
                            data: (prayers) {
                              if (prayers.isEmpty) {
                                return const Center(
                                  child: Text('No special prayers available.'),
                                );
                              }
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 16.h,
                                      crossAxisSpacing: 12.w,
                                      childAspectRatio:
                                          0.60, // Decrease aspect ratio for taller cards
                                    ),
                                itemCount: prayers.length,
                                itemBuilder: (context, index) {
                                  final pooja = prayers[index];
                                  return Container(
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
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(12.r),
                                              child: Image.network(
                                                pooja.mediaUrl,
                                                width: double.infinity,
                                                height: 80.h,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[200],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12.r,
                                                            ),
                                                      ),
                                                      width: double.infinity,
                                                      height: 120.h,
                                                      child: const Icon(
                                                        Icons.broken_image,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.all(8.w),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
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
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                    SizedBox(height: 4.h),
                                                    Text(
                                                      pooja.categoryName,
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                      style: TextStyle(
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
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            loading: () => SizedBox(
                              height: 200.h,
                              child: Center(child: CircularProgressIndicator(
                                color: AppColors.selected,
                              )),
                            ),
                            error: (e, st) => SizedBox(
                              height: 200.h,
                              child: Center(child: Text('Error: $e')),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),


                SizedBox(height: 10.h,)
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(
        color: AppColors.selected,
      )),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}
