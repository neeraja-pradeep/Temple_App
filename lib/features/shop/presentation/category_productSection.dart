import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:temple/core/theme/color/colors.dart';
import 'package:temple/features/shop/cart/data/model/cart_model.dart';
import 'package:temple/features/shop/cart/providers/cart_provider.dart';
import 'package:temple/features/shop/data/model/product/product_category.dart';
import 'package:temple/features/shop/providers/categoryRepo_provider.dart';
import 'package:temple/widgets/mytext.dart';

class CategoryProductGridSection extends ConsumerWidget {
  const CategoryProductGridSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fetchCategoryProducts = ref.watch(categoryProductProvider);
    final cartItems = ref.watch(cartProviders);

    return Expanded(
      flex: 10,
      child: Padding(
        padding: EdgeInsets.only(top: 5.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title
            Padding(
              padding: EdgeInsets.only(left: 10.w, top: 5.h, bottom: 6.h),
              child: WText(
                text: "Common Pooja items",
                color: cBlack,
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
              ),
            ),

            /// Grid
            Expanded(
              child: fetchCategoryProducts.when(
                data: (products) {
                  if (products.isEmpty) {
                    return const Center(child: Text("No products available"));
                  }

                  final allVariants = products
                      .expand(
                        (product) => product.variants.map(
                          (variant) => {"product": product, "variant": variant},
                        ),
                      )
                      .toList();

                  return GridView.builder(
                    padding: EdgeInsets.only(
                      left: 10.w,
                      right: 10.w,
                      bottom: 80.h,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: 15.w,
                      mainAxisSpacing: 10.h,
                      mainAxisExtent: 138.h,
                      crossAxisCount: 2,
                    ),
                    itemCount: allVariants.length,
                    itemBuilder: (context, index) {
                      final variant =
                          allVariants[index]["variant"] as VariantModel;

                      final cartItemInCart = cartItems.firstWhere(
                        (item) =>
                            item.productVariantId == variant.id.toString(),
                        orElse: () => CartItem(
                          id: variant.id,
                          productVariantId: variant.id.toString(),
                          name: variant.name,
                          sku: variant.sku,
                          price: variant.price,
                          quantity: 0,
                          productimage: variant.mediaUrl,
                        ),
                      );

                      final quantity = cartItemInCart.quantity;

                      final cartItem = CartItem(
                        id: variant.id,
                        productVariantId: variant.id.toString(),
                        name: variant.name,
                        sku: variant.sku,
                        price: variant.price,
                        quantity: 1,
                        productimage: variant.mediaUrl,
                      );

                      return Container(
                        decoration: BoxDecoration(
                          color: cWhite,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: Colors.transparent,
                            width: 2.w,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 16.r,
                              offset: Offset(0, 6.h),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            /// Image
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: EdgeInsets.all(4.w),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.r),
                                  child: Image.network(
                                    _normalizeImageUrl(variant.mediaUrl),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.image_not_supported),
                                  ),
                                ),
                              ),
                            ),

                            /// Name + Price + Quantity Controls
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 5.h,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  WText(
                                    text: variant.name,
                                    maxLines: 2,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11.sp,
                                    color: cBlack,
                                  ),
                                  SizedBox(height: 5.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      WText(
                                        text: "₹${variant.price}",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.sp,
                                        color: cBlack,
                                      ),

                                      quantity == 0
                                          ? GestureDetector(
                                              onTap: () async {
                                                await ref
                                                    .read(
                                                      cartProviders.notifier,
                                                    )
                                                    .addOrUpdateViaApi(
                                                      productVariantId: cartItem
                                                          .productVariantId,
                                                      quantity: 1,
                                                    );
                                              },
                                              child: _squareButton(
                                                icon: Icons.add,
                                                color: primaryThemeColor,
                                                filled: true,
                                              ),
                                            )
                                          : Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () async {
                                                    await ref
                                                        .read(
                                                          cartProviders
                                                              .notifier,
                                                        )
                                                        .decrementViaApi(
                                                          productVariantId:
                                                              variant.id
                                                                  .toString(),
                                                          currentQuantity:
                                                              quantity,
                                                        );
                                                  },
                                                  child: _squareButton(
                                                    icon: Icons.remove,
                                                    color: primaryThemeColor,
                                                    filled: false,
                                                  ),
                                                ),
                                                SizedBox(width: 10.w),
                                                Text(quantity.toString()),
                                                SizedBox(width: 10.w),
                                                GestureDetector(
                                                  onTap: () async {
                                                    await ref
                                                        .read(
                                                          cartProviders
                                                              .notifier,
                                                        )
                                                        .addOrUpdateViaApi(
                                                          productVariantId: cartItem
                                                              .productVariantId,
                                                          quantity:
                                                              quantity + 1,
                                                        );
                                                  },
                                                  child: _squareButton(
                                                    icon: Icons.add,
                                                    color: primaryThemeColor,
                                                    filled: true,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },

                /// 🔹 Shimmer loading effect
                loading: () => GridView.builder(
                  padding: EdgeInsets.only(
                    left: 10.w,
                    right: 10.w,
                    bottom: 80.h,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 15.w,
                    mainAxisSpacing: 10.h,
                    mainAxisExtent: 138.h,
                    crossAxisCount: 2,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) => Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: cWhite,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),

                error: (err, _) => Center(child: Text("Error: $err")),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Small square button widget
  Widget _squareButton({
    required IconData icon,
    required Color color,
    required bool filled,
  }) {
    return Container(
      height: 18.h,
      width: 18.h,
      decoration: BoxDecoration(
        border: Border.all(color: color),
        color: filled ? color : cWhite,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Icon(icon, color: filled ? cWhite : color, size: 16),
    );
  }
}

// Ensures image URLs have a scheme; defaults to https
String _normalizeImageUrl(String url) {
  final String trimmed = (url).trim();
  if (trimmed.isEmpty) return trimmed;
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  return 'https://' + trimmed;
}
