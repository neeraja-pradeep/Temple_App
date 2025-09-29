String formatDate(String input) {
  // Remove any non-digit characters
  final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
  
  if (digits.length < 8) return digits; 

  try {
    final year = digits.substring(0, 4);
    final month = digits.substring(4, 6);
    final day = digits.substring(6, 8);

    final y = int.parse(year);
    final m = int.parse(month);
    final d = int.parse(day);

    if (d < 1 || d > 31) return '';
    if (m < 1 || m > 12) return '';
    if (y < 1900 || y > DateTime.now().year) return '';

    return '$year-$month-$day';
  } catch (_) {
    return '';
  }
}


String formatTime(String input) {
  final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
  
  if (digits.length < 4) return digits;

  try {
    final hour = digits.substring(0, 2);
    final minute = digits.substring(2, 4);
    final second = digits.length >= 6 ? digits.substring(4, 6) : '00';

    final h = int.parse(hour);
    final m = int.parse(minute);
    final s = int.parse(second);

    if (h > 23 || m > 59 || s > 59) return '';

    return '$hour:$minute:$second';
  } catch (_) {
    return '';
  }
}

