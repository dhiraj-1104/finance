import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _showNotice(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
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

    final pillShadow = isDark
        ? null
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ];

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
                      // Back Button (<)
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: cardBg,
                          shape: BoxShape.circle,
                          boxShadow: pillShadow,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              final router = GoRouter.maybeOf(context);
                              if (router != null && router.canPop()) {
                                router.pop();
                              } else if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                            },
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

                      // Title "About"
                      Expanded(
                        child: Text(
                          'About',
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

            // Content
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
                        // SECTION 1: ezBookkeeping
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'ezBookkeeping',
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
                              _buildAboutItem(
                                title: 'Version',
                                trailingValue: 'v2.0.0-dev (d96ba0c)',
                                showChevron: false,
                                textColor: textColor,
                                subtextColor: subtextColor,
                                chevronColor: chevronColor,
                                onTap: () => _showNotice(
                                  context,
                                  'ezBookkeeping v2.0.0-dev (d96ba0c)',
                                ),
                              ),
                              _buildDivider(dividerColor),
                              _buildAboutItem(
                                title: 'Build Time',
                                trailingValue: 'September 10, 2026 08:43:37 PM',
                                showChevron: false,
                                textColor: textColor,
                                subtextColor: subtextColor,
                                chevronColor: chevronColor,
                                onTap: () => _showNotice(
                                  context,
                                  'Build: September 10, 2026 08:43:37 PM',
                                ),
                              ),
                              _buildDivider(dividerColor),
                              _buildAboutItem(
                                title: 'Official Website',
                                showChevron: true,
                                textColor: textColor,
                                subtextColor: subtextColor,
                                chevronColor: chevronColor,
                                onTap: () => _showNotice(
                                  context,
                                  'https://ezbookkeeping.mayswind.net',
                                ),
                              ),
                              _buildDivider(dividerColor),
                              _buildAboutItem(
                                title: 'Report Issue',
                                showChevron: true,
                                textColor: textColor,
                                subtextColor: subtextColor,
                                chevronColor: chevronColor,
                                onTap: () => _showNotice(
                                  context,
                                  'Opening issue reporter...',
                                ),
                              ),
                              _buildDivider(dividerColor),
                              _buildAboutItem(
                                title: 'Getting help',
                                showChevron: true,
                                textColor: textColor,
                                subtextColor: subtextColor,
                                chevronColor: chevronColor,
                                onTap: () => _showNotice(
                                  context,
                                  'Opening documentation...',
                                ),
                              ),
                              _buildDivider(dividerColor),
                              _buildAboutItem(
                                title: 'License',
                                showChevron: true,
                                textColor: textColor,
                                subtextColor: subtextColor,
                                chevronColor: chevronColor,
                                onTap: () =>
                                    _showNotice(context, 'MIT License'),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // SECTION 2: Exchange Rates Data
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'Exchange Rates Data',
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
                              () {
                                final provider =
                                    getIt.isRegistered<ExchangeRateService>() &&
                                            getIt<ExchangeRateService>()
                                                    .dataSource !=
                                                null
                                        ? getIt<ExchangeRateService>()
                                            .dataSource!
                                        : 'European Central Bank';
                                return _buildAboutItem(
                                  title: 'Provider',
                                  trailingValue: provider,
                                  showChevron: true,
                                  textColor: textColor,
                                  subtextColor: subtextColor,
                                  chevronColor: chevronColor,
                                  onTap: () => _showNotice(
                                    context,
                                    'Exchange Rates Provider: $provider',
                                  ),
                                );
                              }(),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // SECTION 3: Map
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'Map',
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
                              _buildAboutItem(
                                title: 'Provider',
                                trailingValue: 'OpenStreetMap',
                                showChevron: true,
                                textColor: textColor,
                                subtextColor: subtextColor,
                                chevronColor: chevronColor,
                                onTap: () => _showNotice(
                                  context,
                                  'Map Provider: OpenStreetMap',
                                ),
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
      margin: const EdgeInsets.symmetric(horizontal: 18),
      height: 1,
      color: color,
    );
  }

  Widget _buildAboutItem({
    required String title,
    String? trailingValue,
    bool showChevron = true,
    required Color textColor,
    Color? subtextColor,
    required Color chevronColor,
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
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              if (trailingValue != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    trailingValue,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: subtextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ] else ...[
                const Spacer(),
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
