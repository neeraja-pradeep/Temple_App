import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple_app/core/app_colors.dart';
import 'package:temple_app/features/drawer/store_order/data/order_service.dart';
import 'package:temple_app/features/drawer/store_order/presentation/widget/order_card.dart';

class OrderDetails extends ConsumerStatefulWidget {
  const OrderDetails({super.key});

  @override
  ConsumerState<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends ConsumerState<OrderDetails> {
  String selectedFilter = "pending"; // default

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.refresh(storeOrdersProvider(selectedFilter));
    });
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(storeOrdersProvider(selectedFilter));

    return Scaffold(
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
              color: AppColors.selectedBackground,
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
              "Orders",
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
                  Expanded(child: _buildFilterButton("pending", "Upcoming")),
                  SizedBox(width: 8.w),
                  Expanded(child: _buildFilterButton("delivered", "Delivered")),
                  SizedBox(width: 8.w),
                  Expanded(child: _buildFilterButton("cancelled", "Cancelled")),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Orders list
            Expanded(
              child: ordersAsync.when(
                data: (orders) {
                  if (orders.results.isEmpty) {
                    return const Center(child: Text("No orders found"));
                  }
                  return ListView.builder(
                    itemCount: orders.results.length,
                    itemBuilder: (context, index) {
                      final order = orders.results[index];
                      return OrderCard(order: order);
                    },
                  );
                },
                loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.selected)),
                error: (err, _) => Center(child: Text("Error: $err")),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String value, String label) {
    final isSelected = selectedFilter == value;
    return GestureDetector(
      onTap: () {
        if (selectedFilter == value) return;
        setState(() => selectedFilter = value);
        ref.refresh(storeOrdersProvider(selectedFilter));
      },
      child: Align(
        alignment: Alignment.center,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.selectedBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
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
