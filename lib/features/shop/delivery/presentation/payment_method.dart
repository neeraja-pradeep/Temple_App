import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple/core/constants/sized.dart';
import 'package:temple/core/theme/color/colors.dart';
import 'package:temple/features/shop/presentation/app_bar.dart';
import 'package:temple/features/shop/widget/checkout_button.dart';
import 'package:temple/widgets/mytext.dart';

class PaymentMethodScreemn extends StatelessWidget {
  const PaymentMethodScreemn({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            /// ✅ Top App Bar
            AppBarSection(onPressed: () {}),

            /// ✅ Main Content (scrollable if needed)
            Expanded(
              flex: 11,
              child: Padding(
                padding: EdgeInsets.only(bottom: 60.h, left: 11.w, right: 11.w),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cWhite,
                    borderRadius: BorderRadius.circular(15.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// ✅ Delivery Address Section
                        Center(
                          child: WText(
                            text: "Delivery Address",
                            color: cBlack,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        AppSizes.h10,
                        Padding(
                          padding: EdgeInsets.only(left: 8.w, right: 8.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              WText(
                                text: "ഹരിചന്ദ്രൻ ഹരിചന്ദ്രൻ",
                                fontSize: 12.sp,
                                color: cBlack,
                                fontWeight: FontWeight.bold,
                              ),
                              AppSizes.h5,
                              WText(
                                text: "തിരുവല്ല, പിന്‍കോഡ്: 689101",
                                fontSize: 11.sp,
                                color: cGrey,
                                fontWeight: FontWeight.w500,
                              ),
                              WText(
                                text: "689101",
                                fontSize: 11.sp,
                                color: cGrey,
                                fontWeight: FontWeight.w500,
                              ),
                              AppSizes.h10,
                              Row(
                                children: [
                                  Expanded(
                                    child: WText(
                                      text: "Delivery within 5-7 days",
                                      fontSize: 11.sp,
                                      color: cGrey,
                                      fontWeight: FontWeight.w500,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {},
                                    child: WText(
                                      text: "Change address",
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.bold,
                                      color: primaryThemeColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        AppSizes.h10,
                        Divider(thickness: 1.w, color: cGrey),

                        /// ✅ Payment Methods
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 15.h),
                            child: WText(
                              text: "Payment Method",
                              color: cBlack,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Container(
                              height: 42.h,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: primaryThemeColor),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 15.w),
                                  child: WText(
                                    text: paymentMethods[index],
                                    fontSize: 13.sp,
                                    color: cBlack,
                                    fontWeight: FontWeight.w500,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) => AppSizes.h20,
                          itemCount: paymentMethods.length,
                        ),
                        AppSizes.h10,
                        Divider(thickness: 1.w, color: cGrey),

                        /// ✅ Price Details
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                          child: Column(
                            children: [
                              _priceRow("ആകെ തുക", "₹1,800"),
                              AppSizes.h5,
                              _priceRow("ഡെലിവറി ചാർജ്", "₹40"),
                              AppSizes.h5,
                              _priceRow("Other charges/taxes", "₹0"),
                              AppSizes.h5,
                              _priceRow("ആകെ തുക", "₹1,800"),
                              AppSizes.h5,
                              AppSizes.h10,
                              AppSizes.h10,
                              _priceRow("Total", "₹1,840", isBold: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            /// ✅ Checkout Button fixed at bottom
        
          ],
        ),
            CheckoutButton(onPressed: () {}),
      ],
    );
  }

  Widget _priceRow(String label, String price, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        WText(
          text: label,
          color: isBold ? cBlack : cGrey,
          fontSize: isBold ? 15.sp : 12.sp,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
        ),
        WText(
          text: price,
          color: cBlack,
          fontSize: isBold ? 15.sp : 12.sp,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
        ),
      ],
    );
  }
}

List<String> paymentMethods = [
  "ഡെബിറ്റ്/ക്രെഡിറ്റ് കാർഡ്",
  "UPI / PhonePe / GPay",
  "കാഷ് ഓൺ ഡെലിവറി (if supported)",
];
