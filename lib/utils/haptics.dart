import 'package:flutter/services.dart';
import '../services/settings_service.dart';

/// أدوات مساعدة لإطلاق اهتزازات بسيطة تحترم إعدادات المستخدم
class Haptics {
  static void light(SettingsService? settings) {
    if (settings?.hapticEnabled ?? true) {
      HapticFeedback.lightImpact();
    }
  }

  static void medium(SettingsService? settings) {
    if (settings?.hapticEnabled ?? true) {
      HapticFeedback.mediumImpact();
    }
  }

  static void selection(SettingsService? settings) {
    if (settings?.hapticEnabled ?? true) {
      HapticFeedback.selectionClick();
    }
  }
}
