import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple/core/constants/sized.dart';
import 'package:temple/core/theme/color/colors.dart';
import 'package:temple/features/shop/cart/providers/checkout_provider.dart';
import 'package:temple/features/shop/data/model/product/product_category.dart';
import 'package:temple/features/shop/providers/categoryRepo_provider.dart';
import 'package:temple/widgets/mytext.dart';

class CategoryProductGridSection extends ConsumerWidget {
  const CategoryProductGridSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fetchCategoryProducts = ref.watch(categoryProductProvider);

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

                  /// Flatten → products → variants
                  final allVariants = products
                      .expand((product) => product.variants.map((variant) => {
                            "product": product,
                            "variant": variant,
                          }))
                      .toList();

                  return GridView.builder(
                    padding: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 80.h),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: 15.w,
                      mainAxisSpacing: 10.h,
                      mainAxisExtent: 138.h,
                      crossAxisCount: 2,
                    ),
                    itemCount: allVariants.length,
                    itemBuilder: (context, index) {
                      final variant = allVariants[index]["variant"] as VariantModel;

                      return Container(
                        decoration: BoxDecoration(
                          color: cWhite,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: Colors.transparent, width: 2.w),
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
                                child: Image.network(
                                  variant.mediaUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.image_not_supported),
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      WText(
                                        text: "₹${variant.price}",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.sp,
                                        color: cBlack,
                                      ),

                                      /// Quantity buttons
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              ref.read(cartProvider.notifier).removeItem(variant.id.toString());
                                            },
                                            child: _squareButton(
                                              icon: Icons.remove,
                                              color: primaryThemeColor,
                                              filled: false,
                                            ),
                                          ),
                                          AppSizes.w10,
                                          Consumer(
                                            builder: (context, ref, _) {
                                              final cart = ref.watch(cartProvider);
                                              final quantity = cart[variant.id.toString()] ?? 0;
                                              return Text(quantity.toString());
                                            },
                                          ),
                                          AppSizes.w10,
                                          GestureDetector(
                                            onTap: () {
                                              ref.read(cartProvider.notifier).addItem(variant.id.toString());
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
                loading: () => const Center(child: CircularProgressIndicator()),
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
