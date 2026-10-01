import 'package:ezbookkeeping/core/localization/app_language.dart';
import 'package:ezbookkeeping/core/localization/locale_controller.dart';
import 'package:flutter/material.dart';

/// Floating modal dialog for selecting the application language matching the design reference.
class LanguageSelectorModal extends StatelessWidget {
  const LanguageSelectorModal({super.key});

  /// Shows the language selector modal dialog.
  static Future<AppLanguage?> show(BuildContext context) {
    return showDialog<AppLanguage>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      builder: (ctx) => const LanguageSelectorModal(),
    );
  }

  static const Color _copperAccent = Color(0xFFC86D3B);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final localeController = LocaleScope.of(context);
    final currentLanguage = localeController.currentLanguage;

    final cardBg = isDark
        ? const Color(0xFF2C2C2E).withValues(alpha: 0.96)
        : const Color(0xFFF7F5F0).withValues(alpha: 0.98);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.06);
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1E1E1E);
    final subtitleTextColor = isDark
        ? const Color(0xFF8E8E93)
        : const Color(0xFF7A7A7A);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: AppLanguage.supportedLanguages.map((lang) {
                  final isSelected = lang.code == currentLanguage.code;

                  return InkWell(
                    onTap: () async {
                      await localeController.setLanguage(lang);
                      if (context.mounted) {
                        Navigator.of(context).pop(lang);
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    splashColor: _copperAccent.withValues(alpha: 0.12),
                    highlightColor: _copperAccent.withValues(alpha: 0.06),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 13,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Native Name (Left)
                          Text(
                            lang.nativeName,
                            style: TextStyle(
                              color: primaryTextColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.2,
                            ),
                          ),

                          // English subtitle OR Selected Copper Checkmark (Right)
                          if (isSelected)
                            const Icon(
                              Icons.check_rounded,
                              color: _copperAccent,
                              size: 20,
                            )
                          else
                            Text(
                              lang.englishName,
                              style: TextStyle(
                                color: subtitleTextColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
