import 'package:ezbookkeeping/app/router/app_router.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/core/localization/locale_controller.dart';
import 'package:ezbookkeeping/core/theme/app_theme.dart';
import 'package:ezbookkeeping/core/theme/theme_controller.dart';
import 'package:ezbookkeeping/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class App extends StatefulWidget {
  final LocaleController? localeController;
  final ThemeController? themeController;

  const App({super.key, this.localeController, this.themeController});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final ThemeController _themeController;
  late final LocaleController _localeController;

  @override
  void initState() {
    super.initState();
    _themeController = widget.themeController ?? ThemeController();
    _localeController =
        widget.localeController ??
        (getIt.isRegistered<LocaleController>()
            ? getIt<LocaleController>()
            : LocaleController());
  }

  @override
  void dispose() {
    if (widget.themeController == null) {
      _themeController.dispose();
    }
    if (widget.localeController == null &&
        !getIt.isRegistered<LocaleController>()) {
      _localeController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LocaleScope(
      controller: _localeController,
      child: ThemeScope(
        controller: _themeController,
        child: ListenableBuilder(
          listenable: Listenable.merge([_themeController, _localeController]),
          builder: (context, _) {
            return MaterialApp.router(
              title: 'ezBookkeeping',
              debugShowCheckedModeBanner: false,
              routerConfig: appRouter,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: _themeController.themeMode,
              locale: _localeController.locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) {
                final mediaQuery = MediaQuery.of(context);
                return MediaQuery(
                  data: mediaQuery.copyWith(
                    textScaler: TextScaler.linear(
                      _themeController.textScaleFactor,
                    ),
                  ),
                  child: child ?? const SizedBox.shrink(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
