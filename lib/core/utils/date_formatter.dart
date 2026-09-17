import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final _standardDate = DateFormat('dd MMM yyyy');
  static final _shortDate = DateFormat('dd/MM/yyyy');
  static final _monthYear = DateFormat('MMMM yyyy');

  static String format(DateTime date) => _standardDate.format(date);

  static String formatShort(DateTime date) => _shortDate.format(date);

  static String formatMonthYear(DateTime date) => _monthYear.format(date);

  static String relativeDueText(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = target.difference(today).inDays;

    if (difference == 0) {
      return 'Due today';
    } else if (difference == 1) {
      return 'Due tomorrow';
    } else if (difference > 1) {
      return 'Due in $difference days';
    } else if (difference == -1) {
      return '1 day overdue';
    } else {
      return '${difference.abs()} days overdue';
    }
  }
}
