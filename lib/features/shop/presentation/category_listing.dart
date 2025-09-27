import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:temple/core/constants/sized.dart';
import 'package:temple/core/theme/color/colors.dart';
import 'package:temple/features/shop/providers/categoryRepo_provider.dart';
import 'package:temple/features/shop/providers/gesture_riverpod.dart';
import 'package:temple/widgets/mytext.dart';

class ShopCategorySection extends ConsumerWidget {
  final int selectedIndex;
  const ShopCategorySection({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Expanded(
      flex: 2,
      child: categoriesAsync.when(
        data: (data) {
          return Padding(
            padding: EdgeInsets.only(left: 10.w, top: 5.h, bottom: 3.h),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: data.length,
              itemBuilder: (context, index) {
                final isSelected = selectedIndex == index;
                return GestureDetector(
                  onTap: () {
                    final current = ref.read(selectedCategoryIndexProvider);
                    ref.read(selectedCategoryIndexProvider.notifier).state =
                        (current == index) ? null : index;
                    ref.read(selectedIndexCatProvider.notifier).state = index;
                  },
                  child: Container(
                    width: 95.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: isSelected
                            ? primaryThemeColor
                            : Colors.transparent,
                        width: 2.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 16.r,
                          offset: Offset(0, 6.h),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 9,
                          child: Padding(
                            padding: EdgeInsets.all(3.w),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5.r),
                              child: Image.network(
                                _normalizeImageUrl(data[index].mediaUrl),
                                fit: BoxFit.fitHeight,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: WText(
                            text: data[index].name,
                            color: cBlack,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => AppSizes.w10,
            ),
          );
        },

        /// 🔹 Shimmer loading effect
        loading: () => Padding(
          padding: EdgeInsets.only(left: 10.w, top: 5.h, bottom: 3.h),
          child: SizedBox(
            height: 80.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              itemBuilder: (context, index) => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: 95.w,
                  decoration: BoxDecoration(
                    color: cWhite,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              separatorBuilder: (_, __) => AppSizes.w10,
            ),
          ),
        ),

        error: (err, stack) => Center(child: Text("Error: $err")),
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
  return 'https://' + trimmed;
}
