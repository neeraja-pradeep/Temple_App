import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple/core/theme/color/colors.dart';
import 'package:temple/features/shop/cart/presentation/checkout_screen.dart';
import 'package:temple/features/shop/cart/providers/cart_provider.dart';
import 'package:temple/widgets/mytext.dart';

class ItemsPriceDetails extends ConsumerWidget {
  const ItemsPriceDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProviders);

    // Calculate total price from Hive items
    final totalPrice = cartItems.fold<double>(
      0,
      (sum, item) => sum + (double.tryParse(item.price) ?? 0) * item.quantity,
    );

    if (cartItems.isEmpty) {
      return Expanded(
        flex: 1,
        child: Center(
          child: WText(
            text: "🛒 No items in cart",
            fontSize: 14.sp,
            color: cGrey,
          ),
        ),
      );
    }

    return Expanded(
      flex: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: cGrey, width: 1.w),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Column(
            children: [
              SizedBox(height: 10.h),
              SelectedItemPriceDetail(
                text: 'ആകെ തുക',
                price: '₹${totalPrice.toStringAsFixed(0)}',
              ),
              SizedBox(height: 10.h),
              SelectedItemPriceDetail(
                text: 'ഡെലിവറി ചാർജ്',
                price: '₹40',
              ),
              SizedBox(height: 10.h),
              SelectedItemPriceDetail(
                text: 'Other charges/taxes',
                price: '₹0',
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    WText(
                      text: "Total",
                      fontSize: 16.sp,
                      color: cBlack,
                      fontWeight: FontWeight.bold,
                    ),
                    WText(
                      text: '₹${(totalPrice + 40).toStringAsFixed(0)}',
                      fontSize: 16.sp,
                      color: cBlack,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
