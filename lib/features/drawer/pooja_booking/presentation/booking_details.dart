import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple_app/core/app_colors.dart';
import 'package:temple_app/features/drawer/pooja_booking/data/booking_service.dart';
import 'package:temple_app/features/drawer/pooja_booking/presentation/widget/booking_card.dart';

class BookingDetails extends ConsumerStatefulWidget {
  const BookingDetails({super.key});

  @override
  ConsumerState<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends ConsumerState<BookingDetails> {
  String selectedFilter = "Upcoming"; // default tab must match API

  @override
  void initState() {
    super.initState();
    // Trigger initial fetch for the default filter after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.refresh(bookingOrdersProvider(selectedFilter));
    });
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(bookingOrdersProvider(selectedFilter));

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 60.h,
          leadingWidth: 64.w,
          leading: Padding(
            padding: EdgeInsets.only(left: 16.w, top: 16.h),
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color:AppColors.selectedBackground,
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
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Pooja Booking Details",
                style: TextStyle(fontFamily: "Poppins", fontSize: 16.sp),
              ),
              SizedBox(height: 10.h),
              // Filter buttons
              Container(
                width: double.infinity,
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildFilterButton("Upcoming")),
                    SizedBox(width: 8.w),
                    Expanded(child: _buildFilterButton("completed")),
                    SizedBox(width: 8.w),
                    Expanded(child: _buildFilterButton("cancelled")),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Booking list
              Expanded(
                child: ordersAsync.when(
                  data: (orders) {
                    if (orders.isEmpty) {
                      return const Center(child: Text("No orders found"));
                    }
                    return ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final booking = orders[index];
                        return BookingCard(
                          booking: booking,
                        ); // use the expandable card
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.selected,)),
                  error: (err, _) => Center(child: Text("Error: $err")),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String filter) {
    final isSelected = selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        if (selectedFilter == filter) return;
        setState(() => selectedFilter = filter);
        // Force refresh for the new filter
        ref.refresh(bookingOrdersProvider(selectedFilter));
      },
      child: Align(
        alignment: Alignment.center,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.selectedBackground
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
          ),
          alignment: Alignment.center,
          child: Text(
            filter[0].toUpperCase() + filter.substring(1),
            style: TextStyle(
              color: isSelected ? AppColors.selected : Colors.black,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
