import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:temple_app/core/app_colors.dart';

class PoojaPageSkeleton extends StatelessWidget {
  const PoojaPageSkeleton({super.key});

  Widget _buildShimmerCategoryCard() {
    return Card(
      color: AppColors.navBarBackground,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: SizedBox(
        width: 142.w,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Shimmer.fromColors(
                baseColor: AppColors.navBarBackground.withOpacity(0.6),
                highlightColor: Colors.white.withOpacity(0.6),
                child: Container(
                  height: 102.h,
                  width: 131.w,
                  decoration: BoxDecoration(
                    color: AppColors.navBarBackground,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Shimmer.fromColors(
              baseColor: AppColors.navBarBackground.withOpacity(0.6),
              highlightColor: Colors.white.withOpacity(0.6),
              child: Container(
                height: 14.h,
                width: 80.w,
                color: AppColors.navBarBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerDropdown() {
    return Shimmer.fromColors(
      baseColor: AppColors.navBarBackground.withOpacity(0.6),
      highlightColor: Colors.white.withOpacity(0.6),
      child: Container(
        height: 40.h,
        width: 342.w,
        decoration: BoxDecoration(
          color: AppColors.navBarBackground,
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  Widget _buildShimmerCalendar() {
    return Shimmer.fromColors(
      baseColor: AppColors.navBarBackground.withOpacity(0.6),
      highlightColor: Colors.white.withOpacity(0.6),
      child: Container(
        height: 298.h,
        width: 343.w,
        decoration: BoxDecoration(
          color: AppColors.navBarBackground,
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: SizedBox(
              height: 152.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(2),
                  child: _buildShimmerCategoryCard(),
                ),
              ),
            ),
          ),
          SizedBox(height: 15.h),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: _buildShimmerDropdown(),
          ),
          SizedBox(height: 18.h),
          Padding(
            padding: const EdgeInsets.all(14),
            child: _buildShimmerCalendar(),
          ),
          SizedBox(height: 50.h),
        ],
      ),
    );
  }
}
