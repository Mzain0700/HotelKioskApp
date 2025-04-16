// A simple singleton class to manage the selected language across the app
class LanguageProvider {
  static String _currentLanguage = 'en';

  static String get currentLanguage => _currentLanguage;

  static void setLanguage(String language) {
    _currentLanguage = language;
  }
}

