import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';


class CheckoutAppBarSection extends ConsumerWidget {
    final Function()? onPressed;
  const CheckoutAppBarSection({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    return Expanded(
      flex: 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onPressed,
            child: Padding(
              padding: EdgeInsets.only(left: 10.w, top: 0.h),
              child: SvgPicture.asset(
                'assets/svg/Group 6.svg',
                fit: BoxFit.contain,
                height: 30.h,
                width: 30.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
