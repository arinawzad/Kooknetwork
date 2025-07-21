import 'package:flutter/material.dart';
import 'app_localizations.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    // Check if the locale is in our supported locales list
    return ['en', 'ar', 'fr', 'de','fa','vi'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    // Create a new AppLocalizations instance
    AppLocalizations localizations = AppLocalizations(locale);
    // Load the JSON file
    await localizations.load();
    return localizations;
  }
  
  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}