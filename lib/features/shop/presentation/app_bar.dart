import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:temple_app/features/shop/cart/providers/cart_provider.dart';

// Replace this with your real cart provider

class AppBarSection extends ConsumerWidget {
  final Function()? onPressed;
  const AppBarSection({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProviders);
    log("Cart items>>>>>>>>>>>>>>>>: $cartItems");

    return Expanded(
      flex: 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side logo
          Padding(
            padding: EdgeInsets.only(left: 10.w, top: 5.h),
            child: SvgPicture.asset(
              'assets/svg/Group 6.svg',
              fit: BoxFit.contain,
              height: 30.h,
              width: 30.w,
            ),
          ),

          // Cart icon with badge
          GestureDetector(
            onTap: onPressed,
            child: Padding(
              padding: EdgeInsets.only(right: 10.w, top: 5.h),
              child: Stack(
                clipBehavior: Clip.none, // ✅ Prevent clipping
                children: [
                  Container(
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

                  // Badge - only show if items exist
                  if (cartItems.isNotEmpty)
                    Positioned(
                      right: -2, // ✅ keep it inside
                      top: -2,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            '${cartItems.length}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
