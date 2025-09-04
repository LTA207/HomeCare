import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('vi', 'VN');

  Locale get currentLocale => _currentLocale;

  void changeLanguage(Locale locale) {
    _currentLocale = locale;
    notifyListeners();
  }

  void toggleLanguage() {
    if (_currentLocale.languageCode == 'vi') {
      _currentLocale = const Locale('en', 'US');
    } else {
      _currentLocale = const Locale('vi', 'VN');
    }
    notifyListeners();
  }
}
