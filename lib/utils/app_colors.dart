import 'package:flutter/material.dart';

/// ألوان التطبيق الأساسية
class AppColors {
  // ألوان الملاحظة الصفراء
  static const Color noteYellow = Color(0xFFF9EE8C);
  static const Color noteYellowDark = Color(0xFFE8DA6C);
  static const Color noteShadow = Color(0x33000000);

  // ألوان لوحة الفلين
  static const Color corkBoard = Color(0xFFC19A6B);
  static const Color corkBoardDark = Color(0xFF8B6F47);

  // ألوان الدبابيس
  static const Color pinGreen = Color(0xFF4CAF50);
  static const Color pinGreenDark = Color(0xFF2E7D32);
  static const Color pinRed = Color(0xFFE53935);
  static const Color pinRedDark = Color(0xFFB71C1C);
  static const Color pinBlue = Color(0xFF1E88E5);
  static const Color pinBlueDark = Color(0xFF0D47A1);
  static const Color pinYellow = Color(0xFFFBC02D);
  static const Color pinYellowDark = Color(0xFFF57F17);

  // ألوان التبويبات
  static const Color tabHome = Color(0xFF81C784); // أخضر
  static const Color tabWork = Color(0xFFFFD54F); // أصفر
  static const Color tabFamily = Color(0xFF4DB6AC); // تركوازي
  static const Color tabSettings = Color(0xFFBCAAA4); // بني فاتح

  // ألوان أخرى
  static const Color actionGreen = Color(0xFF43A047);
  static const Color actionRed = Color(0xFFE53935);
  static const Color dialogBackground = Color(0xFFFFF8E1);

  // ألوان الملاحظات (6 ألوان) - فاتح ومظلم لكل منها لتدرج لوني
  static const List<List<Color>> noteColors = [
    // 0: أصفر (افتراضي)
    [Color(0xFFF9EE8C), Color(0xFFE8DA6C)],
    // 1: وردي
    [Color(0xFFFFB6C1), Color(0xFFF48FA8)],
    // 2: أخضر
    [Color(0xFFC5E1A5), Color(0xFFAED581)],
    // 3: أزرق
    [Color(0xFFB3E5FC), Color(0xFF81D4FA)],
    // 4: برتقالي
    [Color(0xFFFFCC80), Color(0xFFFFB74D)],
    // 5: بنفسجي
    [Color(0xFFE1BEE7), Color(0xFFCE93D8)],
  ];

  static const List<String> noteColorNames = [
    'أصفر',
    'وردي',
    'أخضر',
    'أزرق',
    'برتقالي',
    'بنفسجي',
  ];

  /// الحصول على اللون الأساسي لورقة الملاحظة
  static Color noteColorPrimary(int index) {
    if (index < 0 || index >= noteColors.length) return noteYellow;
    return noteColors[index][0];
  }

  /// الحصول على اللون الداكن لورقة الملاحظة (للتدرج)
  static Color noteColorSecondary(int index) {
    if (index < 0 || index >= noteColors.length) return noteYellowDark;
    return noteColors[index][1];
  }

  static Color pinColor(int index) {
    switch (index) {
      case 0:
        return pinGreen;
      case 1:
        return pinRed;
      case 2:
        return pinBlue;
      case 3:
        return pinYellow;
      default:
        return pinGreen;
    }
  }

  static Color pinColorDark(int index) {
    switch (index) {
      case 0:
        return pinGreenDark;
      case 1:
        return pinRedDark;
      case 2:
        return pinBlueDark;
      case 3:
        return pinYellowDark;
      default:
        return pinGreenDark;
    }
  }
}
