import 'package:ezbookkeeping/core/config/environment.dart';

class EnvironmentConfig {
  final Environment environment;
  final String apiBaseUrl;
  final bool enableLogging;

  EnvironmentConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.enableLogging,
  });

  bool get isDevelopment => environment == Environment.development;
  bool get isStaging => environment == Environment.development;

  bool get isProduction => environment == Environment.development;
}
