import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _dateFormat = DateFormat('MMM d, yyyy');
  static final DateFormat _timeFormat = DateFormat('h:mm a');
  static final DateFormat _dateTimeFormat = DateFormat('MMM d, yyyy • h:mm a');
  static final DateFormat _dayFormat = DateFormat('EEEE');
  static final DateFormat _shortDateFormat = DateFormat('MMM d');
  static final DateFormat _yearFormat = DateFormat('yyyy');

  static String formatDate(DateTime date) => _dateFormat.format(date);

  static String formatTime(DateTime time) => _timeFormat.format(time);

  static String formatDateTime(DateTime dateTime) =>
      _dateTimeFormat.format(dateTime);

  static String formatDay(DateTime date) => _dayFormat.format(date);

  static String formatShortDate(DateTime date) => _shortDateFormat.format(date);

  static String formatYear(DateTime date) => _yearFormat.format(date);

  static String formatEventDateTime(DateTime startTime, DateTime endTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final eventDate = DateTime(startTime.year, startTime.month, startTime.day);

    String dateText;
    if (eventDate == today) {
      dateText = 'Today';
    } else if (eventDate == tomorrow) {
      dateText = 'Tomorrow';
    } else {
      dateText = formatDate(startTime);
    }

    final startTimeText = formatTime(startTime);
    final endTimeText = formatTime(endTime);

    return '$dateText • $startTimeText - $endTimeText';
  }

  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Tomorrow';
      } else if (difference.inDays < 7) {
        return 'In ${difference.inDays} days';
      } else {
        return formatDate(dateTime);
      }
    } else if (difference.inHours > 0) {
      return 'In ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'In ${difference.inMinutes}m';
    } else if (difference.inSeconds > -60) {
      return 'Now';
    } else {
      // Past events
      final pastDifference = now.difference(dateTime);
      if (pastDifference.inDays > 0) {
        return '${pastDifference.inDays} days ago';
      } else if (pastDifference.inHours > 0) {
        return '${pastDifference.inHours}h ago';
      } else {
        return '${pastDifference.inMinutes}m ago';
      }
    }
  }
}
