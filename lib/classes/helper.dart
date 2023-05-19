import 'package:intl/intl.dart';

abstract class Helper {
  static DateFormat format = DateFormat('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
  static String capitalize(String subject) {
    if (subject.isEmpty) {
      return '';
    }
    return subject[0].toUpperCase() + subject.substring(1).toLowerCase();
  }

  static String getFomattedDate(DateTime date) {
    return format.format(date);
  }
}
