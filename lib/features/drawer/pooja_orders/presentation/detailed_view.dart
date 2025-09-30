import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple_app/core/app_colors.dart';
import 'package:temple_app/features/drawer/pooja_orders/order_model.dart';
import 'package:intl/intl.dart';

class DetailedView extends StatelessWidget {
  final Booking booking;

  const DetailedView({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final firstLine = booking.orderLines.first;
    final poojaName = firstLine.poojaDetails!.name;
    final dateFormat = DateFormat('yyyy-MM-dd – kk:mm');

    return Scaffold(
      backgroundColor: AppColors.navBarBackground,
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
              color: const Color.fromRGBO(251, 239, 217, 1),
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
        padding: EdgeInsets.all(10.h),
        child: Column(
          children: [
            
            Container(
              width: 343.w,
              //height: 462,
              margin: const EdgeInsets.only(top: 68),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text("പൂജാ വിശദാംശങ്ങൾ",
                         style: TextStyle(
                         fontSize: 12.sp
                         ),),
                    ),
                    SizedBox(height: 20.h,),
                    Text(
                      "ബുക്കിംഗ് നമ്പർ:${booking.id}",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp),
                    ),
                    Text(
                      "Booking Date: ${booking.createdAt!.split('T').first}",
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        color: Colors.grey,
                        fontWeight: FontWeight.w400, fontSize: 12),
                    ),
                    SizedBox(height: 15.h,),

                    Text(
                      poojaName!,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 16.sp,
                        color: AppColors.selected,
                        fontWeight: FontWeight.w700),
                    ),
                    Text("Special Pooja",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      color: Colors.grey,
                      fontWeight: FontWeight.w400, fontSize: 12
                    ),),
                    SizedBox(height: 6.h),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: booking.orderLines.map((line) {
                        final userName = line.userListDetails!.name;
                        final nakshatra = line.userAttributeDetails!.nakshatramName;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text("$userName - $nakshatra",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400
                          ),),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20.h,),
            
                    // Payment Details
                    Text(
                      "Payment ID: ${booking.razorpayPaymentId ?? '  -'}",
                      
                      style:TextStyle(fontSize: 12.sp,
                      fontFamily: "Poppins",
                      color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Payment Date: ${booking.razorpayPaymentId != null ? dateFormat.format(DateTime.parse(booking.modifiedAt!)) : '  -'}",
                      style: TextStyle(fontSize: 12.sp,
                      fontFamily: "Poppins",
                      color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "ആകെതുക :${booking.total}",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Payment ${booking.statusDisplay}",
                      style: TextStyle(fontSize: 12.sp,
                      fontFamily: "Poppins",
                      color: Colors.grey),
                    ),

                    Text(
                      "Payment gateway : RazorPay / UPI etc",
                      style: TextStyle(fontSize: 12.sp,
                      fontFamily: "Poppins",
                      color: Colors.grey),
                    ),
                    SizedBox(height: 20.h,),

                    
if (booking.orderLines.any((line) => line.isCancelled!)) ...[
  const SizedBox(height: 20),
  Text("cancelled",
  style: TextStyle(
    fontSize: 12.sp,
    fontFamily: "Poppins",
    fontWeight: FontWeight.w600,
  ),),
  Text(
    "Refund ID: ${booking.razorpayRefundId ?? '-'}",
    style: TextStyle(
      fontFamily: "Poppins",
      fontSize: 12.sp, color: Colors.grey),
  ),
  Text(
    "Refund Date: ${booking.razorpayRefundId != null ? dateFormat.format(DateTime.parse(booking.modifiedAt!)) : '-'}",
    style: TextStyle(
      fontFamily: "Poppins",
      fontSize: 12.sp, color: Colors.grey),
  ),
  Text(
    "Refund Amount: ${booking.refundAmount}",
    style: TextStyle(
      fontFamily: "Poppins",
      fontSize: 12.sp, fontWeight: FontWeight.w700),
  ),
  Text(
    "Refund Status: ${booking.refundStatusDisplay}",
    style: TextStyle(
      fontFamily: "Poppins",
      fontSize: 12.sp, color: Colors.grey),
  ),
  
]

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
