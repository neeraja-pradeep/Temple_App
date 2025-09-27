import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple_app/core/app_colors.dart';

class AppButtonStyles {
  static ButtonStyle submitButtom = ElevatedButton.styleFrom(
      backgroundColor: AppColors.selected,
      foregroundColor: Colors.white,
      fixedSize: Size(342.w, 40.h),
      padding: EdgeInsets.all(6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
    );
}
