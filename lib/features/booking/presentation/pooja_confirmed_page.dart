import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../booking/data/checkout_model.dart';
import '../../booking/data/cart_model.dart';
import '../../booking/providers/booking_provider.dart';
import '../../booking/providers/user_list_provider.dart';
import '../../booking/providers/booking_page_providers.dart';

class PoojaConfirmedPage extends ConsumerStatefulWidget {
  final CheckoutResponse checkoutResponse;
  final int userId;
  final CartItem? cartItem;
  final int totalParticipants;

  const PoojaConfirmedPage({
    super.key,
    required this.checkoutResponse,
    required this.userId,
    this.cartItem,
    this.totalParticipants = 1,
  });

  @override
  ConsumerState<PoojaConfirmedPage> createState() => _PoojaConfirmedPageState();
}

class _PoojaConfirmedPageState extends ConsumerState<PoojaConfirmedPage> {
  @override
  void initState() {
    super.initState();
    // Debug: Print checkout response details
    print('🔍 PoojaConfirmedPage - Checkout Response:');
    print('   Order ID: ${widget.checkoutResponse.orderId}');
    print('   Razorpay Order ID: ${widget.checkoutResponse.razorpayOrderId}');
    print('   Amount: ${widget.checkoutResponse.amount}');
    print('   Currency: ${widget.checkoutResponse.currency}');
    print('   Key: ${widget.checkoutResponse.key}');

    // Invalidate cart provider to fetch fresh data every time
    // Add a small delay to ensure the checkout has been processed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        ref.invalidate(cartProvider);
        print('🔄 Invalidated cart provider after checkout');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5DC), // Light brown background
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 60.h, // Increase toolbar height for top spacing
          leadingWidth: 64.w, // give extra space for left padding
          leading: Padding(
            padding: EdgeInsets.only(left: 16.w, top: 16.h), // Add top padding
            // child: Container(
            //   width: 40.w,
            //   height: 40.h,
            //   decoration: BoxDecoration(
            //     color: Color.fromRGBO(251, 239, 217, 1),
            //     borderRadius: BorderRadius.circular(8.r),
            //   ),
            //   child: Center(
            //     child: IconButton(
            //       icon: Image.asset(
            //         'assets/backIcon.png',
            //         width: 20.w,
            //         height: 20.h,
            //       ),
            //       onPressed: () => Navigator.pop(context),
            //       padding: EdgeInsets.zero,
            //       constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
            //     ),
            //   ),
            // ),
          ),
        ),
        body: Builder(
          builder: (context) {
            // Use passed cart data if available, otherwise show loading
            if (widget.cartItem == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    SizedBox(height: 16.h),
                    Text(
                      'Loading booking details...',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            final cartItem = widget.cartItem!;
            final totalParticipants = widget.totalParticipants;

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
                          padding: EdgeInsets.all(20.w),
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
                              SizedBox(height: 24.h),

                              // Booking Number
                              _buildInfoRow(
                                'ബുക്കിംഗ് നമ്പർ:',
                                widget
                                        .checkoutResponse
                                        .razorpayOrderId
                                        .isNotEmpty
                                    ? '#${widget.checkoutResponse.razorpayOrderId}'
                                    : '#${widget.checkoutResponse.orderId}',
                                12,
                              ),
                              SizedBox(height: 51.h),

                              // Pooja Name (prominent display without label)
                              Text(
                                cartItem.poojaDetails.name,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8.h),

                              // Date (without label)
                              Text(
                                _getDateDisplay(cartItem),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8.h),

                              // Number of Persons (without label)
                              Text(
                                '$totalParticipants persons',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 44.h),

                              // Total Amount
                              _buildInfoRow(
                                'ആകെതുക :',
                                '₹${_calculateTotalAmount(cartItem, totalParticipants)}',
                                20,
                              ),
                              SizedBox(height: 24.h),

                              // Payment Instructions
                              _buildPaymentInstructions(),
                            ],
                          ),
                        ),
                      ),
                      // Add bottom padding to prevent content from being hidden behind the fixed button
                      SizedBox(height: 100.h),
                    ],
                  ),
                ),

                // Fixed Return to Home Button at bottom
                Positioned(
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
                        onPressed: () {
                          // Clear all booking state before navigating to home
                          _clearAllBookingState();

                          // Navigate to home screen
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8C001A), // Dark red
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'ഹോം സ്ക്രീൻലേക്ക് മടങ്ങുക',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, int spSize) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: spSize.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          value,
          style: TextStyle(
            fontSize: spSize.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  String _getDateDisplay(CartItem cartItem) {
    if (cartItem.specialPoojaDateDetails != null) {
      // Special pooja - show Malayalam date
      return cartItem.specialPoojaDateDetails!.malayalamDate;
    } else if (cartItem.selectedDate != null) {
      // Regular pooja - format the date
      return _formatDate(cartItem.selectedDate!);
    }
    return 'Date not available';
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

  String _calculateTotalAmount(CartItem cartItem, int totalParticipants) {
    // Calculate total price as effective price * number of persons
    final double effectivePrice = double.parse(cartItem.effectivePrice);
    final double totalPrice = effectivePrice * totalParticipants;
    return totalPrice.toStringAsFixed(2);
  }

  Widget _buildPaymentInstructions() {
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
          'ഏജന്റ് കോഡ് ഉപയോഗിച്ച് കൗണ്ടറിൽ പണമടയ്ക്കണം',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _clearAllBookingState() {
    // Clear all booking-related providers

    // Reset family providers with userId
    ref.read(selectedUsersProvider(widget.userId).notifier).state = [];
    ref.read(visibleUsersProvider(widget.userId).notifier).state = [];

    // Reset calendar-related state
    ref.read(selectedCalendarDateProvider.notifier).state = null;
    ref.read(showCalendarProvider.notifier).state = false;

    // Reset participation and agent code state
    ref.read(isParticipatingPhysicallyProvider.notifier).state = false;
    ref.read(isAgentCodeProvider.notifier).state = false;
    ref.read(agentCodeProvider.notifier).state = '';

    // Invalidate providers that can be invalidated
    ref.invalidate(cartProvider);
    ref.invalidate(checkoutProvider);
    ref.invalidate(userListsProvider);

    print('🧹 Cleared all booking state and cache for user ${widget.userId}');
  }
}
