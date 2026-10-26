import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// This class holds the seven user settings and saves them with SharedPreferences.
// It is a ChangeNotifier, so screens that listen to it redraw when a setting changes.
class AppSettings extends ChangeNotifier {
  // Only one copy exists, so every screen reads the same settings.
  static final AppSettings instance = AppSettings._init();
  AppSettings._init();

  // These are the names the values are saved under on the phone.
  static const String _volumeKey = 'volume';
  static const String _musicKey = 'music_on';
  static const String _darkModeKey = 'dark_mode';
  static const String _vibrationKey = 'vibration_on';
  static const String _restKey = 'rest_seconds';
  static const String _focusKey = 'preferred_focus';
  static const String _suggestionsKey = 'show_suggestions';

  // These limits keep the rest slider between 10 and 60 seconds.
  static const int minRestSeconds = 10;
  static const int maxRestSeconds = 60;

  // These are the current values, starting with the defaults from the build plan.
  double volume = 0.7;
  bool musicOn = true;
  bool darkMode = false;
  bool vibrationOn = true;
  int restSeconds = 20;
  String? preferredFocus;
  bool showSuggestions = true;

  // This getter tells the app which theme to use.
  ThemeMode get themeMode => darkMode ? ThemeMode.dark : ThemeMode.light;

  // This method reads the saved values when the app starts.
  // A value that was never saved keeps its default.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    volume = (prefs.getDouble(_volumeKey) ?? volume).clamp(0.0, 1.0);
    musicOn = prefs.getBool(_musicKey) ?? musicOn;
    darkMode = prefs.getBool(_darkModeKey) ?? darkMode;
    vibrationOn = prefs.getBool(_vibrationKey) ?? vibrationOn;
    restSeconds = (prefs.getInt(_restKey) ?? restSeconds).clamp(
      minRestSeconds,
      maxRestSeconds,
    );
    preferredFocus = prefs.getString(_focusKey);
    showSuggestions = prefs.getBool(_suggestionsKey) ?? showSuggestions;
  }

  // Each setter below changes the value, redraws listening screens, and saves it.

  Future<void> setVolume(double value) async {
    volume = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeKey, value);
  }

  Future<void> setMusicOn(bool value) async {
    musicOn = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_musicKey, value);
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  Future<void> setVibrationOn(bool value) async {
    vibrationOn = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationKey, value);
  }

  Future<void> setRestSeconds(int value) async {
    restSeconds = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_restKey, value);
  }

  // A null focus means "No preference", so the saved value is removed.
  Future<void> setPreferredFocus(String? value) async {
    preferredFocus = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_focusKey);
    } else {
      await prefs.setString(_focusKey, value);
    }
  }

  Future<void> setShowSuggestions(bool value) async {
    showSuggestions = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_suggestionsKey, value);
  }
}
