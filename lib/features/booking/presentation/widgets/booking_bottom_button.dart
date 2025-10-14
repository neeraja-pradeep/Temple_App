import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple_app/core/app_colors.dart';
import 'package:temple_app/features/booking/data/booking_pooja_model.dart';

class BookingBottomButton extends StatelessWidget {
  final BookingPooja pooja;
  final int userId;
  final VoidCallback onBookingPressed;

  const BookingBottomButton({
    super.key,
    required this.pooja,
    required this.userId,
    required this.onBookingPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.transparent,
          // r
        ),
        child: SizedBox(
          width: double.infinity,
          height: 40.h,
          child: ElevatedButton(
            onPressed: onBookingPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.selected,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'പൂജ ബുക്ക് ചെയ്യുക',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
