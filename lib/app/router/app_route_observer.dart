import 'package:ezbookkeeping/core/logger/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A [NavigatorObserver] that logs screen navigation events to the console.
class AppRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    final from = previousRoute?.settings.name ?? 'None';
    final to = route.settings.name ?? 'Unknown';
    _logNavigation('PUSH', from: from, to: to);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    final from = route.settings.name ?? 'Unknown';
    final to = previousRoute?.settings.name ?? 'None';
    _logNavigation('POP', from: from, to: to);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final from = oldRoute?.settings.name ?? 'None';
    final to = newRoute?.settings.name ?? 'Unknown';
    _logNavigation('REPLACE', from: from, to: to);
  }

  void _logNavigation(
    String action, {
    required String from,
    required String to,
  }) {
    final message = '[$action] Screen transition: "$from" ➡️ "$to"';
    // AppLogger.info(message);
    if (kDebugMode) {
      AppLogger.info('[Navigation] $message');
    }
  }
}
