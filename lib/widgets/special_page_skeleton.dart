import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SpecialPageSkeleton extends StatelessWidget {
  const SpecialPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Banner Section Skeleton
          Column(
            children: [
              SizedBox(height: 64.h),
              Container(
                width: 343.w,
                height: 142.h,
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: Colors.grey[300],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 16.r,
                      offset: Offset(8.w, 8.h),
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              // Page indicators skeleton
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: index == 0 ? 35.w : 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: index == 0 ? Colors.grey[400] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 2. Today's Prayers Section Skeleton
          Padding(
            padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24.h),
                Container(
                  height: 12.h,
                  width: 120.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 12.h),
                // Weekly poojas skeleton
                SizedBox(
                  height: 180.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
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
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 12.h,
                                          width: 120.w,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(
                                              4.r,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Container(
                                          height: 12.h,
                                          width: 100.w,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(
                                              4.r,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 14.h,
                                      width: 60.w,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(
                                          4.r,
                                        ),
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
                ),
              ],
            ),
          ),

          // 3. Special Poojas Section Skeleton
          Padding(
            padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24.h),
                Container(
                  height: 12.h,
                  width: 120.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 16.h),
                // Special poojas grid skeleton
                GridView.builder(
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
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Container(
                                width: 146.w,
                                height: 80.h,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 8.w,
                                  right: 8.w,
                                  top: 8.h,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 12.h,
                                          width: 120.w,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(
                                              4.r,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Container(
                                          height: 12.h,
                                          width: 100.w,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(
                                              4.r,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 14.h,
                                      width: 60.w,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(
                                          4.r,
                                        ),
                                      ),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
