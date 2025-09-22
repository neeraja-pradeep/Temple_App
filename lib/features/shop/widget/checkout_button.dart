import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple/core/theme/color/colors.dart';
import 'package:temple/widgets/mytext.dart';

class CheckoutButton extends ConsumerWidget {
  final Function()? onPressed;
  final String text;
  const CheckoutButton({
    required this.onPressed,
    this.text = 'Checkout',
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      left: 16.w,
      right: 16.w,
      bottom: 8.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryThemeColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 10.h),
        ),
        onPressed: onPressed,
        child: WText(
          text: text,
          color: cWhite,
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
