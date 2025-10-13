import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temple_app/features/booking/data/booking_pooja_model.dart';
import 'package:temple_app/features/booking/providers/booking_page_providers.dart';
import 'package:temple_app/widgets/custom_calendar_picker.dart';

class BookingCalendarCard extends ConsumerWidget {
  final BookingPooja pooja;

  const BookingCalendarCard({super.key, required this.pooja});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showCalendar = ref.watch(showCalendarProvider);
    if (!showCalendar) return SizedBox.shrink();

    List<String> enabledDates;
    if (pooja.specialPooja) {
      // For special pooja, use the predefined dates
      enabledDates = pooja.specialPoojaDates.map((d) => d.date).toList();
      print('🎯 Special Pooja - Available dates: $enabledDates');
    } else {
      // For regular pooja, generate dates for the next 30 days
      final now = DateTime.now();
      enabledDates = List.generate(30, (index) {
        final date = now.add(Duration(days: index + 1));
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      });
      print(
        '📅 Regular Pooja - Generated dates: ${enabledDates.take(5)}... (${enabledDates.length} total)',
      );
    }

    final selectedDate = ref.watch(selectedCalendarDateProvider);

    // If previously stored date is invalid for this pooja, clear it
    if (selectedDate != null && !enabledDates.contains(selectedDate)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedCalendarDateProvider.notifier).state = null;
      });
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: CustomCalendarPicker(
        enabledDates: enabledDates,
        selectedDate: selectedDate,
        onDateSelected: (date) {
          ref.read(selectedCalendarDateProvider.notifier).state = date;
          ref.read(showCalendarProvider.notifier).state = false;
        },
      ),
    );
  }
}

