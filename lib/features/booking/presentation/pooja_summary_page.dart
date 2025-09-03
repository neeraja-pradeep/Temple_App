import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple/core/app_colors.dart';
import 'package:temple/features/booking/presentation/pooja_confirmed_page.dart';
import '../../booking/data/cart_model.dart';
import '../../booking/providers/booking_provider.dart';
import '../../booking/data/checkout_model.dart';

class PoojaSummaryPage extends ConsumerWidget {
  const PoojaSummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5DC), // Light brown background
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          toolbarHeight: 60.h, // Increase toolbar height for top spacing
          backgroundColor: Colors.transparent,
          elevation: 0,
          leadingWidth: 64.w, // give extra space for left padding
          leading: Padding(
            padding: EdgeInsets.only(
              left: 16.w,
              top: 16.h,
            ), // shift container inward
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: Color.fromRGBO(251, 239, 217, 1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: IconButton(
                  icon: Image.asset(
                    'assets/backIcon.png',
                    width: 20.w,
                    height: 20.h,
                  ),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
                ),
              ),
            ),
          ),
        ),
        body: Consumer(
          builder: (context, ref, child) {
            final cartAsync = ref.watch(cartProvider);

            return cartAsync.when(
              data: (cartResponse) {
                // Print raw cart API response
                print('🛒 Raw Cart API Response:');
                print(cartResponse);

                if (cartResponse.cart.isEmpty) {
                  return const Center(child: Text('No items in cart'));
                }

                final cartItem = cartResponse.cart.first;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image
                    Image.asset(
                      'assets/background.png',
                      fit: BoxFit.cover,
                      height: double.infinity,
                      width: double.infinity,
                      alignment: Alignment.topCenter,
                    ),

                    // Content
                    SingleChildScrollView(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        children: [
                          SizedBox(height: 64.h), // Add top spacing for app bar
                          // Main white card
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8.r,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 21.w,
                                right: 21.w,
                                top: 17.h,
                                bottom: 17.h,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title
                                  Center(
                                    child: Text(
                                      'പൂജാ വിശദാംശങ്ങൾ',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 32.h),

                                  // Pooja Details
                                  _buildPoojaDetails(cartItem),
                                  SizedBox(height: 32.h),

                                  // Participants
                                  _buildParticipants(cartItem),
                                  SizedBox(height: 32.h),

                                  // Options/Status
                                  _buildOptionsStatus(context, cartItem),
                                  SizedBox(height: 32.h),

                                  // Total Amount
                                  _buildTotalAmount(cartItem),

                                  // Payment Instructions
                                  _buildPaymentInstructions(cartItem),
                                ],
                              ),
                            ),
                          ),
                          // Add bottom padding to prevent content from being hidden behind the fixed button
                          // SizedBox(height: 100.h),
                        ],
                      ),
                    ),

                    // Fixed Book Button at bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.transparent, // Match background color
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: Colors.black.withOpacity(0.1),
                          //     blurRadius: 8.r,
                          //     offset: const Offset(0, 2),
                          //   ),
                          // ],
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 40.h,
                          child: ElevatedButton(
                            onPressed: () async {
                              // Handle checkout process
                              await _handleCheckout(context, ref);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFF8C001A,
                              ), // Dark red
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              'ബുക്ക്',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                    SizedBox(height: 16.h),
                    Text(
                      'Failed to load cart',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      error.toString(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPoojaDetails(CartItem cartItem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pooja name
        Text(
          cartItem.poojaDetails.name,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.selected, // Dark red
          ),
        ),
        SizedBox(height: 8.h),

        // Pooja type
        Text(
          cartItem.poojaDetails.categoryName,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.selected, // Dark red
          ),
        ),
        SizedBox(height: 8.h),

        // Date information
        if (cartItem.specialPoojaDateDetails != null) ...[
          // Date in Malayalam
          Text(
            cartItem.specialPoojaDateDetails!.malayalamDate,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.h),

          // Date in English
          Text(
            _formatDate(cartItem.specialPoojaDateDetails!.date),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
            ),
          ),
        ] else if (cartItem.selectedDate != null) ...[
          // Regular pooja date
          Text(
            _formatDate(cartItem.selectedDate!),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildParticipants(CartItem cartItem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show user list details
        _buildParticipantRow(
          cartItem.userListDetails.name,
          cartItem.userListDetails.attributes.isNotEmpty
              ? cartItem.userListDetails.attributes.first.nakshatramName
              : 'No nakshatram',
        ),
      ],
    );
  }

  Widget _buildParticipantRow(String name, String nakshatram) {
    return Container(
      // padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      // decoration: BoxDecoration(
      //   color: Colors.grey[50],
      //   borderRadius: BorderRadius.circular(8.r),
      //   border: Border.all(color: Colors.grey[200]!),
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            nakshatram,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsStatus(BuildContext context, CartItem cartItem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   'Options:',
        //   style: TextStyle(
        //     fontSize: 16.sp,
        //     fontWeight: FontWeight.w600,
        //     color: Colors.black87,
        //   ),
        // ),
        // SizedBox(height: 12.h),

        // Physical participation checkbox (read-only)
        Row(
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: cartItem.status
                    ? const Color(0xFF8C001A)
                    : Colors.transparent,
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: cartItem.status
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            SizedBox(width: 12.w),
            Text(
              'ഭൗതികമായി പങ്കെടുക്കുന്നു',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Agent code (read-only)
        Row(
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: cartItem.agent != null
                    ? const Color(0xFF8C001A)
                    : Colors.transparent,
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: cartItem.agent != null
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            SizedBox(width: 12.w),
            Text(
              cartItem.agent != null ? 'ഏജന്റ് കോഡ് applied' : 'ഏജന്റ് കോഡ്',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalAmount(CartItem cartItem) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'ആകെതുക :',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black, // Dark red
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          '₹${cartItem.effectivePrice}',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black, // Dark red
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentInstructions(CartItem cartItem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'പൂജ നടത്തപ്പെടുന്നതിന് മുമ്പായി കൗണ്ടറിൽ പണമടയ്ക്കണം.',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
        ),
        Text(
          cartItem.agent != null
              ? 'Agent code ഉപയോഗിച്ചതിനാൽ, ഓൺലൈനായി പണമടയ്ക്കേണ്ടതില്ല.'
              : 'ഓൺലൈനായി പണമടയ്ക്കണം.',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      final List<String> months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];

      final String month = months[date.month - 1];
      final int day = date.day;
      final int year = date.year;

      return '$month $day, $year';
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _handleCheckout(BuildContext context, WidgetRef ref) async {
    try {
      // Check if cart has items
      final cartResponse = await ref.read(cartProvider.future);
      if (cartResponse.cart.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text(
                'Cart must contain poojas in order to checkout.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Call checkout API
      final checkoutResponse = await ref.read(checkoutProvider.future);

      // Print raw checkout API response
      print('💳 Raw Checkout API Response:');
      print(checkoutResponse);

      // Hide loading indicator
      Navigator.of(context).pop();

      // Get cart data to pass to confirmed page
      final cartData = await ref.read(cartProvider.future);
      final cartItem = cartData.cart.first;

      // Navigate to pooja confirmed page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PoojaConfirmedPage(
            checkoutResponse: checkoutResponse,
            cartItem: cartItem,
          ),
        ),
      );
    } catch (e) {
      // Hide loading indicator
      Navigator.of(context).pop();

      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to checkout: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
