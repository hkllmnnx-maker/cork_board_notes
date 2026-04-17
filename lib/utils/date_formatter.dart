import 'package:intl/intl.dart';

/// أدوات تنسيق التاريخ والوقت بالعربية
class DateFormatter {
  static const List<String> arabicMonths = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  static const List<String> arabicWeekDays = [
    'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس',
    'الجمعة', 'السبت', 'الأحد',
  ];

  /// تنسيق بسيط: 2024/03/05 (مع حشو الأصفار)
  static String shortDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}/$mm/$dd';
  }

  /// تنسيق مع الوقت: 2024/03/05 14:30
  static String dateTime(DateTime d) {
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${shortDate(d)} $hh:$mm';
  }

  /// تنسيق عربي: 5 مارس 2024
  static String arabicDate(DateTime d) {
    final monthName = arabicMonths[d.month - 1];
    return '${d.day} $monthName ${d.year}';
  }

  /// تنسيق عربي كامل مع اليوم: الثلاثاء، 5 مارس 2024
  static String fullArabicDate(DateTime d) {
    final dayName = arabicWeekDays[d.weekday - 1];
    return '$dayName، ${arabicDate(d)}';
  }

  /// نص وصفي للوقت النسبي: "منذ 5 دقائق"، "أمس"، "اليوم"...
  static String relative(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);

    if (diff.inSeconds < 60) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
    if (diff.inDays < 30) return 'منذ ${(diff.inDays / 7).floor()} أسابيع';
    if (diff.inDays < 365) return 'منذ ${(diff.inDays / 30).floor()} أشهر';
    return 'منذ ${(diff.inDays / 365).floor()} سنوات';
  }

  /// وقت التذكير بالعربية: "غدًا"، "بعد 3 أيام"، "منذ يومين"
  static String reminderLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(d.year, d.month, d.day);
    final diffDays = target.difference(today).inDays;

    if (diffDays == 0) return 'اليوم';
    if (diffDays == 1) return 'غدًا';
    if (diffDays == -1) return 'أمس';
    if (diffDays > 1 && diffDays < 7) return 'بعد $diffDays أيام';
    if (diffDays > 6 && diffDays < 30) return 'بعد ${(diffDays / 7).floor()} أسابيع';
    if (diffDays < -1 && diffDays > -30) return 'منذ ${-diffDays} أيام';
    return arabicDate(d);
  }

  /// استخدام intl لضمان الأرقام العربية عند الحاجة
  static String intlShort(DateTime d) {
    return DateFormat('yyyy/MM/dd', 'ar').format(d);
  }
}
