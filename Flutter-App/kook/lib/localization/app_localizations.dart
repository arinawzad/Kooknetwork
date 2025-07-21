import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_localizations_delegate.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, String> _localizedStrings = {};
  
  AppLocalizations(this.locale);
  
  // Helper method to get localized instance
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  // Static delegate for material app
  static const LocalizationsDelegate<AppLocalizations> delegate = AppLocalizationsDelegate();
  
  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('ar'), // Arabic
    Locale('fr'), // French
    Locale('de'), // German
    Locale('fa'), // kurdi
    Locale('vi'), // Vietnamese
  


  ];
  
  // Load JSON language file
  Future<bool> load() async {
    try {
      debugPrint('Loading language file for: ${locale.languageCode}');
      // Load the language JSON file from the l10n folder
      String jsonString = await rootBundle.loadString('assets/l10n/${locale.languageCode}.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      
      _localizedStrings = jsonMap.map((key, value) {
        return MapEntry(key, value.toString());
      });
      
      debugPrint('Successfully loaded ${_localizedStrings.length} translations for ${locale.languageCode}');
      return true;
    } catch (e) {
      // If the locale is not supported or file not found, load English as fallback
      debugPrint('Error loading language file for ${locale.languageCode}: $e');
      if (locale.languageCode != 'en') {
        try {
          // Try to load English as fallback
          debugPrint('Attempting to load English as fallback');
          String jsonString = await rootBundle.loadString('assets/l10n/en.json');
          Map<String, dynamic> jsonMap = json.decode(jsonString);
          
          _localizedStrings = jsonMap.map((key, value) {
            return MapEntry(key, value.toString());
          });
          
          debugPrint('Loaded English fallback with ${_localizedStrings.length} translations');
          return true;
        } catch (fallbackError) {
          debugPrint('Error loading English fallback: $fallbackError');
          _localizedStrings = {};
          return false;
        }
      } else {
        _localizedStrings = {};
        return false;
      }
    }
  }
  
  // Get a localized string
  String translate(String key) {
    final result = _localizedStrings[key];
    if (result == null) {
      debugPrint('Missing translation for key: $key in ${locale.languageCode}');
      return key;
    }
    return result;
  }
}