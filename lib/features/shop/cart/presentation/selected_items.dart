import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:temple/core/constants/sized.dart';
import 'package:temple/core/theme/color/colors.dart';
import 'package:temple/features/shop/cart/data/model/cart_model.dart';
import 'package:temple/features/shop/cart/providers/cart_provider.dart';
import 'package:temple/widgets/mytext.dart';

class CartSelectedItemslisting extends ConsumerWidget {
  const CartSelectedItemslisting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProviders);

    if (cartItems.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_cart_outlined,
                  size: 40, color: Colors.grey),
              AppSizes.h10,
              WText(
                text: "Your cart is empty",
                fontSize: 14.sp,
                color: cGrey,
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      flex: 2,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
        itemCount: cartItems.length,
        separatorBuilder: (_, __) => AppSizes.h5,
        itemBuilder: (context, index) {
          final item = cartItems[index];
          final quantity = item.quantity;

          return Container(
            decoration: BoxDecoration(
              color: cWhite,
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8.r,
                  offset: Offset(0, 4.h),
                ),
              ],
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
                    borderRadius: BorderRadius.circular(10.r),
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

                // Info + Quantity
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + Price
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
                        width: 90.w,
                        decoration: BoxDecoration(
                          border: Border.all(color: cGrey.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Remove / Delete
                              quantity == 1
                                  ? GestureDetector(
                                      onTap: () async {
                                        await ref
                                            .read(cartProviders.notifier)
                                            .removeItem(item.productVariantId);
                                      },
                                      child: SvgPicture.asset(
                                        'assets/svg/delete.svg',
                                        colorFilter: ColorFilter.mode(
                                          cBlack.withOpacity(0.7),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () async {
                                        await ref
                                            .read(cartProviders.notifier)
                                            .decrementItem(
                                                item.productVariantId);
                                      },
                                      child: Container(
                                        height: 18.h,
                                        width: 18.h,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: cGrey),
                                          color: cWhite,
                                          borderRadius:
                                              BorderRadius.circular(6.r),
                                        ),
                                        child: Icon(
                                          Icons.remove,
                                          color: cGrey,
                                          size: 16,
                                        ),
                                      ),
                                    ),

                              // Quantity
                              WText(
                                text: quantity.toString(),
                                fontSize: 12.sp,
                              ),

                              // Add (+1 always)
                              GestureDetector(
                                onTap: () async {
                                  final singleIncrement = CartItem(
                                    id: item.id,
                                    productVariantId: item.productVariantId,
                                    name: item.name,
                                    sku: item.sku,
                                    price: item.price,
                                    quantity: 1, // ✅ Always add +1
                                    productimage: item.productimage,
                                  );

                                  await ref
                                      .read(cartProviders.notifier)
                                      .addItem(singleIncrement);
                                },
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
    );
  }
}
