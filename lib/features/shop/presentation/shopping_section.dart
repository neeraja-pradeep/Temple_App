import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temple/features/shop/cart/providers/cart_provider.dart';
import 'package:temple/features/shop/presentation/app_bar.dart';
import 'package:temple/features/shop/presentation/category_listing.dart';
import 'package:temple/features/shop/presentation/category_productSection.dart';
import 'package:temple/features/shop/providers/gesture_riverpod.dart';
import 'package:temple/features/shop/widget/checkout_button.dart';

class ShoppingSectionScreeen extends ConsumerWidget {
  const ShoppingSectionScreeen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProviders);
    final selectedIndex2 = ref.watch(selectedIndexCatProvider);
    // final checkbutton = ref.watch(checkoutButtonTurnON);

    return Stack(
      children: [
        /// Main content
        Column(
          children: [
            // ---------------- AppBar Section ----------------
            AppBarSection(
              onPressed: () {
                ref.read(onclickCheckoutButton.notifier).state = true;
              },
            ),

            // ---------------- Horizontal Category Section ----------------
            ShopCategorySection(selectedIndex: selectedIndex2),

            // ---------------- Grid Section ----------------
            CategoryProductGridSection(),
          ],
        ),
        cartItems.isNotEmpty
            ? CheckoutButton(
                onPressed: () {
                  ref.read(onclickCheckoutButton.notifier).state = true;
                },
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
