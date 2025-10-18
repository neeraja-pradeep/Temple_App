import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:temple_app/core/app_colors.dart';
import 'package:temple_app/features/pooja/providers/pooja_providers.dart';

class MalayalamCalendar extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  final Function(String)? onDateSelected;

  const MalayalamCalendar({super.key, this.initialDate, this.onDateSelected});

  @override
  ConsumerState<MalayalamCalendar> createState() => _MalayalamCalendarState();
}

class _MalayalamCalendarState extends ConsumerState<MalayalamCalendar> {
  late DateTime _focusedDate;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDate =
        widget.initialDate ?? DateTime.now().add(const Duration(days: 1));
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDate = focusedDay;
    });

    final dateStr = selectedDay.toIso8601String().split("T").first;

    ref.read(malayalamDateProvider.notifier).fetchDate(dateStr);

    // ✅ Update the global provider here
    ref.read(selectedDateProvider.notifier).state = dateStr;

    if (widget.onDateSelected != null) {
      widget.onDateSelected!(dateStr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final malayalamDateAsync = ref.watch(malayalamDateProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: malayalamDateAsync.when(
            data: (date) => Text(
              date.malayalamDate,
              style: TextStyle(
                color: AppColors.selected,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            loading: () => CircularProgressIndicator(color: AppColors.selected),
            error: (err, _) => Text(
              "Error: $err",
              style: TextStyle(color: AppColors.selected, fontSize: 12.sp),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: 343.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: TableCalendar(
              rowHeight: 28.h,
              focusedDay: _focusedDate,
              firstDay: DateTime.now().add(const Duration(days: 1)),
              lastDay: DateTime.utc(2030, 12, 31),
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: _onDaySelected,

              // ✅ Important: use swipe paging instead of scroll conflict
              availableGestures: AvailableGestures.horizontalSwipe,

              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                headerPadding: const EdgeInsets.symmetric(vertical: 4),
                titleTextFormatter: (date, locale) {
                  const months = [
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
                  return months[date.month - 1];
                },
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: AppColors.selected,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: AppColors.selected,
                ),
                titleTextStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: "NotoSansMalayalam",
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: AppColors.selected),
                weekendStyle: TextStyle(color: AppColors.selected),
                dowTextFormatter: (date, locale) {
                  const letters = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                  return letters[date.weekday % 7];
                },
              ),
              calendarStyle: CalendarStyle(
                cellMargin: const EdgeInsets.only(top: 6, left: 6, right: 6),
                selectedDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: AppColors.selected,
                  borderRadius: BorderRadius.circular(8),
                ),
                todayDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.selected),
                ),
                holidayDecoration:BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(8),
                ), 
                rangeStartDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: AppColors.selected.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                rangeEndDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: AppColors.selected.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                defaultDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
