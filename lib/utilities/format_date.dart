import 'package:intl/intl.dart';

String formatDueDate(dynamic dueDate) {
  try {
    if (dueDate is String && dueDate.isNotEmpty) {
      final parsedDate = DateTime.parse(dueDate);
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } else if (dueDate is DateTime) {
      return DateFormat('yyyy-MM-dd').format(dueDate);
    } else {
      return 'תאריך לא תקין';
    }
  } catch (_) {
    return 'תאריך לא תקין';
  }
}
