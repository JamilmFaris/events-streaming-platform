abstract class Helper {
  static String capitalize(String subject) {
    if (subject.isEmpty) {
      return '';
    }
    return subject[0].toUpperCase() + subject.substring(1).toLowerCase();
  }
}
