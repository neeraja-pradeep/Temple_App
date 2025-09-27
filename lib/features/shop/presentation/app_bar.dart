import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';


class AppBarSection extends ConsumerWidget {
   final Function()? onPressed;
  const AppBarSection({super.key,required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      flex: 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10.w, top: 5.h),
            child: SvgPicture.asset(
              'assets/svg/Group 6.svg',
              fit: BoxFit.contain,
              height: 30.h,
              width: 30.w,
            ),
          ),
          GestureDetector(
            onTap: onPressed,
          
            child: Padding(
              padding: EdgeInsets.only(right: 10.w, top: 5.h),
              child: Container(
                height: 35.h,
                width: 35.w,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 251, 239, 217),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/svg/_x30_1_cart.svg',
                    fit: BoxFit.contain,
                    height: 16.82.h,
                    width: 16.83.w,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
