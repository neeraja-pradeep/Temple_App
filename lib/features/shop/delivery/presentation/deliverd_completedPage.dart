import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple_app/core/app.dart';
import 'package:temple_app/core/constants/sized.dart';
import 'package:temple_app/core/theme/color/colors.dart';
import 'package:temple_app/features/shop/cart/presentation/app_bar.dart';
import 'package:temple_app/features/shop/cart/providers/cart_provider.dart';
import 'package:temple_app/features/shop/providers/gesture_riverpod.dart';
import 'package:temple_app/features/shop/widget/text_widget.dart';
import 'package:temple_app/widgets/mytext.dart';
import 'package:temple_app/features/shop/delivery/providers/delivery_provider.dart';

class DeliverdCompletedPage extends ConsumerWidget {
  final int? orderId;
  const DeliverdCompletedPage({super.key, this.orderId});

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
                  onPressed: () async {
                    // Clear cart data after successful order completion
                    await ref.read(cartProviders.notifier).clearCart();

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
                            if (orderId != null)
                              Consumer(
                                builder: (context, ref, _) {
                                  final order = ref.watch(
                                    orderDetailProvider(orderId!),
                                  );
                                  return order.when(
                                    data: (data) {
                                      final addr = data.shippingAddress;
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
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
                                              text:
                                                  'നിങ്ങളുടെ ഓർഡർ സ്ഥിരീകരിച്ചു',
                                              color: cBlack,
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 32.h),
                                          TextFontWidget(
                                            text: "Order ID: #${data.id}",
                                            fontsize: 11.sp,
                                            fontWeight: FontWeight.bold,
                                            color: cBlack,
                                          ),
                                          AppSizes.h10,
                                          TextFontWidget(
                                            text: "മൊത്തം തുക: ₹${data.total}",
                                            fontsize: 11.sp,
                                            fontWeight: FontWeight.bold,
                                            color: cBlack,
                                          ),
                                          AppSizes.h15,
                                          SizedBox(
                                            height: 130.h,
                                            child: ListView.separated(
                                              shrinkWrap: true,
                                              itemBuilder: (context, index) {
                                                final line = data.lines[index];
                                                return TextFontWidget(
                                                  text:
                                                      "${line.productName} – ${line.variantName} x${line.quantity} @ ₹${line.price}",
                                                  fontsize: 11.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: cGrey,
                                                );
                                              },
                                              separatorBuilder:
                                                  (context, index) =>
                                                      AppSizes.h10,
                                              itemCount: data.lines.length,
                                            ),
                                          ),
                                          AppSizes.h20,
                                          if (addr != null) ...[
                                            TextFontWidget(
                                              text: "${addr['street']}",
                                              fontsize: 11.sp,
                                              fontWeight: FontWeight.bold,
                                              color: cBlack,
                                            ),
                                            TextFontWidget(
                                              text:
                                                  "${addr['city']}, ${addr['state']}",
                                              fontsize: 11.sp,
                                              fontWeight: FontWeight.w500,
                                              color: cGrey,
                                            ),
                                            TextFontWidget(
                                              text:
                                                  "${addr['country']} ${addr['pincode']}",
                                              fontsize: 11.sp,
                                              fontWeight: FontWeight.w500,
                                              color: cGrey,
                                            ),
                                          ],
                                          AppSizes.h10,
                                        ],
                                      );
                                    },
                                    loading: () => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    error: (e, _) => Text(e.toString()),
                                  );
                                },
                              ),

                            /// Title
                            AppSizes.h20,

                            // Static fallback below retained after dynamic block
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
                      onPressed: () async {
                        // Clear cart data after successful order completion
                        await ref.read(cartProviders.notifier).clearCart();

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
