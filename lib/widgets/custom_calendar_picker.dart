import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple_app/core/app_colors.dart';

class CustomCalendarPicker extends StatefulWidget {
  final List<String> enabledDates;
  final String? selectedDate;
  final void Function(String) onDateSelected;

  const CustomCalendarPicker({
    super.key,
    required this.enabledDates,
    required this.onDateSelected,
    this.selectedDate,
  });

  @override
  State<CustomCalendarPicker> createState() => _CustomCalendarPickerState();
}

class _CustomCalendarPickerState extends State<CustomCalendarPicker> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    if (widget.enabledDates.isNotEmpty) {
      _displayedMonth = DateTime.parse(widget.enabledDates.first);
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month);
    } else {
      final now = DateTime.now();
      _displayedMonth = DateTime(now.year, now.month);
    }
  }

  void _goToPreviousMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
      );
    });
  }

  void _goToNextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final enabledDateSet = widget.enabledDates.toSet();
    final selected = widget.selectedDate;
    final daysInMonth = DateUtils.getDaysInMonth(
      _displayedMonth.year,
      _displayedMonth.month,
    );
    final firstDayOfWeek =
        DateTime(_displayedMonth.year, _displayedMonth.month, 1).weekday % 7;
    final days = List.generate(daysInMonth, (i) => i + 1);
    final monthName = _monthName(_displayedMonth.month);

    return Container(
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
        children: [
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: AppColors.selected),
                onPressed: _goToPreviousMonth,
              ),
              Text(
                '$monthName ${_displayedMonth.year}',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: AppColors.selected),
                onPressed: _goToNextMonth,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Weekday labels (tight spacing)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.selected,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 8.h),
          // Days grid with reduced vertical spacing and tighter row height
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 0,
              crossAxisSpacing: 2.w,
              // Increase aspect ratio (width/height) to reduce each cell's height
              childAspectRatio: 1.8,
            ),
            padding: EdgeInsets.zero,
            itemCount: daysInMonth + firstDayOfWeek,
            itemBuilder: (context, i) {
              if (i < firstDayOfWeek) {
                return SizedBox.shrink();
              }
              final day = days[i - firstDayOfWeek];
              final date = DateTime(
                _displayedMonth.year,
                _displayedMonth.month,
                day,
              );
              final dateStr = date.toIso8601String().substring(0, 10);
              final isEnabled = enabledDateSet.contains(dateStr);
              final isSelected = selected == dateStr;
              return GestureDetector(
                onTap: isEnabled
                    ? () {
                        widget.onDateSelected(dateStr);
                      }
                    : null,
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 28.w,
                    height: 28.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.selected
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6.r),
                      border: isSelected
                          ? Border.all(color: AppColors.selected, width: 2)
                          : null,
                    ),
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isEnabled ? Colors.black : Colors.grey),
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  String _monthName(int month) {
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
    return months[month - 1];
  }
}
