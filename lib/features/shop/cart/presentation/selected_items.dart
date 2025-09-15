import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:temple/core/constants/sized.dart';
import 'package:temple/core/theme/color/colors.dart';
import 'package:temple/features/shop/cart/providers/checkout_provider.dart';
import 'package:temple/widgets/mytext.dart';

class CartSelectedItemslisting extends ConsumerWidget {
  const CartSelectedItemslisting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProviders);
    ref.read(cartProviders.notifier).loadCart();

    if (items.isEmpty) {
      return const Center(child: Text("No items in cart"));
    }

    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 14),
        child: ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => AppSizes.h5,
          itemBuilder: (context, index) {
            final item = items[index];

            return Container(
              decoration: BoxDecoration(
                // border: Border.all(color: cGrey),
              ),
              height: 95.h,
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  SizedBox(
                    width: 75.w,
                    height: 67.h,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        10.r,
                      ), // curve the image
                      child: Image.network(
                        item.productimage,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),

                  AppSizes.w10,

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: WText(
                                text: item.name,
                                color: cBlack,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            WText(
                              text:
                                  "₹${(double.tryParse(item.price) ?? 0) * item.quantity}",
                              color: cBlack,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ],
                        ),
                        AppSizes.h10,
                        WText(
                          text: "Other details here",
                          fontSize: 12.sp,
                          color: cGrey,
                        ),
                        AppSizes.h5,

                        // Quantity control
                        Container(
                          height: 25.h,
                          width: 80.w,
                          decoration: BoxDecoration(
                            border: Border.all(color: cGrey.withOpacity(0.2)),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                item.quantity == 1
                                    ? GestureDetector(
                                        onTap: () => ref
                                            .read(cartProviders.notifier)
                                            .removeItem(
                                              item.productVariantId,
                                            ), // this will delete fully
                                        child: SvgPicture.asset(
                                          'assets/svg/delete.svg',
                                          colorFilter: ColorFilter.mode(
                                            cBlack.withOpacity(0.7),
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () => ref
                                            .read(cartProviders.notifier)
                                            .removeItem(
                                              item.productVariantId,
                                            ), // this will decrement
                                        child: Container(
                                          height: 18.h,
                                          width: 18.h,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: cGrey),
                                            color: cWhite,
                                            borderRadius: BorderRadius.circular(
                                              6.r,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.remove,
                                            color: cGrey,
                                            size: 16,
                                          ),
                                        ),
                                      ),

                                WText(
                                  text: item.quantity.toString(),
                                  fontSize: 12.sp,
                                ),
                                GestureDetector(
                                  onTap: () => ref
                                      .read(cartProviders.notifier)
                                      .addItem(item.productVariantId),
                                  child: SvgPicture.asset(
                                    'assets/svg/add.svg',
                                    colorFilter: ColorFilter.mode(
                                      cBlack.withOpacity(0.7),
                                      BlendMode.srcIn,
                                    ),
                                  ),
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
        ),
      ),
    );
  }
}
