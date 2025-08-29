import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WeeklyPoojaSkeleton extends StatelessWidget {
  const WeeklyPoojaSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3, // Show 3 skeleton cards while loading
        separatorBuilder: (context, i) => SizedBox(width: 11.w),
        itemBuilder: (context, index) {
          return Container(
            width: 150.w,
            height: 216.h,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image skeleton
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      width: 134.w,
                      height: 80.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Text skeleton lines
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // First text line skeleton
                            Container(
                              height: 12.h,
                              width: 120.w,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                            SizedBox(height: 4.h),

                            // Second text line skeleton
                            Container(
                              height: 12.h,
                              width: 100.w,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                          ],
                        ),

                        // Price line skeleton
                        Container(
                          height: 14.h,
                          width: 60.w,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
