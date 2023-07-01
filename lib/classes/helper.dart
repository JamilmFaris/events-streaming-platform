import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

abstract class Helper {
  static DateFormat format = DateFormat('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
  static String capitalize(String subject) {
    if (subject.isEmpty) {
      return '';
    }
    return subject[0].toUpperCase() + subject.substring(1).toLowerCase();
  }

  static String getFormattedDateString(DateTime date) {
    return format.format(date);
  }

  static DateTime getFormattedDate(String date) {
    return DateFormat('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'').parse(date);
  }

  static Widget getSizedImage(
    Image image,
    double height,
    double width,
  ) {
    return Center(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fitWidth,
            alignment: FractionalOffset.topCenter,
            image: image.image,
          ),
        ),
      ),
    );
  }

  Future<void> _presentEndDatePicker(
    BuildContext context,
    DateTime initialDate,
    DateTime firstDate,
    DateTime lastDate,
    void Function(DateTime) function,
  ) async {
    if (!context.mounted) {
      return;
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 7),
      ),
    );
    if (picked != null) {
      if (!context.mounted) return;
      final TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(
          hour: initialDate.hour,
          minute: initialDate.minute,
        ),
      );
      if (timePicked != null) {
        DateTime resultDate = picked.copyWith(
          hour: timePicked.hour,
          minute: timePicked.minute,
        );
        function(resultDate);
      }
    }
  }
}
