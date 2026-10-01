import 'package:flutter/material.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';

/// Screen allowing the user to view and reorder account categories via drag-and-drop handles.
class AccountCategoryOrderScreen extends StatefulWidget {
  final PreferencesController? controller;

  const AccountCategoryOrderScreen({super.key, this.controller});

  @override
  State<AccountCategoryOrderScreen> createState() =>
      _AccountCategoryOrderScreenState();
}

class _AccountCategoryOrderScreenState
    extends State<AccountCategoryOrderScreen> {
  static const Color _copperAccent = Color(0xFFC86D3B);

  PreferencesController? _preferencesController;
  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _preferencesController = widget.controller;
    } else if (getIt.isRegistered<PreferencesController>()) {
      _preferencesController = getIt<PreferencesController>();
    }

    final initialCategories = _preferencesController?.accountCategories ??
        PreferencesController.defaultAccountCategories;
    _categories = List<String>.from(initialCategories);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = _categories.removeAt(oldIndex);
      _categories.insert(newIndex, item);
    });
  }

  void _saveAndExit() {
    _preferencesController?.setAccountCategories(_categories);
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context, _categories);
    }
  }

  void _showMoreActionsSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actionButtonBg =
        isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Reset to Default Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: actionButtonBg,
                        foregroundColor: _copperAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _categories = List<String>.from(
                            PreferencesController.defaultAccountCategories,
                          );
                        });
                        Navigator.pop(sheetContext);
                      },
                      child: const Text(
                        'Reset to Default',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _copperAccent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Cancel Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: actionButtonBg,
                        foregroundColor: _copperAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                        ),
                      ),
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _copperAccent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg =
        isDark ? const Color(0xFF0F0F11) : const Color(0xFFEFF1F5);
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final dragHandleColor =
        isDark ? const Color(0xFF8E8E93) : const Color(0xFFB0B3C1);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.05);

    final pillShadow = isDark
        ? null
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ];

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Row(
                    children: [
                      // Back Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (mounted && Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: cardBg,
                              shape: BoxShape.circle,
                              boxShadow: pillShadow,
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.05),
                              ),
                            ),
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
                      // Centered Title
                      Expanded(
                        child: Text(
                          'Account Category Order',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      // Action Capsule (More ... and Save ✓)
                      Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: pillShadow,
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // More Options (...) Button
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _showMoreActionsSheet,
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                  child: Icon(
                                    Icons.more_horiz_rounded,
                                    color: textColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            // Save / Confirm (✓) Button
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _saveAndExit,
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                  child: Icon(
                                    Icons.check_rounded,
                                    color: textColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Draggable Categories List Card
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          canvasColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: ReorderableListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          buildDefaultDragHandles: false,
                          itemCount: _categories.length,
                          onReorder: _onReorder,
                          itemBuilder: (context, index) {
                            final categoryName = _categories[index];
                            final isLast = index == _categories.length - 1;

                            return Container(
                              key: ValueKey(categoryName),
                              decoration: BoxDecoration(
                                color: cardBg,
                                border: isLast
                                    ? null
                                    : Border(
                                        bottom: BorderSide(
                                          color: dividerColor,
                                          width: 1,
                                        ),
                                      ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  // Category Title
                                  Expanded(
                                    child: Text(
                                      categoryName,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: -0.1,
                                      ),
                                    ),
                                  ),
                                  // 3-line Drag Handle
                                  ReorderableDragStartListener(
                                    index: index,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: _buildDragHandleIcon(
                                        dragHandleColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
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

  /// Custom 3 horizontal lines drag handle widget matching ezBookkeeping design.
  Widget _buildDragHandleIcon(Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 18,
          height: 1.8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(height: 3.5),
        Container(
          width: 18,
          height: 1.8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(height: 3.5),
        Container(
          width: 18,
          height: 1.8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }
}
