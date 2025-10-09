import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:temple_app/core/constants/sized.dart';
import 'package:temple_app/core/theme/color/colors.dart';
import 'package:temple_app/features/shop/providers/categoryRepo_provider.dart';
import 'package:temple_app/features/shop/providers/gesture_riverpod.dart';
import 'package:temple_app/widgets/mytext.dart';

class ShopCategorySection extends ConsumerWidget {
  final int selectedIndex;
  const ShopCategorySection({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final isRefreshing = ref.watch(categoryRefreshInProgressProvider);

    Widget buildShimmer() => _buildCategoryShimmer();

    if (isRefreshing) {
      log('[UI] Category refresh in progress – showing shimmer');
      return Expanded(
        flex: 2,
        child: buildShimmer(),
      );
    }

    return Expanded(
      flex: 2,
      child: categoriesAsync.when(
        data: (data) {
          log('[UI] Categories loaded: ${data.length} items');

          if (data.isEmpty) {
            log('[UI] Category list is empty. Waiting 5 seconds before showing message...');
            return FutureBuilder(
              future: Future.delayed(const Duration(seconds: 5)),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return buildShimmer();
                }

                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: WText(
                      text: "No categories available",
                      color: Colors.grey,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            );
          }

          return Padding(
            padding: EdgeInsets.only(left: 10.w, top: 5.h, bottom: 3.h),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: data.length,
              itemBuilder: (context, index) {
                final isSelected = selectedIndex == index;

                return GestureDetector(
                  onTap: () {
                    try {
                      ref.read(selectedCategoryIndexProvider.notifier).state = index;
                      ref.read(selectedIndexCatProvider.notifier).state = index;
                      log('[UI] Category tapped: ${data[index].name} (Index: $index)');
                    } catch (e, st) {
                      log('[Error] Failed to update category selection: $e');
                      log('[StackTrace]', error: e, stackTrace: st);
                    }
                  },
                  child: Container(
                    width: 95.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: isSelected ? primaryThemeColor : Colors.transparent,
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
                              child: _buildImage(data[index].mediaUrl),
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
        loading: () {
          log('[UI] Loading categories...');
          return buildShimmer();
        },
        error: (err, stack) {
          log('[UI Error] Error loading categories: $err');
          log('[StackTrace]', error: err, stackTrace: stack);
          return Center(
            child: Padding(
              padding: EdgeInsets.all(10.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade400, size: 30),
                  AppSizes.h10,
                  WText(
                    text: "Failed to load categories.\\nPlease try again later.",
                    color: Colors.red.shade400,
                    fontSize: 12.sp,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryShimmer() {
    return Padding(
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
    );
  }

  /// Safely build network image with fallback
  Widget _buildImage(String? url) {
    final safeUrl = _normalizeImageUrl(url ?? '');
    if (safeUrl.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }
    return Image.network(
      safeUrl,
      fit: BoxFit.fitHeight,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }
}

// âœ… Normalizes URL scheme
String _normalizeImageUrl(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return '';
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) return trimmed;
  return 'https://$trimmed';
}

