import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple_app/core/app_colors.dart';
import 'package:temple_app/features/booking/data/booking_pooja_model.dart';

class BookingInfoCard extends StatelessWidget {
  final BookingPooja pooja;
  final String? source;
  final String? malayalamDate;
  final VoidCallback? onCalendarTap;
  final String? selectedDate;

  const BookingInfoCard({
    super.key,
    required this.pooja,
    this.source,
    this.malayalamDate,
    this.onCalendarTap,
    this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pooja Name with Calendar Icon (conditional)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  pooja.name,
                  style: TextStyle(
                    fontFamily: 'NotoSansMalayalam',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.selected,
                  ),
                ),
              ),
              // Only show calendar icon if not coming from PoojaPage
              if (source != 'pooja') ...[
                GestureDetector(
                  onTap: onCalendarTap,
                  child: Image.asset(
                    'assets/calendar.png',
                    width: 20.w,
                    height: 20.h,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 8.h),
          // Show selected date when coming from PoojaPage
          if (source == 'pooja') ...[
            if (selectedDate != null) ...[
              // Malayalam date passed from PoojaPage in black
              Text(
                malayalamDate ?? _formatDate(selectedDate!),
                style: TextStyle(
                  fontFamily: 'NotoSansMalayalam',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 2.h),
              // English date in grey
              Text(
                _formatDate(selectedDate!),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ],
          // Date Information (only show when not from PoojaPage)
          if (source != 'pooja') ...[
            if (pooja.specialPooja && pooja.specialPoojaDates.isNotEmpty) ...[
              // Special Pooja - Show selected date or first available date
              if (selectedDate != null) ...[
                // Show selected date
                _buildSelectedDateDisplay(selectedDate!),
              ] else ...[
                // Show first available date as placeholder
                Text(
                  pooja.specialPoojaDates.first.malayalamDate,
                  style: TextStyle(
                    fontFamily: 'NotoSansMalayalam',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _formatDate(pooja.specialPoojaDates.first.date),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8.h),
              ],
            ] else if (!pooja.specialPooja) ...[
              // Regular Pooja - Show instruction to select date
              Text(
                'തീയതി തിരഞ്ഞെടുക്കാൻ കലണ്ടർ ക്ലിക്ക് ചെയ്യുക',
                style: TextStyle(
                  fontFamily: 'NotoSansMalayalam',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedDateDisplay(String selectedDate) {
    // Find the corresponding special pooja date to get Malayalam date
    final specialDate = pooja.specialPoojaDates.firstWhere(
      (d) => d.date == selectedDate,
      orElse: () => pooja.specialPoojaDates.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          specialDate.malayalamDate,
          style: TextStyle(
            fontFamily: 'NotoSansMalayalam',
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          _formatDate(selectedDate),
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 8.h),
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
