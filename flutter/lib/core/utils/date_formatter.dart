import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFormatter {
  static String format(DateTime date, {String pattern = 'd MMM yyyy'}) {
    return DateFormat(pattern, 'es_MX').format(date);
  }

  static String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String formatFull(DateTime date) {
    return DateFormat('EEEE, d MMMM yyyy, HH:mm', 'es_MX').format(date);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else if (difference.inDays < 30) {
      return 'Hace ${difference.inDays ~/ 7} semanas';
    } else {
      return DateFormat('MMM yyyy', 'es_MX').format(date);
    }
  }
}
