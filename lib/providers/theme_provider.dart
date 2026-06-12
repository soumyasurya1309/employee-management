import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const key = 'theme_mode_v3';
  bool _manualDark = false;      // manual override value
  bool _hasManual = false;       // false = follow device, true = manual

  ThemeMode get themeMode {
    if (!_hasManual) return ThemeMode.system; // follow device
    return _manualDark ? ThemeMode.dark : ThemeMode.light;
  }

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _hasManual = prefs.getBool('has_manual') ?? false;
    _manualDark = prefs.getBool('manual_dark') ?? false;
    notifyListeners();
  }

  // Toggle: if following device → switch to opposite of current
  //         if manual → toggle between dark/light
  //         long press → reset to auto (follow device)
  Future<void> toggle(BuildContext context) async {
    final currentlyDark =
        Theme.of(context).brightness == Brightness.dark;
    _hasManual = true;
    _manualDark = !currentlyDark; // flip current
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_manual', _hasManual);
    await prefs.setBool('manual_dark', _manualDark);
  }

  // Reset to follow device theme
  Future<void> resetToAuto() async {
    _hasManual = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_manual', false);
  }

  bool get isManual => _hasManual;
}