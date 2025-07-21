import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../localization/app_localizations.dart';

class LanguageProvider with ChangeNotifier {
  // Default to English
  Locale _locale = const Locale('en');
  
  // List of supported languages
  final List<Map<String, dynamic>> supportedLanguages = [
    {'name': 'English', 'locale': const Locale('en')},
    {'name': 'العربية', 'locale': const Locale('ar')},
    {'name': 'Français', 'locale': const Locale('fr')},
    {'name': 'Deutsch', 'locale': const Locale('de')},
    {'name': 'کوردی', 'locale': const Locale('fa')},
    {'name': 'Vietnamese', 'locale': const Locale('vi')},
   

  ];
  
  // Constructor that can be used to set an initial locale
  LanguageProvider({Locale? initialLocale}) {
    if (initialLocale != null) {
      _locale = initialLocale;
    }
    // Load saved locale when provider is created
    loadLocale();
  }
  
  // Getter for current locale
  Locale get locale => _locale;
  
  // Get the name of the current language
  String get currentLanguageName {
    final currentLanguage = supportedLanguages.firstWhere(
      (language) => language['locale'].languageCode == _locale.languageCode,
      orElse: () => supportedLanguages[0],
    );
    return currentLanguage['name'];
  }
  
  // Check if locale is supported
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
      .map((e) => e.languageCode)
      .contains(locale.languageCode);
  }
  
  // Set locale and save to preferences
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale || !isSupported(locale)) return;
    
    debugPrint('Setting locale to: ${locale.languageCode}');
    _locale = locale;
    
    // Save to shared preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', locale.languageCode);
      debugPrint('Language saved to prefs: ${locale.languageCode}');
    } catch (e) {
      debugPrint('Error saving language preference: $e');
    }
    
    // Make sure to notify listeners to rebuild widgets
    notifyListeners();
  }
  
  // Set locale by language code
  Future<void> setLanguageByCode(String languageCode) async {
    final language = supportedLanguages.firstWhere(
      (lang) => lang['locale'].languageCode == languageCode,
      orElse: () => supportedLanguages[0],
    );
    await setLocale(language['locale']);
  }
  
  // Load saved locale from preferences
  Future<void> loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language_code');
      
      if (languageCode != null && isSupported(Locale(languageCode))) {
        _locale = Locale(languageCode);
        debugPrint('Loaded language from prefs: $languageCode');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading language preference: $e');
      // Fallback to default English if there's an error
      _locale = const Locale('en');
    }
  }
}