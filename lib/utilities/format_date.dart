import 'package:intl/intl.dart';

String formatDueDate(DateTime? dueDate) {
  if (dueDate == null) return 'Not specified';
  return DateFormat('yyyy-MM-dd')
      .format(dueDate); // Format without extra time zeros
}
