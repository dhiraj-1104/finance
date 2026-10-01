import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/core/localization/app_language.dart';
import 'package:ezbookkeeping/core/localization/language_selector_modal.dart';
import 'package:ezbookkeeping/core/localization/locale_controller.dart';
import 'package:ezbookkeeping/core/localization/locale_storage.dart';
import 'package:ezbookkeeping/features/authentication/presentation/login_screen.dart';
import 'package:ezbookkeeping/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

class MockLocaleStorage implements LocaleStorage {
  String? _code;
  bool shouldThrow = false;

  @override
  Future<void> saveLocaleCode(String languageCode) async {
    if (shouldThrow) throw Exception('Storage error');
    _code = languageCode;
  }

  @override
  Future<String?> getLocaleCode() async {
    if (shouldThrow) throw Exception('Storage error');
    return _code;
  }

  @override
  Future<void> clearLocale() async {
    _code = null;
  }
}

void main() {
  setUp(() async {
    await getIt.reset();
    await setupDependencies();
  });

  group('AppLanguage Unit Tests', () {
    test(
      'Supported languages must contain exactly the 7 languages from design',
      () {
        final languages = AppLanguage.supportedLanguages;
        expect(languages.length, 7);

        expect(languages.map((l) => l.code).toList(), [
          'de',
          'el',
          'en',
          'es',
          'fr',
          'it',
          'ja',
        ]);

        expect(languages.map((l) => l.nativeName).toList(), [
          'Deutsch',
          'Ελληνικά',
          'English',
          'Español',
          'Français',
          'Italiano',
          '日本語',
        ]);

        expect(languages.map((l) => l.englishName).toList(), [
          'German',
          'Greek',
          'English',
          'Spanish',
          'French',
          'Italian',
          'Japanese',
        ]);
      },
    );

    test('fromCode returns correct language or defaults to English', () {
      expect(AppLanguage.fromCode('de').nativeName, 'Deutsch');
      expect(AppLanguage.fromCode('el').nativeName, 'Ελληνικά');
      expect(AppLanguage.fromCode('ja').nativeName, '日本語');
      expect(AppLanguage.fromCode('fr').nativeName, 'Français');
      expect(AppLanguage.fromCode('es').nativeName, 'Español');
      expect(AppLanguage.fromCode('it').nativeName, 'Italiano');
      expect(AppLanguage.fromCode('en').nativeName, 'English');

      // Unknown or null falls back to English
      expect(AppLanguage.fromCode(null).code, 'en');
      expect(AppLanguage.fromCode('unknown').code, 'en');
      expect(AppLanguage.fromCode('').code, 'en');
    });

    test('fromLocale returns correct language', () {
      expect(AppLanguage.fromLocale(const Locale('de')).code, 'de');
      expect(AppLanguage.fromLocale(const Locale('ja')).code, 'ja');
      expect(AppLanguage.fromLocale(null).code, 'en');
    });
  });

  group('LocaleController & Persistence Unit Tests', () {
    test('initializes with default English when storage is empty', () async {
      final storage = MockLocaleStorage();
      final controller = LocaleController(storage: storage);
      await controller.initialize();

      expect(controller.locale, const Locale('en'));
      expect(controller.currentLanguage.code, 'en');
    });

    test('initializes with persisted language if found in storage', () async {
      final storage = MockLocaleStorage();
      await storage.saveLocaleCode('ja');

      final controller = LocaleController(storage: storage);
      await controller.initialize();

      expect(controller.locale, const Locale('ja'));
      expect(controller.currentLanguage.nativeName, '日本語');
    });

    test(
      'safely falls back to English if storage throws error on initialize',
      () async {
        final storage = MockLocaleStorage()..shouldThrow = true;
        final controller = LocaleController(storage: storage);
        await controller.initialize();

        expect(controller.locale, const Locale('en'));
      },
    );

    test(
      'setLanguage updates locale, notifies listeners, and persists to storage',
      () async {
        final storage = MockLocaleStorage();
        final controller = LocaleController(storage: storage);

        bool notified = false;
        controller.addListener(() => notified = true);

        final german = AppLanguage.fromCode('de');
        await controller.setLanguage(german);

        expect(notified, isTrue);
        expect(controller.locale, const Locale('de'));
        expect(await storage.getLocaleCode(), 'de');
      },
    );
  });

  group('LanguageSelectorModal Widget Tests', () {
    Widget buildTestApp({required LocaleController controller, Widget? child}) {
      return LocaleScope(
        controller: controller,
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return MaterialApp(
              locale: controller.locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body:
                    child ??
                    Builder(
                      builder: (ctx) {
                        return ElevatedButton(
                          onPressed: () => LanguageSelectorModal.show(ctx),
                          child: const Text('Open Language Selector'),
                        );
                      },
                    ),
              ),
            );
          },
        ),
      );
    }

    testWidgets(
      'Renders modal with exact 7 languages and checkmark on active language',
      (tester) async {
        final storage = MockLocaleStorage();
        final controller = LocaleController(storage: storage);

        await tester.pumpWidget(buildTestApp(controller: controller));
        await tester.tap(find.text('Open Language Selector'));
        await tester.pumpAndSettle();

        // Verify all 7 languages from reference image are displayed
        expect(find.text('Deutsch'), findsOneWidget);
        expect(find.text('German'), findsOneWidget);

        expect(find.text('Ελληνικά'), findsOneWidget);
        expect(find.text('Greek'), findsOneWidget);

        expect(find.text('English'), findsOneWidget);
        // Active English displays checkmark icon instead of 'English' subtitle
        expect(find.byIcon(Icons.check_rounded), findsOneWidget);

        expect(find.text('Español'), findsOneWidget);
        expect(find.text('Spanish'), findsOneWidget);

        expect(find.text('Français'), findsOneWidget);
        expect(find.text('French'), findsOneWidget);

        expect(find.text('Italiano'), findsOneWidget);
        expect(find.text('Italian'), findsOneWidget);

        expect(find.text('日本語'), findsOneWidget);
        expect(find.text('Japanese'), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping a language switches locale, persists, and closes dialog',
      (tester) async {
        final storage = MockLocaleStorage();
        final controller = LocaleController(storage: storage);

        await tester.pumpWidget(buildTestApp(controller: controller));
        await tester.tap(find.text('Open Language Selector'));
        await tester.pumpAndSettle();

        // Tap German (Deutsch)
        await tester.tap(find.text('Deutsch'));
        await tester.pumpAndSettle();

        // Modal closed
        expect(find.text('Deutsch'), findsNothing);

        // Controller updated to German and persisted
        expect(controller.locale, const Locale('de'));
        expect(await storage.getLocaleCode(), 'de');
      },
    );

    testWidgets(
      'LoginScreen language footer opens modal and updates UI dynamically',
      (tester) async {
        final storage = MockLocaleStorage();
        final controller = LocaleController(storage: storage);

        await tester.pumpWidget(
          buildTestApp(controller: controller, child: const LoginScreen()),
        );
        await tester.pumpAndSettle();

        // Initial English UI
        expect(find.text('Log In'), findsOneWidget);
        expect(find.text('English'), findsOneWidget);

        // Ensure footer is visible and tap English footer link
        await tester.ensureVisible(find.text('English'));
        await tester.tap(find.text('English'));
        await tester.pumpAndSettle();

        // Language modal opened -> Tap Japanese (日本語)
        await tester.tap(find.text('日本語'));
        await tester.pumpAndSettle();

        // App dynamically updates to Japanese!
        expect(find.text('ログイン'), findsOneWidget);
        expect(find.text('日本語'), findsOneWidget);
      },
    );
  });
}
