import 'package:flutter/material.dart';

class ThemePickerSheet extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onModeSelected;

  const ThemePickerSheet({
    super.key,
    required this.currentMode,
    required this.onModeSelected,
  });

  static void show(
    BuildContext context, {
    required ThemeMode currentMode,
    required ValueChanged<ThemeMode> onModeSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ThemePickerSheet(
        currentMode: currentMode,
        onModeSelected: onModeSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final contentBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final lowerBg = isDark ? const Color(0xFF0F0F11) : const Color(0xFFEFF1F5);
    final circleBtnBg = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final iconColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final checkColor = const Color(0xFFC86D3B);

    final circleShadow = isDark
        ? null
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ];

    final sheetHeight = MediaQuery.of(context).size.height * 0.85;

    final themeOptions = [
      {'label': 'System Default', 'mode': ThemeMode.system},
      {'label': 'Light', 'mode': ThemeMode.light},
      {'label': 'Dark', 'mode': ThemeMode.dark},
    ];

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: headerBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // 1. Top Header Bar with '✕', 'Theme', and '🔍'
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Circular Close Button (✕)
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: circleBtnBg,
                    shape: BoxShape.circle,
                    boxShadow: circleShadow,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Center(
                        child: Icon(
                          Icons.close_rounded,
                          color: iconColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),

                // Title "Theme"
                Expanded(
                  child: Text(
                    'Theme',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),

                // Circular Search Button (🔍)
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: circleBtnBg,
                    shape: BoxShape.circle,
                    boxShadow: circleShadow,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {},
                      child: Center(
                        child: Icon(
                          Icons.search_rounded,
                          color: iconColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Options Card Container (White / Dark card area)
          Container(
            color: contentBg,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: themeOptions.map((opt) {
                final mode = opt['mode'] as ThemeMode;
                final label = opt['label'] as String;
                final isSelected = mode == currentMode;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      onModeSelected(mode);
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          // Left Checkmark indicator slot
                          SizedBox(
                            width: 24,
                            child: isSelected
                                ? Icon(
                                    Icons.check_rounded,
                                    size: 20,
                                    color: checkColor,
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(width: 8),
                          // Option Text
                          Text(
                            label,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // 3. Lower Area with Soft Light Gray / Dark Background
          Expanded(child: Container(color: lowerBg)),
        ],
      ),
    );
  }
}
