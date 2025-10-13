import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temple_app/core/app_colors.dart';
import 'package:temple_app/features/booking/data/booking_pooja_model.dart';
import 'package:temple_app/features/booking/providers/booking_page_providers.dart';
import 'package:temple_app/features/booking/providers/user_list_provider.dart';

class BookingBottomButton extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final showCalendar = ref.watch(showCalendarProvider);
    final selectedUsers = ref.watch(selectedUsersProvider(userId));

    // Calculate price based on pooja type and selected date
    double basePrice = _calculateBasePrice(ref);
    final int userCount = selectedUsers.isNotEmpty ? selectedUsers.length : 1;
    final double totalPrice = basePrice * userCount;

    print('💰 Total Price: $totalPrice (Base: $basePrice × Users: $userCount)');

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(color: Colors.transparent),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!showCalendar) ...[
              Text(
                'ആകെതുക: ₹${totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: 'NotoSansMalayalam',
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'നോസ്ത്രുഡ് എക്സെപ്റ്റെർ ഡ്യൂയിസ് മാഗ്നാ ക്വിസ് എനിം എനിം എസ്റ്റ് ഉല്ലാംകോ പ്രൊഇഡന്റ് ഉട്ട് നിസി ഉല്ലാംകോ മിനിം',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 12.h),
            ],
            SizedBox(
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
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateBasePrice(WidgetRef ref) {
    double basePrice;
    if (pooja.specialPooja) {
      // For special pooja, use the price of the selected special date
      final selectedDate = ref.watch(selectedCalendarDateProvider);
      if (selectedDate != null) {
        try {
          final selectedSpecialDate = pooja.specialPoojaDates.firstWhere(
            (date) => date.date == selectedDate,
          );
          basePrice = double.tryParse(selectedSpecialDate.price) ?? 0.0;
          print(
            '🎯 Special Pooja - Using special date price: ${selectedSpecialDate.price}',
          );
        } catch (e) {
          // Fallback to first available special date price
          basePrice =
              double.tryParse(pooja.specialPoojaDates.first.price) ?? 0.0;
          print(
            '🎯 Special Pooja - Using first available date price: ${pooja.specialPoojaDates.first.price}',
          );
        }
      } else {
        // No date selected, use first available special date price
        basePrice = double.tryParse(pooja.specialPoojaDates.first.price) ?? 0.0;
        print(
          '🎯 Special Pooja - No date selected, using first available: ${pooja.specialPoojaDates.first.price}',
        );
      }
    } else {
      // For regular pooja, use the base price
      basePrice = double.tryParse(pooja.price) ?? 0.0;
      print('📅 Regular Pooja - Using base price: ${pooja.price}');
    }
    return basePrice;
  }
}

