import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:temple_app/core/app_colors.dart';
import 'package:temple_app/features/drawer/store_order/data/order_model.dart';

class OrderDetailedView extends StatelessWidget {
  final StoreOrder order;

  const OrderDetailedView({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final orderDate = DateTime.parse(order.createdAt);
    final formattedDate = DateFormat('yyyy/MM/dd').format(orderDate);

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
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(10.h),
          child: SingleChildScrollView(
            child: Container(
              width: 343.w,
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text("Order Details",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                  SizedBox(height: 20.h),
      
                  /// ORDER INFO
                  Text("Order ID: ${order.id}",
                      style: TextStyle(
                        color: AppColors.selected,
                          fontWeight: FontWeight.w700, 
                          fontSize: 16.sp)),
                  Text("Order Date: ${order.createdAt.split('T').first}",
                      style: TextStyle(
                          fontFamily: "Poppins",
                          color: Colors.grey,
                          fontSize: 12.sp)),
      
                  SizedBox(height: 20.h),
      
                  /// PRODUCTS
                  ...order.lines.map((line) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Text(
                          "${line.productVariant.product.name}  -  ${line.quantity}",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12.sp)),
                    );
                  }),
      
                  SizedBox(height: 20.h),
      
                  /// PAYMENT INFO
                  SizedBox(height: 8.h),
                  Text("Payment ID: ${order.razorpayOrderId ?? '-'}",
                      style: TextStyle(
                         fontSize: 12.sp,
                        color: Colors.grey)),
                  Text("Payment date:  $formattedDate",
                      style:TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey)),
                  Text("Total Amount: ₹${order.total}",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                        color: Colors.black87)),
                  Text("Payment ${order.status}",
                      style: TextStyle(
                         fontSize: 12.sp,
                        color: Colors.grey)),
                  Text("Payment Gateway: ${order.razorpaySignature?? 'N/A'}",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey)),
      
                  SizedBox(height: 20.h),
      
                  /// SHIPPING INFO
                  Text("Address",
                      style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 12.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.w700)),
                  Text(
                    "${order.shippingAddress?.street}, ${order.shippingAddress?.city}",
                    style: TextStyle(
                       fontSize: 12.sp,
                      color: Colors.grey),
                  ),
      
                  SizedBox(height: 20.h),
      
                  
                  Text("Tracking info: [Available Soon]",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12.sp,
                  ),),
      
                  SizedBox(height: 30.h),
      
                  /// CONTACT US
                  Text("Contact Us",
                      style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w400,
                          color: Colors.grey))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
