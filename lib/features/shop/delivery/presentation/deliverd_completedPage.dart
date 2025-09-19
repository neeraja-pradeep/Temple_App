import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple/core/app.dart';
import 'package:temple/core/constants/sized.dart';
import 'package:temple/core/theme/color/colors.dart';
import 'package:temple/features/shop/cart/presentation/app_bar.dart';
import 'package:temple/features/shop/providers/gesture_riverpod.dart';
import 'package:temple/features/shop/widget/text_widget.dart';
import 'package:temple/widgets/mytext.dart';

class DeliverdCompletedPage extends ConsumerWidget {
  const DeliverdCompletedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            /// Background Image
            Image.asset(
              'assets/backgroundimage.jpg',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.topCenter,
            ),

            /// Content
            Column(
              children: [
                /// Custom App Bar
                CheckoutAppBarSection(
                  onPressed: () {
                    ref.watch(onclickCheckoutButton.notifier).state = false;
                    ref.watch(onclickConformCheckoutButton.notifier).state =
                        false;
                  },
                ),

                /// Main White Card Section
                Expanded(
                  flex: 11,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: 50.h,
                      left: 11.w,
                      right: 11.w,
                      top: 5.h,
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cWhite,
                        borderRadius: BorderRadius.circular(8.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(15.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            /// Title
                            Center(
                              child: WText(
                                text: "നന്ദി!",
                                color: cBlack,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Center(
                              child: WText(
                                text: 'നിങ്ങളുടെ ഓർഡർ സ്ഥിരീകരിച്ചു',
                                color: cBlack,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            AppSizes.h20,

                            /// Order ID
                            TextFontWidget(
                              text: "Order ID: #ORD23984",
                              fontsize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: cBlack,
                            ),
                            AppSizes.h10,

                            /// Total Price
                            TextFontWidget(
                              text: "മൊത്തം തുക: ₹1,840",
                              fontsize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: cBlack,
                            ),
                            AppSizes.h15,

                            /// Item List
                            SizedBox(
                              height: 130.h,
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return TextFontWidget(
                                    text: "Item Details 0${index + 1}",
                                    fontsize: 11.sp,
                                    fontWeight: FontWeight.w500,
                                    color: cGrey,
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    AppSizes.h10,
                                itemCount: 10,
                              ),
                            ),
                            AppSizes.h20,

                            /// Address Section
                            TextFontWidget(
                              text: "ഹരിചന്ദ്രൻ – മകയിരം നക്ഷത്രം",
                              fontsize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: cBlack,
                            ),
                            TextFontWidget(
                              text: "തിരുവല്ല, address line 01",
                              fontsize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: cGrey,
                            ),
                            TextFontWidget(
                              text: "പിന്‍കോഡ് 689101",
                              fontsize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: cGrey,
                            ),
                            AppSizes.h10,
                            TextFontWidget(
                              text: "ഡെലിവറി: 6–8 ദിവസങ്ങൾക്കുള്ളിൽ",
                              fontsize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: cGrey,
                            ),
                            AppSizes.h20,
                            AppSizes.h20,
                            AppSizes.h20,
                            AppSizes.h20,

                            /// Tracking Info
                            TextFontWidget(
                              text: "Tracking info: [Available Soon]",
                              fontsize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: cGrey,
                            ),
                            AppSizes.h10,
                            TextFontWidget(
                              text:
                                  "നിങ്ങളുടെ വസ്തുക്കൾ ഉടൻ ശേഖരിച്ച് അയയ്ക്കും.\nദൈവ അനുഗ്രഹം എല്ലായ്പ്പോഴും ഉണ്ടാകട്ടെ",
                              fontsize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: cGrey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                /// Bottom Button: Go Home
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryThemeColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 11.h),
                      ),
                      onPressed: () {
                        ref.watch(onclickCheckoutButton.notifier).state = false;
                        ref.watch(onclickConformCheckoutButton.notifier).state =
                            false;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MainNavScreen(),
                          ),
                        );
                      },
                      child: WText(
                        text: 'ഹോം സ്ക്രീൻ ലേക്ക് മടങ്ങുക',
                        color: cWhite,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                AppSizes.h10,

                /// Bottom Text: View Orders
                GestureDetector(
                  onTap: () {},
                  child: Center(
                    child: WText(
                      text: 'മൈ ഓർഡേഴ്സ് കാണുക',
                      color: primaryThemeColor,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                AppSizes.h20,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
