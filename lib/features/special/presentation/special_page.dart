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
      viewportFraction: 0.9,
      initialPage: currentPage,
    );
    return asyncPoojas.when(
      data: (poojas) {
        if (poojas.isEmpty) {
          return const Center(child: Text('No special poojas available.'));
        }
        return Column(
          children: [
            SizedBox(
              height: 200.h,
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
                  return Padding(
                    padding: EdgeInsets.only(
                      top: 50.h,
                      left: 8.w,
                      right: 8.w,
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pooja.name,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
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
                                      color: Colors.black.withOpacity(0.4),
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
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 3.r,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              SizedBox(height: 4.h),
                              if (date.isNotEmpty) ...[
                                SizedBox(height: 4.h),
                                Text(
                                  date,
                                  style: TextStyle(
                                    fontSize: 14.sp,
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
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                poojas.length > 3 ? poojas.length : 3,
                (index) => AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: currentPage == index ? 24.w : 12.w,
                  height: currentPage == index ? 12.w : 12.w,
                  decoration: BoxDecoration(
                    color: currentPage == index
                        ? AppColors.selected
                        : AppColors.unselected,
                    borderRadius: BorderRadius.circular(
                      currentPage == index ? 12.w : 12.w,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}
