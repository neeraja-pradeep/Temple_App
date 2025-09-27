import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple/core/constants/sized.dart';
import 'package:temple/core/theme/color/colors.dart';
import 'package:temple/features/shop/cart/presentation/app_bar.dart';
import 'package:temple/features/shop/cart/presentation/item_priceDetails.dart';
import 'package:temple/features/shop/cart/presentation/selected_items.dart';
import 'package:temple/features/shop/cart/providers/addToCart_provider.dart';
import 'package:temple/features/shop/cart/providers/cart_provider.dart';
import 'package:temple/features/shop/providers/gesture_riverpod.dart';
import 'package:temple/features/shop/widget/checkout_button.dart';
import 'package:temple/widgets/mytext.dart';

class CheckoutScreen extends  ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
     bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            CheckoutAppBarSection(
              onPressed: () =>
                  ref.read(onclickCheckoutButton.notifier).state = false,
            ), //**************** App BAR ***************

            Expanded(
              flex: 11,
              child: Padding(
                padding: EdgeInsets.only(bottom: 60.h),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cWhite,
                    borderRadius: BorderRadius.circular(15.r),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSizes.h10,
                      AppSizes.h5,

                      Center(
                        child: WText(
                          text: "കാർട്ട്",
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 20,
                        ),
                        child: Divider(thickness: 1.h, color: cGrey),
                      ),

                      CartSelectedItemslisting(), // ***************** Cart Items *****************
                      ItemsPriceDetails(), // ***************** Cart Items Price Details *****************
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      // Checkout Button
        CheckoutButton(
          onPressed: isLoading ? null : () async {
            setState(() => isLoading = true);

            final cartItems = ref.read(cartProviders);

            // Call API for each item
            for (var item in cartItems) {
              await ref.read(
                addAndUpdateCartItemToAPI({
                  "productVariantId": item.productVariantId,
                  "quantity": item.quantity,
                }).future,
              );
            }

            // After all API calls
            if (!mounted) return; // avoid using ref if widget disposed
            ref.read(onclickConformCheckoutButton.notifier).state = true;
            ref.read(onclickCheckoutButton.notifier).state = false;

            setState(() => isLoading = false);
          },
        ),

        // Optional loading overlay
        if (isLoading)
          Container(
            color: Colors.black45,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        //**************** Checkout Button ***************
      ],
    );
  }
}

class SelectedItemPriceDetail extends StatelessWidget {
  final String text;
  final String price;
  const SelectedItemPriceDetail({
    super.key,
    required this.text,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          WText(
            text: text,
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
          WText(
            text: price,
            fontSize: 12.5.sp,
            fontWeight: FontWeight.bold,
            color: cBlack,
          ),
        ],
      ),
    );
  }
}
