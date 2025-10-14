import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DateFormatter {
  static String _dateFormat = 'dd/MM/yyyy';

  static Future<void> loadFormat() async {
    final prefs = await SharedPreferences.getInstance();
    _dateFormat = prefs.getString('date_format') ?? 'dd/MM/yyyy';
  }

  static String format(DateTime date) {
    try {
      return DateFormat(_dateFormat).format(date);
    } catch (e) {
      // Fallback to default format if there's an error
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  static String formatWithTime(DateTime date) {
    try {
      return '${DateFormat(_dateFormat).format(date)} ${DateFormat('HH:mm').format(date)}';
    } catch (e) {
      // Fallback to default format if there's an error
      return '${DateFormat('dd/MM/yyyy').format(date)} ${DateFormat('HH:mm').format(date)}';
    }
  }

  static String get currentFormat => _dateFormat;
}
