import 'package:ezbookkeeping/core/localization/app_language.dart';
import 'package:ezbookkeeping/core/localization/locale_storage.dart';
import 'package:flutter/material.dart';
import 'package:ezbookkeeping/l10n/generated/app_localizations.dart';

/// Controller that manages the active [Locale] and synchronizes with [LocaleStorage].
class LocaleController extends ChangeNotifier {
  LocaleController({
    Locale initialLocale = const Locale('en'),
    LocaleStorage? storage,
  }) : _locale = initialLocale,
       _storage = storage ?? SecureLocaleStorage();

  Locale _locale;
  final LocaleStorage _storage;

  Locale get locale => _locale;
  AppLanguage get currentLanguage => AppLanguage.fromLocale(_locale);

  /// Initializes the controller by reading the saved locale from storage.
  Future<void> initialize() async {
    try {
      final savedCode = await _storage.getLocaleCode();
      if (savedCode != null && savedCode.isNotEmpty) {
        final language = AppLanguage.fromCode(savedCode);
        _locale = language.locale;
        notifyListeners();
      }
    } catch (_) {
      // Fallback safely to default English on any storage read exception
      _locale = AppLanguage.defaultLanguage.locale;
    }
  }

  /// Sets and persists a new locale.
  Future<void> setLocale(Locale newLocale) async {
    final language = AppLanguage.fromLocale(newLocale);
    if (_locale == language.locale) return;

    _locale = language.locale;
    notifyListeners();

    try {
      await _storage.saveLocaleCode(language.code);
    } catch (_) {
      // Ignore storage persistence failure
    }
  }

  /// Sets and persists a new language.
  Future<void> setLanguage(AppLanguage language) async {
    await setLocale(language.locale);
  }
}

/// InheritedWidget that makes [LocaleController] accessible throughout the widget tree.
class LocaleScope extends InheritedNotifier<LocaleController> {
  const LocaleScope({
    super.key,
    required LocaleController controller,
    required super.child,
  }) : super(notifier: controller);

  static LocaleController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LocaleScope>();
    if (scope?.notifier == null) {
      throw FlutterError(
        'LocaleScope.of() called with a context that does not contain a LocaleScope.',
      );
    }
    return scope!.notifier!;
  }
}

/// Convenience context extension for easy access to localization strings and locale state.
extension LocalizationContextExtension on BuildContext {
  /// Type-safe access to generated localization messages.
  AppLocalizations get l10n {
    final localizations = AppLocalizations.of(this);
    if (localizations == null) {
      throw FlutterError(
        'AppLocalizations not found in BuildContext. Ensure MaterialApp includes AppLocalizations.delegate.',
      );
    }
    return localizations;
  }

  /// The currently active application [Locale].
  Locale get currentAppLocale => LocaleScope.of(this).locale;

  /// The currently active [AppLanguage] representation.
  AppLanguage get currentAppLanguage => LocaleScope.of(this).currentLanguage;
}
