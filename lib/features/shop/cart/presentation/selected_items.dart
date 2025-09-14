import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:temple/core/constants/sized.dart';
import 'package:temple/core/theme/color/colors.dart';
import 'package:temple/widgets/mytext.dart';

class CartSelectedItemslisting extends StatelessWidget {
  const CartSelectedItemslisting({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10,top: 14),
        child: ListView.separated(
          itemBuilder: (context, index) {
            return SizedBox(
              height: 85.h,
              width: double.infinity,
              // decoration: BoxDecoration(border: Border.all(color: cBlack)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // Image/Thumbnail
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      color: Colors.amber,
                    ),
                  ),
                  AppSizes.w10,

                  // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: WText(
                                text: 'ദീപം',
                                color: cBlack,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            WText(
                              text: '₹1,500',
                              color: cBlack,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ],
                        ),
                        AppSizes.h10,
                        WText(
                          text: "Other Details of Brass Lamp",
                          fontSize: 12.sp,
                          color: cGrey,
                        ),
                        AppSizes.h5,
                        Container(
                          height: 25.h,
                          width: 80.w,
                          decoration: BoxDecoration(
                            border: Border.all(color: cGrey.withOpacity(0.2)),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 05, right: 05),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SvgPicture.asset(
                                  'assets/svg/delete.svg',
                                  colorFilter: ColorFilter.mode(
                                    cBlack.withValues(alpha: 0.7),
                                    BlendMode.srcIn,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                                WText(text: "01", fontSize: 12.sp),
                                SvgPicture.asset(
                                  'assets/svg/add.svg',
                                  colorFilter: ColorFilter.mode(
                                    cBlack.withValues(alpha: 0.7),
                                    BlendMode.srcIn,
                                  ),

                                  fit: BoxFit.cover,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (context, index) {
            return AppSizes.h5;
          },
          itemCount: 05,
        ),
      ),
    );
  }
}
