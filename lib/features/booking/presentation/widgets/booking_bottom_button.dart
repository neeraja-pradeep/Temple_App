import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple_app/core/app_colors.dart';
import 'package:temple_app/features/booking/data/booking_pooja_model.dart';

class BookingBottomButton extends StatelessWidget {
  final BookingPooja pooja;
  final int userId;
  final VoidCallback onBookingPressed;
  final bool isEnabled;

  const BookingBottomButton({
    super.key,
    required this.pooja,
    required this.userId,
    required this.onBookingPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
            onPressed: isEnabled
                ? onBookingPressed
                : () => _showErrorSnackbar(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: isEnabled ? AppColors.selected : Colors.grey,
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

  void _showErrorSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'ദയവായി ഒരു ഉപയോക്താവിനെ തിരഞ്ഞെടുക്കുക',
          style: TextStyle(fontSize: 14.sp),
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
