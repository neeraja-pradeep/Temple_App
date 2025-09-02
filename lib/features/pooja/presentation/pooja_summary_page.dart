import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple/core/app_colors.dart';
import '../../booking/data/cart_model.dart';
import '../../booking/providers/booking_provider.dart';

class PoojaSummaryPage extends ConsumerWidget {
  const PoojaSummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5DC), // Light brown background
        appBar: AppBar(
          backgroundColor: const Color(0xFF424242), // Dark grey header
          elevation: 0,
          title: const Text(
            'Pooja summary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: Container(
            margin: EdgeInsets.only(left: 16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF5E6B3), // Light beige
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        body: Consumer(
          builder: (context, ref, child) {
            final cartAsync = ref.watch(cartProvider);

            return cartAsync.when(
              data: (cartResponse) {
                if (cartResponse.cart.isEmpty) {
                  return const Center(child: Text('No items in cart'));
                }

                final cartItem = cartResponse.cart.first;
                return SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
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
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Center(
                                child: Text(
                                  'പൂജാ വിശദാംശങ്ങൾ',
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              SizedBox(height: 24.h),

                              // Pooja Details
                              _buildPoojaDetails(cartItem),
                              SizedBox(height: 24.h),

                              // Participants
                              _buildParticipants(cartItem),
                              SizedBox(height: 24.h),

                              // Options/Status
                              _buildOptionsStatus(cartItem),
                              SizedBox(height: 24.h),

                              // Total Amount
                              _buildTotalAmount(cartItem),
                              SizedBox(height: 24.h),

                              // Payment Instructions
                              _buildPaymentInstructions(cartItem),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Book Button
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle booking action
                            print('Book button pressed');
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
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF8C001A), // Dark red
          ),
        ),
        SizedBox(height: 8.h),

        // Pooja type
        Text(
          cartItem.poojaDetails.categoryName,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8C001A), // Dark red
          ),
        ),
        SizedBox(height: 8.h),

        // Date information
        if (cartItem.specialPoojaDateDetails != null) ...[
          // Date in Malayalam
          Text(
            cartItem.specialPoojaDateDetails!.malayalamDate,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4.h),

          // Date in English
          Text(
            _formatDate(cartItem.specialPoojaDateDetails!.date),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ] else if (cartItem.selectedDate != null) ...[
          // Regular pooja date
          Text(
            _formatDate(cartItem.selectedDate!),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
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
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            nakshatram,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsStatus(CartItem cartItem) {
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

        // Physical participation checkbox
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
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Agent code checkbox
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
              'ഏജന്റ് കോഡ് applied',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalAmount(CartItem cartItem) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'ആകെതുക :',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF8C001A), // Dark red
          ),
        ),
        Text(
          '₹${cartItem.effectivePrice}',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF8C001A), // Dark red
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
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          cartItem.agent != null
              ? 'Agent code ഉപയോഗിച്ചതിനാൽ, ഓൺലൈനായി പണമടയ്ക്കേണ്ടതില്ല.'
              : 'ഓൺലൈനായി പണമടയ്ക്കണം.',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
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
}
