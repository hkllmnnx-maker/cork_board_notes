import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة إدارة تفضيلات التطبيق (الثيم، ترتيب الفرز، إلخ)
class SettingsService extends ChangeNotifier {
  static const String _themeModeKey = 'settings_theme_mode';
  static const String _sortOrderKey = 'settings_sort_order';
  static const String _hapticKey = 'settings_haptic_enabled';

  late SharedPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.light;
  NoteSortOrder _sortOrder = NoteSortOrder.updatedDesc;
  bool _hapticEnabled = true;

  ThemeMode get themeMode => _themeMode;
  NoteSortOrder get sortOrder => _sortOrder;
  bool get hapticEnabled => _hapticEnabled;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    // ThemeMode
    final themeValue = _prefs.getString(_themeModeKey);
    switch (themeValue) {
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'system':
        _themeMode = ThemeMode.system;
        break;
      default:
        _themeMode = ThemeMode.light;
    }

    // Sort order
    final sortValue = _prefs.getString(_sortOrderKey);
    _sortOrder = NoteSortOrder.values.firstWhere(
      (e) => e.name == sortValue,
      orElse: () => NoteSortOrder.updatedDesc,
    );

    // Haptic
    _hapticEnabled = _prefs.getBool(_hapticKey) ?? true;

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final value = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
      _ => 'light',
    };
    await _prefs.setString(_themeModeKey, value);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    await setThemeMode(
      _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }

  Future<void> setSortOrder(NoteSortOrder order) async {
    _sortOrder = order;
    await _prefs.setString(_sortOrderKey, order.name);
    notifyListeners();
  }

  Future<void> setHapticEnabled(bool value) async {
    _hapticEnabled = value;
    await _prefs.setBool(_hapticKey, value);
    notifyListeners();
  }
}

/// ترتيب الفرز للملاحظات
enum NoteSortOrder {
  updatedDesc('آخر تعديل أولًا'),
  updatedAsc('أقدم تعديل أولًا'),
  createdDesc('الأحدث إنشاءً أولًا'),
  createdAsc('الأقدم إنشاءً أولًا'),
  alphabetical('أبجديًا');

  final String label;
  const NoteSortOrder(this.label);
}
