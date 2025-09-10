import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple/core/app_colors.dart';
import 'package:temple/features/shop/data/models/shop_product_models.dart';
import 'package:temple/features/shop/data/models/cart_models.dart';
import 'package:temple/features/shop/providers/shop_providers.dart';

class ShopPage extends ConsumerWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(shopCategoriesProvider);
    final productsAsync = ref.watch(shopProductsByCategoryProvider);
    final int? selectedIndex = ref.watch(selectedCategoryIndexProvider);
    final cartQuantities = ref.watch(cartQuantitiesProvider);

    // Check if there are any items in cart
    final hasItemsInCart = cartQuantities.values.any(
      (quantity) => quantity > 0,
    );

    return Stack(
      children: [
        // Main content
        Padding(
          padding: EdgeInsets.only(top: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              // Horizontal categories
              SizedBox(
                height: 110.h,
                child: categoriesAsync.when(
                  data: (categories) {
                    if (categories.isEmpty) {
                      return const SizedBox();
                    }
                    return ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isSelected = index == selectedIndex;
                        return GestureDetector(
                          onTap: () {
                            final current = ref.read(
                              selectedCategoryIndexProvider,
                            );
                            ref
                                .read(selectedCategoryIndexProvider.notifier)
                                .state = (current == index)
                                ? null
                                : index;
                            ref.invalidate(shopProductsByCategoryProvider);
                          },
                          child: Container(
                            width: 120.w,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.selected
                                    : Colors.transparent,
                              ),
                            ),
                            padding: EdgeInsets.all(8.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: Image.network(
                                      cat.mediaUrl ?? '',
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => Image.asset(
                                        'assets/fallBack.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  cat.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => SizedBox(width: 10.w),
                      itemCount: categories.length,
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox(),
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 6.h),
                child: Text(
                  'Common Pooja items',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),

              // Grid of products
              Expanded(
                child: productsAsync.when(
                  data: (products) {
                    if (products.isEmpty) return const SizedBox();
                    return GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.w,
                        mainAxisSpacing: 10.h,
                        mainAxisExtent: 230.h,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final ProductVariant? variant =
                            product.variants.isNotEmpty
                            ? product.variants.first
                            : null;

                        if (variant == null) return const SizedBox();

                        final quantity = cartQuantities[variant.id] ?? 0;

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12.r),
                                    topRight: Radius.circular(12.r),
                                  ),
                                  child: Image.network(
                                    variant.mediaUrl ?? '',
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Image.asset(
                                      'assets/fallBack.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '₹${variant.price}',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        if (quantity == 0)
                                          GestureDetector(
                                            onTap: () =>
                                                _addToCart(ref, variant.id),
                                            child: Container(
                                              height: 24.h,
                                              width: 24.h,
                                              decoration: BoxDecoration(
                                                color: AppColors.selected,
                                                borderRadius:
                                                    BorderRadius.circular(6.r),
                                              ),
                                              child: const Icon(
                                                Icons.add,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          )
                                        else
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () => _decrementQuantity(
                                                  ref,
                                                  variant.id,
                                                ),
                                                child: Container(
                                                  height: 24.h,
                                                  width: 24.h,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.selected,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6.r,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.remove,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8.w),
                                              Text(
                                                quantity.toString(),
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              SizedBox(width: 8.w),
                                              GestureDetector(
                                                onTap: () => _incrementQuantity(
                                                  ref,
                                                  variant.id,
                                                ),
                                                child: Container(
                                                  height: 24.h,
                                                  width: 24.h,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.selected,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6.r,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.add,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
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
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox(),
                ),
              ),
            ],
          ),
        ),
        // Checkout button overlay
        hasItemsInCart
            ? Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(color: Colors.transparent),
                  child: SizedBox(
                    width: double.infinity,
                    height: 40.h,
                    child: ElevatedButton(
                      onPressed: () => _checkout(ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.selected,
                        foregroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Checkout',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }

  void _addToCart(WidgetRef ref, int variantId) {
    // Set quantity to 1 and add to cart
    ref.read(cartQuantitiesProvider.notifier).state = {
      ...ref.read(cartQuantitiesProvider),
      variantId: 1,
    };

    // Make API call
    final request = AddToCartRequest(productVariantId: variantId, quantity: 1);
    ref.read(addToCartProvider(request));
  }

  void _incrementQuantity(WidgetRef ref, int variantId) {
    final currentQuantities = ref.read(cartQuantitiesProvider);
    final currentQuantity = currentQuantities[variantId] ?? 0;
    final newQuantity = currentQuantity + 1;

    ref.read(cartQuantitiesProvider.notifier).state = {
      ...currentQuantities,
      variantId: newQuantity,
    };

    // Make API call
    final request = AddToCartRequest(
      productVariantId: variantId,
      quantity: newQuantity,
    );
    ref.read(addToCartProvider(request));
  }

  void _decrementQuantity(WidgetRef ref, int variantId) {
    final currentQuantities = ref.read(cartQuantitiesProvider);
    final currentQuantity = currentQuantities[variantId] ?? 0;

    if (currentQuantity <= 1) {
      // Remove from cart
      final newQuantities = Map<int, int>.from(currentQuantities);
      newQuantities.remove(variantId);
      ref.read(cartQuantitiesProvider.notifier).state = newQuantities;
    } else {
      // Decrement quantity
      final newQuantity = currentQuantity - 1;
      ref.read(cartQuantitiesProvider.notifier).state = {
        ...currentQuantities,
        variantId: newQuantity,
      };
    }

    // Make API call
    final request = AddToCartRequest(
      productVariantId: variantId,
      quantity: currentQuantity <= 1 ? 0 : currentQuantity - 1,
    );
    ref.read(addToCartProvider(request));
  }

  void _checkout(WidgetRef ref) async {
    final cartQuantities = ref.read(cartQuantitiesProvider);

    print('🛒 CHECKOUT STARTED:');
    print('Cart Quantities: $cartQuantities');
    print(
      'Total Items: ${cartQuantities.values.fold(0, (sum, qty) => sum + qty)}',
    );
    print('Total Variants: ${cartQuantities.length}');

    try {
      // Send all cart items to the API
      for (final entry in cartQuantities.entries) {
        if (entry.value > 0) {
          print(
            '🛒 Sending item - Variant ID: ${entry.key}, Quantity: ${entry.value}',
          );
          final request = AddToCartRequest(
            productVariantId: entry.key,
            quantity: entry.value,
          );
          await ref.read(addToCartProvider(request).future);
        }
      }

      print('🛒 ALL ITEMS SENT SUCCESSFULLY');

      // Reset cart quantities after successful checkout
      ref.read(cartQuantitiesProvider.notifier).state = {};
      print('🛒 CART RESET TO EMPTY');

      // Show success message
      ScaffoldMessenger.of(ref.context).showSnackBar(
        SnackBar(
          content: Text(
            'Checkout completed! ${cartQuantities.values.fold(0, (sum, qty) => sum + qty)} items sent to cart.',
          ),
          backgroundColor: AppColors.selected,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('🛒 CHECKOUT ERROR: $e');
      // Show error message if checkout fails
      ScaffoldMessenger.of(ref.context).showSnackBar(
        SnackBar(
          content: Text('Checkout failed. Please try again.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
