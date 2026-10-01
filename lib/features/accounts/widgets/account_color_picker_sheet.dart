import 'package:flutter/material.dart';

class AccountColorPickerSheet extends StatefulWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  const AccountColorPickerSheet({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  static void show(
    BuildContext context, {
    required Color selectedColor,
    required ValueChanged<Color> onColorSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AccountColorPickerSheet(
        selectedColor: selectedColor,
        onColorSelected: onColorSelected,
      ),
    );
  }

  @override
  State<AccountColorPickerSheet> createState() =>
      _AccountColorPickerSheetState();
}

class _AccountColorPickerSheetState extends State<AccountColorPickerSheet> {
  int _selectedTabIndex = 0; // 0: System Colors, 1: Custom Color
  late Color _currentColor;

  // 14 colors matching media_1789104012299.png (2 rows of 7)
  static const List<Color> _systemColors = [
    // Row 1
    Color(0xFF1C1C1E), // Black/slate
    Color(0xFF8E8E93), // Gray
    Color(0xFFEF4444), // Bright Red
    Color(0xFFF43F5E), // Pink/Rose
    Color(0xFFFF5722), // Deep Orange
    Color(0xFFFFA000), // Orange
    Color(0xFFFFD600), // Yellow
    // Row 2
    Color(0xFFCDDC39), // Lime
    Color(0xFF009688), // Teal
    Color(0xFF4CAF50), // Green
    Color(0xFF00BCD4), // Cyan/Sky
    Color(0xFF2196F3), // Light Blue
    Color(0xFF673AB7), // Deep Purple
    Color(0xFF9C27B0), // Purple/Magenta
  ];

  @override
  void initState() {
    super.initState();
    _currentColor = widget.selectedColor;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFEFF1F5);
    final tabBg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE2E4EB);
    final activeTabBg = isDark ? const Color(0xFF3A3A3C) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final circleBtnBg = isDark ? const Color(0xFF2C2C2E) : Colors.white;

    final shadow = isDark
        ? null
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ];

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.only(top: 12, bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : const Color(0xFFB0B3BC),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Top Header Row with Close Button and Segmented Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Close button (✕)
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: circleBtnBg,
                    shape: BoxShape.circle,
                    boxShadow: shadow,
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
                          color: textColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Segmented control: System Colors | Custom Color
                Expanded(
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: tabBg,
                      borderRadius: BorderRadius.circular(21),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTabIndex = 0),
                            behavior: HitTestBehavior.opaque,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: _selectedTabIndex == 0
                                    ? activeTabBg
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: _selectedTabIndex == 0 && !isDark
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.06,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'System Colors',
                                style: TextStyle(
                                  color: _selectedTabIndex == 0
                                      ? textColor
                                      : const Color(0xFF64748B),
                                  fontSize: 14,
                                  fontWeight: _selectedTabIndex == 0
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTabIndex = 1),
                            behavior: HitTestBehavior.opaque,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: _selectedTabIndex == 1
                                    ? activeTabBg
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: _selectedTabIndex == 1 && !isDark
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.06,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Custom Color',
                                style: TextStyle(
                                  color: _selectedTabIndex == 1
                                      ? textColor
                                      : const Color(0xFF64748B),
                                  fontSize: 14,
                                  fontWeight: _selectedTabIndex == 1
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Color Palette Grid (2 rows of 7)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _systemColors.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, index) {
                final color = _systemColors[index];
                final isSelected = color == _currentColor;

                return GestureDetector(
                  onTap: () {
                    setState(() => _currentColor = color);
                    widget.onColorSelected(color);
                    Navigator.pop(context);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          right: -3,
                          bottom: -3,
                          child: Container(
                            width: 15,
                            height: 15,
                            decoration: const BoxDecoration(
                              color: Color(0xFFC86D3B),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 11,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
