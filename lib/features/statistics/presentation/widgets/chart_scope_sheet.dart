import 'package:flutter/material.dart';

/// Floating dropdown menu for selecting chart analysis scope matching media_1789987142145.png.
class ChartScopeSheet extends StatelessWidget {
  final String selectedScope;
  final ValueChanged<String> onSelected;

  static const List<String> scopes = [
    'Outflows By Account',
    'Expense By Account',
    'Expense By Primary Category',
    'Expense By Secondary Category',
    'Inflows By Account',
    'Income By Account',
    'Income By Primary Category',
    'Income By Secondary Category',
  ];

  const ChartScopeSheet({
    super.key,
    required this.selectedScope,
    required this.onSelected,
  });

  static Future<String?> show(
    BuildContext context, {
    required String currentScope,
    Offset? position,
  }) async {
    return showDialog<String>(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) {
        return Stack(
          children: [
            Positioned(
              top: position?.dy ?? 60.0,
              left: 24,
              right: 24,
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: ChartScopeSheet(
                    selectedScope: currentScope,
                    onSelected: (scope) {
                      Navigator.of(context).pop(scope);
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F3F6);
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E1E);
    final subtextColor = isDark
        ? const Color(0xFF8E8E93)
        : const Color(0xFF7A7D85);
    final dividerColor = isDark ? Colors.white12 : const Color(0xFFE5E5EA);
    const checkmarkColor = Color(0xFFC86D3B);

    return Container(
      width: 250,
      constraints: const BoxConstraints(maxHeight: 460),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header title "Categorical Analysis"
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  'Categorical Analysis',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: subtextColor,
                  ),
                ),
              ),
              Divider(height: 1, thickness: 0.8, color: dividerColor),

              for (int i = 0; i < scopes.length; i++) ...[
                _buildScopeItem(
                  context: context,
                  scope: scopes[i],
                  isSelected: scopes[i] == selectedScope,
                  textColor: textColor,
                  checkmarkColor: checkmarkColor,
                ),
                if (i < scopes.length - 1)
                  Divider(height: 1, thickness: 0.8, color: dividerColor),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScopeItem({
    required BuildContext context,
    required String scope,
    required bool isSelected,
    required Color textColor,
    required Color checkmarkColor,
  }) {
    return InkWell(
      onTap: () => onSelected(scope),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                scope,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: textColor,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check, size: 18, color: checkmarkColor)
            else
              const SizedBox(width: 18),
          ],
        ),
      ),
    );
  }
}
