import 'package:ezbookkeeping/app/app.dart';
import 'package:ezbookkeeping/app/app_config.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/core/logger/app_logger.dart';
import 'package:flutter/material.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.current;
  AppLogger.initialize(enabled: config.enableLogging);
  AppLogger.info('Application starting: ${config.environment.name}');
  await setupDependencies();
  try {
    final shouldAutoUpdate = getIt.isRegistered<PreferencesController>()
        ? getIt<PreferencesController>().autoUpdateExchangeRates
        : true;
    if (shouldAutoUpdate && getIt.isRegistered<ExchangeRateService>()) {
      await getIt<ExchangeRateService>().initialize();
    }
  } catch (e, stackTrace) {
    AppLogger.error(
      'Failed to initialize exchange rates during startup: $e',
      e,
      stackTrace,
    );
  }
  runApp(App());
}
