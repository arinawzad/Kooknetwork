import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  
  // Constructor that can be used to set a default theme mode
  ThemeProvider({ThemeMode initialThemeMode = ThemeMode.system}) : _themeMode = initialThemeMode;
  
  // Getter for current theme mode
  ThemeMode get themeMode => _themeMode;
  
  // Determine if dark mode is active based on system or user preference
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
  
  // Set theme mode and save to preferences
  void setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;
    
    _themeMode = themeMode;
    notifyListeners();
    
    // Save to shared preferences
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('theme_mode', themeMode.toString());
  }
  
  // Toggle between light and dark mode (ignoring system)
  void toggleTheme() {
    setThemeMode(_themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }
  
  // Load saved theme mode from preferences
  Future<void> loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedThemeMode = prefs.getString('theme_mode');
      
      if (savedThemeMode != null) {
        if (savedThemeMode == ThemeMode.dark.toString()) {
          _themeMode = ThemeMode.dark;
        } else if (savedThemeMode == ThemeMode.light.toString()) {
          _themeMode = ThemeMode.light;
        } else {
          _themeMode = ThemeMode.system;
        }
        notifyListeners();
      }
    } catch (e) {
      // Fallback to system theme if there's an error
      _themeMode = ThemeMode.system;
    }
  }
}