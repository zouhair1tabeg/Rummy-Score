import 'package:intl/intl.dart';

/// Safe date formatter with French locale and zero-crash fallback.
class AppDateFormatter {
  AppDateFormatter._();

  static const List<String> _frenchMonthsShort = [
    'janv.',
    'févr.',
    'mars',
    'avr.',
    'mai',
    'juin',
    'juil.',
    'août',
    'sept.',
    'oct.',
    'nov.',
    'déc.',
  ];

  /// Formats date as e.g. "25 oct. 2026 à 18:30"
  static String formatGameDate(DateTime dateTime) {
    try {
      final formatter = DateFormat('dd MMM yyyy à HH:mm', 'fr_FR');
      return formatter.format(dateTime);
    } catch (_) {
      // Fallback if intl locale data is uninitialized
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = _frenchMonthsShort[dateTime.month - 1];
      final year = dateTime.year;
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$day $month $year à $hour:$minute';
    }
  }

  /// Formats time as "HH:mm"
  static String formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
