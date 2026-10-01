import 'package:ezbookkeeping/core/config/environment.dart';
import 'package:ezbookkeeping/core/config/environment_config.dart';
import 'package:flutter/services.dart';

class AppConfig {
  static EnvironmentConfig get current {
    switch (appFlavor) {
      case 'development':
        return EnvironmentConfig(
          environment: Environment.development,
          apiBaseUrl: '',
          enableLogging: true,
        );
      case 'staging':
        return EnvironmentConfig(
          environment: Environment.staging,
          apiBaseUrl: '',
          enableLogging: true,
        );
      case 'production':
        return EnvironmentConfig(
          environment: Environment.production,
          apiBaseUrl: '',
          enableLogging: false,
        );
      default:
        throw Exception("Unknown Flutter flavor: $appFlavor");
    }
  }
}
