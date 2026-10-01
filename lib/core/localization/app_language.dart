import 'package:flutter/material.dart';

/// Represents a supported language in the application.
class AppLanguage {
  final String code;
  final String nativeName;
  final String englishName;
  final Locale locale;

  const AppLanguage({
    required this.code,
    required this.nativeName,
    required this.englishName,
    required this.locale,
  });

  /// The exact list of supported languages extracted directly from the design reference.
  static const List<AppLanguage> supportedLanguages = [
    AppLanguage(
      code: 'de',
      nativeName: 'Deutsch',
      englishName: 'German',
      locale: Locale('de'),
    ),
    AppLanguage(
      code: 'el',
      nativeName: 'Ελληνικά',
      englishName: 'Greek',
      locale: Locale('el'),
    ),
    AppLanguage(
      code: 'en',
      nativeName: 'English',
      englishName: 'English',
      locale: Locale('en'),
    ),
    AppLanguage(
      code: 'es',
      nativeName: 'Español',
      englishName: 'Spanish',
      locale: Locale('es'),
    ),
    AppLanguage(
      code: 'fr',
      nativeName: 'Français',
      englishName: 'French',
      locale: Locale('fr'),
    ),
    AppLanguage(
      code: 'it',
      nativeName: 'Italiano',
      englishName: 'Italian',
      locale: Locale('it'),
    ),
    AppLanguage(
      code: 'ja',
      nativeName: '日本語',
      englishName: 'Japanese',
      locale: Locale('ja'),
    ),
  ];

  /// The default fallback language for first-time users.
  static const AppLanguage defaultLanguage = AppLanguage(
    code: 'en',
    nativeName: 'English',
    englishName: 'English',
    locale: Locale('en'),
  );

  /// Resolves an [AppLanguage] from a language code (e.g. 'en', 'de', 'ja').
  static AppLanguage fromCode(String? code) {
    if (code == null || code.isEmpty) {
      return defaultLanguage;
    }
    final normalized = code.toLowerCase().split('_').first.split('-').first;
    return supportedLanguages.firstWhere(
      (lang) => lang.code.toLowerCase() == normalized,
      orElse: () => defaultLanguage,
    );
  }

  /// Resolves an [AppLanguage] from a Flutter [Locale].
  static AppLanguage fromLocale(Locale? locale) {
    if (locale == null) return defaultLanguage;
    return fromCode(locale.languageCode);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppLanguage &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'AppLanguage($code, $nativeName / $englishName)';
}
