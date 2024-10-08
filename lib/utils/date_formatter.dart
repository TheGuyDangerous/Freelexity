import 'package:intl/intl.dart';

String formatTimestamp(String timestamp) {
  final date = DateTime.parse(timestamp);
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays == 0) {
    return DateFormat.jm().format(date);
  } else if (difference.inDays == 1) {
    return 'Yesterday';
  } else if (difference.inDays < 7) {
    return DateFormat.E().format(date);
  } else {
    return DateFormat.yMMMd().format(date);
  }
}
