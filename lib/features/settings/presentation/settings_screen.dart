import 'package:ezbookkeeping/core/localization/app_language.dart';
import 'package:ezbookkeeping/core/localization/language_selector_modal.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ezbookkeeping/app/router/app_routes.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/core/theme/theme_controller.dart';
import 'package:ezbookkeeping/features/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:ezbookkeeping/features/authentication/presentation/bloc/authentication_event.dart';
import 'package:ezbookkeeping/features/settings/widgets/theme_picker_sheet.dart';
import 'package:ezbookkeeping/features/settings/widgets/timezone_picker_sheet.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentTimezone = '(UTC+05:30) System Default';
  String _currentTextSize = 'Default';
  final String _exchangeRatesDate = 'September 10, 2026';
  final String _appVersion = 'v2.0.0-dev (d96ba0c)';

  String get _formattedExchangeRatesDate {
    if (getIt.isRegistered<ExchangeRateService>()) {
      final service = getIt<ExchangeRateService>();
      if (service.updateTime != null) {
        final date = service.updateTime!;
        const months = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December',
        ];
        return '${months[date.month - 1]} ${date.day}, ${date.year}';
      }
    }
    return _exchangeRatesDate;
  }

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  void _showThemePicker() {
    final themeController = ThemeScope.maybeOf(context);
    final currentMode = themeController?.themeMode ?? ThemeMode.light;

    ThemePickerSheet.show(
      context,
      currentMode: currentMode,
      onModeSelected: (mode) {
        themeController?.setThemeMode(mode);
        setState(() {});
      },
    );
  }

  void _showTimezonePicker() {
    TimezonePickerSheet.show(
      context,
      currentTimezone: _currentTimezone,
      onTimezoneSelected: (tz) {
        setState(() => _currentTimezone = tz);
      },
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out of demo?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC86D3B),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                if (getIt.isRegistered<AuthenticationBloc>()) {
                  getIt<AuthenticationBloc>().add(const LogoutRequested());
                }
                context.go(AppRoutes.login);
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  void _showNotice(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title opened'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark
        ? const Color(0xFF0F0F11)
        : const Color(0xFFEFF1F5);
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final sectionHeaderColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final subtextColor = isDark
        ? const Color(0xFF8E8E93)
        : const Color(0xFF8E8E93);
    final chevronColor = isDark
        ? const Color(0xFF636366)
        : const Color(0xFFC7C7CC);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.05);

    final cardShadow = [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
        blurRadius: 12,
        offset: const Offset(0, 2),
      ),
    ];

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Row(
                    children: [
                      // Back button
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: cardBg,
                          shape: BoxShape.circle,
                          boxShadow: isDark
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => context.pop(),
                            child: Center(
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: textColor,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Title
                      Expanded(
                        child: Text(
                          'Settings',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      // Spacer to balance back button
                      const SizedBox(width: 42),
                    ],
                  ),
                ),
              ),
            ),

            // Settings Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // SECTION 1: User Profile & Account (demo)
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'demo',
                            style: TextStyle(
                              color: sectionHeaderColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: cardShadow,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildSettingItem(
                                title: 'User Profile',
                                textColor: textColor,
                                chevronColor: chevronColor,
                                onTap: () =>
                                    context.push(AppRoutes.userProfile),
                              ),
                              _buildDivider(dividerColor),
                              _buildSettingItem(
                                title: 'Transaction Categories',
                                textColor: textColor,
                                chevronColor: chevronColor,
                                onTap: () => context.push(
                                  AppRoutes.transactionCategories,
                                ),
                              ),
                              _buildDivider(dividerColor),
                              _buildSettingItem(
                                title: 'Transaction Tags',
                                textColor: textColor,
                                chevronColor: chevronColor,
                                onTap: () =>
                                    context.push(AppRoutes.transactionTags),
                              ),
                              _buildDivider(dividerColor),
                              _buildSettingItem(
                                title: 'Transaction Templates',
                                textColor: textColor,
                                chevronColor: chevronColor,
                                onTap: () => context.push(
                                  AppRoutes.transactionTemplates,
                                ),
                              ),
                              _buildDivider(dividerColor),
                              _buildSettingItem(
                                title: 'Scheduled Transactions',
                                textColor: textColor,
                                chevronColor: chevronColor,
                                onTap: () =>
                                    _showNotice('Scheduled Transactions'),
                              ),
                              _buildDivider(dividerColor),
                              _buildSettingItem(
                                title: 'Data Management',
                                textColor: textColor,
                                chevronColor: chevronColor,
                                onTap: () =>
                                    context.push(AppRoutes.dataManagement),
                              ),
                              _buildDivider(dividerColor),
                              // _buildSettingItem(
                              //   title: 'Two-Factor Authentication',
                              //   textColor: textColor,
                              //   chevronColor: chevronColor,
                              //   onTap: () =>
                              //       context.push(AppRoutes.twoFactorAuth),
                              // ),
                              // _buildDivider(dividerColor),
                              _buildSettingItem(
                                title: 'Device & Sessions',
                                textColor: textColor,
                                chevronColor: chevronColor,
                                onTap: () =>
                                    context.push(AppRoutes.deviceAndSessions),
                              ),
                              _buildDivider(dividerColor),
                              // Log Out Action
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _confirmLogout,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Log Out',
                                      style: TextStyle(
                                        color: Color(0xFFC86D3B),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // SECTION 2: Application
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'Application',
                            style: TextStyle(
                              color: sectionHeaderColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: cardShadow,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildSettingItem(
                                title: 'Theme',
                                trailingValue: _getThemeLabel(
                                  ThemeScope.maybeOf(context)?.themeMode ??
                                      ThemeMode.light,
                                ),
                                textColor: textColor,
                                subtextColor: subtextColor,
                                chevronColor: chevronColor,
                                onTap: _showThemePicker,
                              ),
                              _buildDivider(dividerColor),
                              _buildSettingItem(
                                title: 'Language',
                                trailingValue: AppLanguage.fromLocale(
                                  Localizations.localeOf(context),
                                ).nativeName,
                                textColor: textColor,
                                subtextColor: subtextColor,
                                chevronColor: chevronColor,
                                onTap: () =>
                                    LanguageSelectorModal.show(context),
                              ),
                              _buildDivider(dividerColor),
                              _buildSettingItem(
                                title: 'Text Size',
                                trailingValue:
                                    ThemeScope.maybeOf(
                                      context,
                                    )?.currentTextScale.label ??
                                    _currentTextSize,
                                textColor: textColor,
                                subtextColor: subtextColor,
                                chevronColor: chevronColor,
                                onTap: () async {
                                  final theme = ThemeScope.maybeOf(context);
                                  final activeLabel =
                                      theme?.currentTextScale.label ??
                                      _currentTextSize;
                                  final res = await context.push<String>(
                                    AppRoutes.textSize,
                                    extra: activeLabel,
                                  );
                                  if (res != null && mounted) {
                                    theme?.setTextScaleByLabel(res);
                                    setState(() => _currentTextSize = res);
                                  }
                                },
                              ),
                              _buildDivider(dividerColor),
                              _buildSettingItem(
                                title: 'Timezone',
                                trailingValue: _currentTimezone,
                                textColor: textColor,
                                subtextColor: subtextColor,
                                chevronColor: chevronColor,
                                onTap: _showTimezonePicker,
                              ),
                              _buildDivider(dividerColor),
                              // _buildSettingItem(
                              //   title: 'Application Lock',
                              //   trailingValue: _appLock,
                              //   textColor: textColor,
                              //   subtextColor: subtextColor,
                              //   chevronColor: chevronColor,
                              //   onTap: () async {
                              //     final res = await context.push<String>(
                              //       AppRoutes.applicationLock,
                              //       extra: _appLock,
                              //     );
                              //     if (res != null && mounted) {
                              //       setState(() => _appLock = res);
                              //     }
                              //   },
                              // ),
                              // _buildDivider(dividerColor),
                              _buildSettingItem(
                                title: 'Exchange Rates Data',
                                trailingValue: _formattedExchangeRatesDate,
                                textColor: textColor,
                                subtextColor: subtextColor,
                                chevronColor: chevronColor,
                                onTap: () =>
                                    context.push(AppRoutes.exchangeRatesData),
                              ),
                              _buildDivider(dividerColor),
                              _buildSettingItem(
                                title: 'Preferences',
                                textColor: textColor,
                                chevronColor: chevronColor,
                                onTap: () {
                                  context.push(AppRoutes.preferences);
                                },
                              ),
                              _buildDivider(dividerColor),
                              _buildSettingItem(
                                title: 'Statistics Settings',
                                textColor: textColor,
                                chevronColor: chevronColor,
                                onTap: () {
                                  context.push(AppRoutes.statisticsSettings);
                                },
                              ),
                              _buildDivider(dividerColor),
                              // _buildSettingItem(
                              //   title: 'Settings Sync',
                              //   textColor: textColor,
                              //   chevronColor: chevronColor,
                              //   onTap: () => _showNotice('Settings Sync'),
                              // ),
                              // _buildDivider(dividerColor),
                              // _buildSettingSwitch(
                              //   title: 'Enable Swipe Back',
                              //   value: _swipeBackEnabled,
                              //   textColor: textColor,
                              //   onChanged: (val) {
                              //     setState(() => _swipeBackEnabled = val);
                              //   },
                              // ),
                              // _buildDivider(dividerColor),
                              // _buildSettingSwitch(
                              //   title: 'Enable Animation',
                              //   value: _animationEnabled,
                              //   textColor: textColor,
                              //   onChanged: (val) {
                              //     setState(() => _animationEnabled = val);
                              //   },
                              // ),
                              // _buildDivider(dividerColor),
                              // _buildSettingItem(
                              //   title: 'Browser Cache Management',
                              //   textColor: textColor,
                              //   chevronColor: chevronColor,
                              //   onTap: () =>
                              //       _showNotice('Browser Cache Management'),
                              // ),
                              // _buildDivider(dividerColor),
                              // _buildSettingItem(
                              //   title: 'Switch to Desktop Version',
                              //   showChevron: false,
                              //   textColor: textColor,
                              //   chevronColor: chevronColor,
                              //   onTap: () =>
                              //       _showNotice('Switch to Desktop Version'),
                              // ),
                              // _buildDivider(dividerColor),
                              _buildSettingItem(
                                title: 'About',
                                trailingValue: _appVersion,
                                textColor: textColor,
                                subtextColor: subtextColor,
                                chevronColor: chevronColor,
                                onTap: () => context.push(AppRoutes.about),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: color,
    );
  }

  Widget _buildSettingItem({
    required String title,
    String? trailingValue,
    required Color textColor,
    Color? subtextColor,
    required Color chevronColor,
    bool showChevron = true,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (trailingValue != null) ...[
                const SizedBox(width: 8),
                Text(
                  trailingValue,
                  style: TextStyle(
                    color: subtextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
              if (showChevron) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: chevronColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
