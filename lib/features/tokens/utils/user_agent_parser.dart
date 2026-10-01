import 'package:flutter/material.dart';

/// Helper utility for converting raw user-agent strings into human-readable device/browser names.
class UserAgentParser {
  UserAgentParser._();

  /// Returns a human-friendly client name, e.g. "Chrome on Windows", "Safari on iPhone".
  static String parseClientName(String userAgent) {
    final ua = userAgent.trim();
    if (ua.isEmpty) {
      return 'Unknown Device';
    }

    if (ua.contains('ezBookkeeping-Flutter') || ua.contains('ezBookkeeping')) {
      return 'ezBookkeeping Flutter App';
    }

    final isWindows = ua.contains('Windows') || ua.contains('Win64') || ua.contains('Win32');
    final isMac = ua.contains('Macintosh') || ua.contains('Mac OS X');
    final isIPhone = ua.contains('iPhone');
    final isIPad = ua.contains('iPad');
    final isAndroid = ua.contains('Android');
    final isLinux = ua.contains('Linux') && !isAndroid;

    String os = '';
    if (isIPhone) {
      os = 'iPhone';
    } else if (isIPad) {
      os = 'iPad';
    } else if (isAndroid) {
      os = 'Android';
    } else if (isWindows) {
      os = 'Windows';
    } else if (isMac) {
      os = 'macOS';
    } else if (isLinux) {
      os = 'Linux';
    }

    String browser = '';
    if (ua.contains('WeChat') || ua.contains('MicroMessenger')) {
      browser = 'WeChat';
    } else if (ua.contains('Edg/') || ua.contains('Edge/')) {
      browser = 'Edge';
    } else if (ua.contains('Chrome/') && !ua.contains('Edg/')) {
      browser = 'Chrome';
    } else if (ua.contains('Firefox/')) {
      browser = 'Firefox';
    } else if (ua.contains('Safari/') && !ua.contains('Chrome/')) {
      browser = 'Safari';
    } else if (ua.contains('Mobile Safari')) {
      browser = 'Safari';
    }

    if (browser.isNotEmpty && os.isNotEmpty) {
      return '$browser on $os';
    } else if (os.isNotEmpty) {
      return os;
    } else if (browser.isNotEmpty) {
      return browser;
    }

    return ua.length > 40 ? '${ua.substring(0, 37)}...' : ua;
  }

  /// Whether the user-agent describes a desktop system.
  static bool isDesktop(String userAgent) {
    final ua = userAgent.toLowerCase();
    if (ua.contains('mobile') ||
        ua.contains('android') ||
        ua.contains('iphone') ||
        ua.contains('ipad') ||
        ua.contains('ipod')) {
      return false;
    }
    if (ua.contains('windows') || ua.contains('macintosh') || ua.contains('linux')) {
      return true;
    }
    return false;
  }

  /// Returns an appropriate icon for the user-agent device.
  static IconData getDeviceIcon(String userAgent) {
    final ua = userAgent.toLowerCase();
    if (ua.contains('iphone') || (ua.contains('android') && ua.contains('mobile'))) {
      return Icons.smartphone_outlined;
    } else if (ua.contains('ipad') || (ua.contains('android') && !ua.contains('mobile'))) {
      return Icons.tablet_mac_outlined;
    } else if (ua.contains('windows') || ua.contains('macintosh') || ua.contains('linux')) {
      return Icons.desktop_windows_outlined;
    }
    return Icons.devices_outlined;
  }
}
