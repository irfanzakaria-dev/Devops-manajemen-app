import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static final SettingsService instance = SettingsService._internal();
  SettingsService._internal();

  bool _isDarkMode = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  int _syncIntervalMinutes = 15;
  bool _autoSyncEnabled = true;

  bool get isDarkMode => _isDarkMode;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  int get syncIntervalMinutes => _syncIntervalMinutes;
  bool get autoSyncEnabled => _autoSyncEnabled;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('is_dark_mode') ?? true;
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
    _syncIntervalMinutes = prefs.getInt('sync_interval_minutes') ?? 15;
    _autoSyncEnabled = prefs.getBool('auto_sync_enabled') ?? true;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', value);
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', value);
    notifyListeners();
  }

  Future<void> setVibrationEnabled(bool value) async {
    _vibrationEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibration_enabled', value);
    notifyListeners();
  }

  Future<void> setSyncInterval(int minutes) async {
    _syncIntervalMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sync_interval_minutes', minutes);
    notifyListeners();
  }

  Future<void> setAutoSyncEnabled(bool value) async {
    _autoSyncEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_sync_enabled', value);
    notifyListeners();
  }
}

