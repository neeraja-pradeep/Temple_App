import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple/core/constants/sized.dart';
import 'package:temple/core/theme/color/colors.dart';
import 'package:temple/features/shop/cart/presentation/checkout_screen.dart';
import 'package:temple/widgets/mytext.dart';

class ItemsPriceDetails extends StatelessWidget {
  const ItemsPriceDetails({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: cGrey, width: 1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 05, right: 05),
          child: Column(
            children: [
              AppSizes.h10,
              SelectedItemPriceDetail(
                text: 'ആകെ തുക',
                price: '₹1,800',
              ),
              AppSizes.h10,
              SelectedItemPriceDetail(
                text: 'ഡെലിവറി ചാർജ്',
                price: '₹40',
              ),
              AppSizes.h10,
              SelectedItemPriceDetail(
                text: 'Other charges/taxes',
                price: '₹00',
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(
                  left: 05,
                  right: 05,
                  bottom: 05,
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    WText(
                      text: "Total",
                      fontSize: 16.sp,
                      color: cBlack,
                      fontWeight: FontWeight.bold,
                    ),
                    WText(
                      text: "₹1,500",
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