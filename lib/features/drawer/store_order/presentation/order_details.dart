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
  String selectedFilter = "pending";
  String? currentPageUrl; // for pagination
  int currentPageNumber = 1;

  @override
  void initState() {
    super.initState();
    currentPageUrl = null; // first page
    currentPageNumber = 1;
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(
      storeOrdersPageProvider((selectedFilter, currentPageUrl)),
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBackButton(context),
              Text(
                "Store Orders Details",
                style: TextStyle(fontFamily: "Poppins", fontSize: 16.sp),
              ),
              SizedBox(height: 10.h),

              // Filter buttons
              _buildFilterRow(),

              SizedBox(height: 10.h),

              // Orders list
              Expanded(
                child: ordersAsync.when(
                  data: (orders) {
                    if (orders.results.isEmpty) {
                      return const Center(child: Text("No orders found"));
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          currentPageUrl = null;
                          currentPageNumber = 1;
                        });
                        ref.invalidate(
                          storeOrdersPageProvider((selectedFilter, currentPageUrl)),
                        );
                      },
                      child: ListView.builder(
                        itemCount: orders.results.length,
                        itemBuilder: (context, index) {
                          final order = orders.results[index];
                          return OrderCard(order: order);
                        },
                      ),
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.selected),
                  ),
                  error: (err, _) => Center(
                    child: Text("⚠️ Error loading orders: $err"),
                  ),
                ),
              ),
              SizedBox(height: 10.h),

              // Pagination with page number
              ordersAsync.maybeWhen(
                data: (orders) => _buildPaginationRow(
                  previousUrl: orders.previous,
                  nextUrl: orders.next,
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.h, bottom: 16.h),
      child: Container(
        width: 45.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: AppColors.selectedBackground,
          borderRadius: BorderRadius.circular(8.r),
        ),
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
    );
  }

  Widget _buildFilterRow() {
    return Container(
      width: double.infinity,
      height: 50.h,
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
    );
  }

  Widget _buildFilterButton(String value, String label) {
    final isSelected = selectedFilter == value;
    return GestureDetector(
      onTap: () {
        if (selectedFilter == value) return;
        setState(() {
          selectedFilter = value;
          currentPageUrl = null;
          currentPageNumber = 1;
        });
        ref.invalidate(
          storeOrdersPageProvider((selectedFilter, currentPageUrl)),
        );
      },
      child: Align(
        alignment: Alignment.center,
        child: Container(
          height: 32.h,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.selectedBackground
                : Colors.transparent,
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

  Widget _buildPaginationRow({
    required String? previousUrl,
    required String? nextUrl,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (previousUrl != null)
          _paginationButton(
            iconPath: 'assets/backIcon.png',
            onTap: () {
              setState(() {
                currentPageUrl = previousUrl;
                currentPageNumber = (currentPageNumber > 1)
                    ? currentPageNumber - 1
                    : 1;
              });
              ref.invalidate(
                storeOrdersPageProvider((selectedFilter, currentPageUrl)),
              );
            },
          ),
        SizedBox(width: 15.w),
        Text(
          "$currentPageNumber",
          style: TextStyle(fontFamily: "Poppins",),
        ),
        SizedBox(width: 15.w),
        if (nextUrl != null)
          _paginationButton(
            iconPath: 'assets/nextIcon.png',
            onTap: () {
              setState(() {
                currentPageUrl = nextUrl;
                currentPageNumber += 1;
              });
              ref.invalidate(
                storeOrdersPageProvider((selectedFilter, currentPageUrl)),
              );
            },
          ),
      ],
    );
  }

  Widget _paginationButton({
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 45.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: AppColors.selectedBackground,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Center(
        child: IconButton(
          icon: Image.asset(
            iconPath,
            width: 20.w,
            height: 20.h,
          ),
          onPressed: onTap,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
        ),
      ),
    );
  }
}
