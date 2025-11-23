import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SettingsService {
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyCalculationMethod = 'calculation_method';
  static const String _keyDailyResetHour = 'daily_reset_hour';
  static const String _keyDailyResetMinute = 'daily_reset_minute';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  static Future<SettingsService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsService(prefs);
  }

  ThemeMode getThemeMode() {
    final index = _prefs.getInt(_keyThemeMode) ?? ThemeMode.system.index;
    return ThemeMode.values[index];
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setInt(_keyThemeMode, mode.index);
  }

  int getCalculationMethod() {
    // Default to Muslim World League (index 3 in adhan package usually, but we store our own index)
    return _prefs.getInt(_keyCalculationMethod) ?? 3;
  }

  Future<void> setCalculationMethod(int index) async {
    await _prefs.setInt(_keyCalculationMethod, index);
  }

  TimeOfDay getDailyResetTime() {
    final hour = _prefs.getInt(_keyDailyResetHour) ?? 0;
    final minute = _prefs.getInt(_keyDailyResetMinute) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> setDailyResetTime(TimeOfDay time) async {
    await _prefs.setInt(_keyDailyResetHour, time.hour);
    await _prefs.setInt(_keyDailyResetMinute, time.minute);
  }
}
