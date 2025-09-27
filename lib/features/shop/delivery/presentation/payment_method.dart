import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:temple/core/constants/sized.dart';
import 'package:temple/core/theme/color/colors.dart';
import 'package:temple/features/shop/cart/presentation/app_bar.dart';
import 'package:temple/features/shop/delivery/presentation/add_address.dart';
import 'package:temple/features/shop/delivery/presentation/deliverd_completedPage.dart';
import 'package:temple/features/shop/delivery/presentation/saved_address.dart';
import 'package:temple/features/shop/delivery/providers/delivery_provider.dart';
import 'package:temple/features/shop/providers/gesture_riverpod.dart';
import 'package:temple/features/shop/widget/checkout_button.dart';
import 'package:temple/widgets/mytext.dart';
import 'package:temple/features/shop/cart/providers/addToCart_provider.dart';

class PaymentMethodScreen extends ConsumerWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressState = ref.watch(addressListProvider);

    return Stack(
      children: [
        Column(
          children: [
            /// ✅ Top App Bar
            CheckoutAppBarSection(
              onPressed: () {
                ref.watch(onclickCheckoutButton.notifier).state = true;
                ref.watch(onclickConformCheckoutButton.notifier).state = false;
              },
            ),

            /// ✅ Main Content
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

                        addressState.when(
                          data: (addresses) {
                            log("Addresses: $addresses");
                            if (addresses.isEmpty) {
                              // ✅ Show "Add Address" button when no address
                              return Center(
                                child: Column(
                                  children: [
                                    WText(
                                      text: "No address found",
                                      fontSize: 12.sp,
                                      color: cGrey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    AppSizes.h10,
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryThemeColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        showAddAddressSheet(context);
                                      },
                                      child: WText(
                                        text: "Add Address",
                                        fontSize: 12.sp,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            // ✅ Get selected/default address
                            final defaultAddress = addresses.firstWhere(
                              (a) => a.selection == true,
                              orElse: () => addresses.first,
                            );

                            return Padding(
                              padding: EdgeInsets.only(left: 8.w, right: 8.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  WText(
                                    text: defaultAddress.name,
                                    fontSize: 12.sp,
                                    color: cBlack,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  AppSizes.h5,
                                  WText(
                                    text:
                                        "${defaultAddress.street}, ${defaultAddress.city}, ${defaultAddress.state}, ${defaultAddress.country}",
                                    fontSize: 11.sp,
                                    color: cGrey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  WText(
                                    text: defaultAddress.pincode,
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
                                        onTap: () {
                                          showSavedAddressSheet(context);
                                        },
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
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (err, st) =>
                              Center(child: Text("Error: $err")),
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
                          itemCount: paymentMethods.length,
                          separatorBuilder: (context, index) => AppSizes.h20,
                          itemBuilder: (context, index) {
                            final selectedIndex = ref.watch(
                              selectedPaymentProvider,
                            );

                            final isSelected = selectedIndex == index;

                            return GestureDetector(
                              onTap: () {
                                ref
                                        .read(selectedPaymentProvider.notifier)
                                        .state =
                                    index;
                              },
                              child: Container(
                                height: 42.h,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? primaryThemeColor.withOpacity(0.1)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? primaryThemeColor
                                        : Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 15.w),
                                    child: WText(
                                      text: paymentMethods[index],
                                      fontSize: 13.sp,
                                      color: isSelected
                                          ? primaryThemeColor
                                          : cGrey,
                                      fontWeight: FontWeight.w500,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
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
          ],
        ),

        /// ✅ Checkout Button
        CheckoutButton(
          onPressed: () async {
            final selectedPayment = ref
                .watch(selectedPaymentProvider.notifier)
                .state;

            // Check address availability
            final addressAvailable =
                addressState.asData?.value.isNotEmpty ?? false;

            if (!addressAvailable) {
              showError("Please add a delivery address");
              return;
            }

            if (selectedPayment == -1) {
              showError("Please select a payment method");
            } else {
              // Call checkout API (no payload)
              print("[PAYMENT] Starting pay API call...");
              // Force a fresh provider execution to avoid cached results
              final orderId = await ref.refresh(
                payAndGetOrderIdProvider.future,
              );
              print("[PAYMENT] Pay API call completed. orderId=$orderId");
              if (!context.mounted) return;

              if (orderId != null) {
                ref.watch(selectedPaymentProvider.notifier).state = -1;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DeliverdCompletedPage(orderId: orderId),
                  ),
                );
              } else {
                showError("Payment failed. Please try again");
              }
            }
          },
        ),
      ],
    );
  }

  void showError(String message) {
    Fluttertoast.cancel(); // cancel previous toast if still visible
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: primaryThemeColor,
      textColor: Colors.white,
      fontSize: 14.0,
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
