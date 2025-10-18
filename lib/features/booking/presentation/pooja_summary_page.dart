import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple_app/core/app_colors.dart';
import 'package:temple_app/core/theme/color/colors.dart';
import 'package:temple_app/features/booking/presentation/pooja_confirmed_page.dart';
import '../../booking/data/cart_model.dart';

import '../../booking/providers/booking_provider.dart';
// Removed unused imports after stopping state clearing on back

class PoojaSummaryPage extends ConsumerStatefulWidget {
  final int userId;

  const PoojaSummaryPage({super.key, required this.userId});

  @override
  ConsumerState<PoojaSummaryPage> createState() => _PoojaSummaryPageState();
}

class _PoojaSummaryPageState extends ConsumerState<PoojaSummaryPage> {
  @override
  void initState() {
    super.initState();
    // Invalidate cart provider to fetch fresh data every time
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(cartProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  onPressed: () {
                    Navigator.pop(context);
                  },
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

                // Print detailed cart item for debugging
                if (cartResponse.cart.isNotEmpty) {
                  final cartItem = cartResponse.cart.first;
                  print('🔍 Detailed Cart Item Debug:');
                  print('   Cart Item ID: ${cartItem.id}');
                  print('   Agent: ${cartItem.agent}');
                  print('   Agent Details: ${cartItem.agentDetails}');
                  print('   Status: ${cartItem.status}');
                  print('   Effective Price: ${cartItem.effectivePrice}');
                  print('   Full Cart Item JSON: ${cartItem.toString()}');
                }

                if (cartResponse.cart.isEmpty) {
                  return const Center(child: Text('No items in cart'));
                }

                final cartItem = cartResponse.cart.first;
                final totalParticipants = cartResponse.cart.length;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image
                    Image.asset(
                      'assets/background.jpg',
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

                                  // Participants Section
                                  _buildParticipants(
                                    cartItem,
                                    totalParticipants,
                                  ),
                                  SizedBox(height: 32.h),

                                  // Options/Status
                                  _buildOptionsStatus(context, cartItem),
                                  SizedBox(height: 32.h),

                                  // Total Amount
                                  _buildTotalAmount(
                                    cartItem,
                                    totalParticipants,
                                  ),

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
                    Icon(
                      Icons.error_outline,
                      size: 64.sp,
                      color: primaryThemeColor,
                    ),
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

  Widget _buildParticipants(CartItem cartItem, int totalParticipants) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Show number of participants
        _buildParticipantRow('', '$totalParticipants persons'),
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
              cartItem.agent != null
                  ? (cartItem.agentDetails != null &&
                            cartItem.agentDetails is Map<String, dynamic> &&
                            (cartItem.agentDetails
                                    as Map<String, dynamic>)['name'] !=
                                null
                        ? 'ഏജന്റ് കോഡ്: ${(cartItem.agentDetails as Map<String, dynamic>)['name']}'
                        : 'ഏജന്റ് കോഡ് applied')
                  : 'ഏജന്റ് കോഡ്',
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

  Widget _buildTotalAmount(CartItem cartItem, int totalParticipants) {
    // Calculate total price as effective price * number of persons
    final double effectivePrice = double.parse(cartItem.effectivePrice);
    final double totalPrice = effectivePrice * totalParticipants;

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
          '₹${totalPrice.toStringAsFixed(2)}',
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

  bool _cartHasRequiredNakshatram(CartResponse cartResponse) {
    for (final item in cartResponse.cart) {
      final attributes = item.userListDetails.attributes;
      if (attributes.isEmpty) {
        return false;
      }

      final hasNakshatram = attributes.any(
        (attr) =>
            attr.nakshatram != 0 || attr.nakshatramName.trim().isNotEmpty,
      );

      if (!hasNakshatram) {
        return false;
      }
    }
    return true;
  }

  Future<void> _showMissingNakshatramDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Details Needed'),
          content: const Text(
            'Please add the participant\'s nakshatram details under Saved Members before completing checkout.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleCheckout(BuildContext context, WidgetRef ref) async {
    var loadingDialogVisible = false;
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

      if (!_cartHasRequiredNakshatram(cartResponse)) {
        await _showMissingNakshatramDialog(context);
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
      loadingDialogVisible = true;

      // Call checkout API
      final checkoutResponse = await ref.read(checkoutProvider.future);

      // Print raw checkout API response
      print('💳 Raw Checkout API Response:');
      print(checkoutResponse);
      print('💳 Checkout Response Details:');
      print('   Order ID: ${checkoutResponse.orderId}');
      print('   Razorpay Order ID: ${checkoutResponse.razorpayOrderId}');
      print('   Amount: ${checkoutResponse.amount}');
      print('   Currency: ${checkoutResponse.currency}');
      print('   Key: ${checkoutResponse.key}');

      // Hide loading indicator
      if (loadingDialogVisible) {
        Navigator.of(context).pop();
        loadingDialogVisible = false;
      }

      // Get cart data to pass to confirmed page
      final cartData = await ref.read(cartProvider.future);
      final cartItem = cartData.cart.isNotEmpty ? cartData.cart.first : null;
      final totalParticipants = cartData.cart.length;

      // Navigate to pooja confirmed page with checkout response and cart data
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PoojaConfirmedPage(
            checkoutResponse: checkoutResponse,
            userId: widget.userId,
            cartItem: cartItem,
            totalParticipants: totalParticipants,
          ),
        ),
      );
    } catch (e) {
      // Hide loading indicator
      if (loadingDialogVisible) {
        Navigator.of(context).pop();
      }

      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final errorString = e.toString();
          final friendlyMessage = errorString.contains('500') &&
                  errorString.contains('unexpected error')
              ? 'Checkout failed because required participant details are missing. Please update nakshatram information for the selected member and try again.'
              : 'Failed to checkout: $errorString';

          return AlertDialog(
            title: const Text('Message'),
            content: Text(friendlyMessage),
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

  // (intentionally left blank) — we no longer clear booking state on back
}
