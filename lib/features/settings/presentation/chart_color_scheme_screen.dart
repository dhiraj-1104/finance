import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';

/// Screen allowing the user to view, customize, reorder, import, and export the chart color scheme.
class ChartColorSchemeScreen extends StatefulWidget {
  final PreferencesController? controller;

  const ChartColorSchemeScreen({super.key, this.controller});

  @override
  State<ChartColorSchemeScreen> createState() => _ChartColorSchemeScreenState();
}

class _ChartColorSchemeScreenState extends State<ChartColorSchemeScreen> {
  static const Color _copperAccent = Color(0xFFC86D3B);

  PreferencesController? _preferencesController;
  late List<String> _colors;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _preferencesController = widget.controller;
    } else if (getIt.isRegistered<PreferencesController>()) {
      _preferencesController = getIt<PreferencesController>();
    }

    final initialColors = _preferencesController?.chartColors ??
        PreferencesController.defaultChartColors;
    _colors = List<String>.from(initialColors);
  }

  Color _parseHexColor(String hexString) {
    try {
      final clean = hexString.replaceAll('#', '').trim();
      if (clean.length == 6) {
        final val = int.parse('FF$clean', radix: 16);
        return Color(val);
      } else if (clean.length == 3) {
        final r = clean[0];
        final g = clean[1];
        final b = clean[2];
        final val = int.parse('FF$r$r$g$g$b$b', radix: 16);
        return Color(val);
      }
    } catch (_) {}
    return const Color(0xFFC86D3B);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = _colors.removeAt(oldIndex);
      _colors.insert(newIndex, item);
    });
  }

  void _deleteColor(int index) {
    setState(() {
      _colors.removeAt(index);
    });
  }

  void _saveAndExit() {
    _preferencesController?.setChartColors(_colors);
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context, _colors);
    }
  }

  void _showMoreActionsSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actionCardBg =
        isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

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
                  // Action Menu Card (Add, Import, Export)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: actionCardBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Add Option
                        InkWell(
                          onTap: () {
                            Navigator.pop(sheetContext);
                            _showAddColorModal();
                          },
                          child: Container(
                            height: 52,
                            alignment: Alignment.center,
                            child: const Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: _copperAccent,
                              ),
                            ),
                          ),
                        ),
                        Divider(height: 1, thickness: 1, color: dividerColor),
                        // Import Option
                        InkWell(
                          onTap: () {
                            Navigator.pop(sheetContext);
                            _showImportSheet();
                          },
                          child: Container(
                            height: 52,
                            alignment: Alignment.center,
                            child: const Text(
                              'Import',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: _copperAccent,
                              ),
                            ),
                          ),
                        ),
                        Divider(height: 1, thickness: 1, color: dividerColor),
                        // Export Option
                        InkWell(
                          onTap: () {
                            Navigator.pop(sheetContext);
                            _showExportSheet();
                          },
                          child: Container(
                            height: 52,
                            alignment: Alignment.center,
                            child: const Text(
                              'Export',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: _copperAccent,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Reset to Default Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: actionCardBg,
                        foregroundColor: _copperAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _colors = List<String>.from(
                            PreferencesController.defaultChartColors,
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
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: actionCardBg,
                        foregroundColor: _copperAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
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

  void _showAddColorModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final inputBg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7);

    final controller = TextEditingController();
    Color previewColor = const Color(0xFFC86D3B);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 12,
                  bottom: MediaQuery.of(modalContext).viewInsets.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : const Color(0xFFE2E4EB),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Add Color',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: previewColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? Colors.white24 : Colors.black12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextField(
                            controller: controller,
                            autofocus: true,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              hintText: 'e.g. #c67e48 or c67e48',
                              hintStyle: TextStyle(
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                              filled: true,
                              fillColor: inputBg,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            ),
                            onChanged: (val) {
                              setModalState(() {
                                previewColor = _parseHexColor(val);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _copperAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          final text = controller.text.trim();
                          if (text.isNotEmpty) {
                            final hex = text.startsWith('#') ? text : '#$text';
                            setState(() {
                              _colors.add(hex.toLowerCase());
                            });
                          }
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: _copperAccent),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showImportSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF9F9F9);
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final inputBg = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final inputBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

    final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag Handle Bar
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : const Color(0xFF636366),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    'Import',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Input Box
                  Container(
                    decoration: BoxDecoration(
                      color: inputBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: inputBorderColor),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: textController,
                      maxLines: 8,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                      decoration: const InputDecoration(
                        hintText:
                            'Each line should be a hex color value (e.g.\nc67e48 or #c67e48)',
                        hintStyle: TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 14,
                          height: 1.4,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Import Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4A383),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        final raw = textController.text.trim();
                        if (raw.isNotEmpty) {
                          final lines = raw.split(RegExp(r'[\r\n]+'));
                          final newColors = <String>[];
                          for (final line in lines) {
                            final trimmed = line.trim();
                            if (trimmed.isEmpty) continue;
                            final clean = trimmed.replaceAll('#', '');
                            if (clean.length == 6 || clean.length == 3) {
                              newColors.add('#${clean.toLowerCase()}');
                            }
                          }
                          if (newColors.isNotEmpty) {
                            setState(() {
                              _colors = newColors;
                            });
                          }
                        }
                        Navigator.pop(sheetContext);
                      },
                      child: const Text(
                        'Import',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Cancel Button
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
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

  void _showExportSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF9F9F9);
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final colorsText = _colors.join('\n');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag Handle Bar
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : const Color(0xFF636366),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Header with Export Title and Copy Icon
                  Row(
                    children: [
                      Text(
                        'Export',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          await Clipboard.setData(
                            ClipboardData(text: colorsText),
                          );
                          if (sheetContext.mounted) {
                            ScaffoldMessenger.of(sheetContext).showSnackBar(
                              const SnackBar(
                                content: Text('Copied to clipboard'),
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.copy_rounded,
                            color: _copperAccent,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Exported Colors Text Content
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        colorsText,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontFamily: 'monospace',
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Close Button
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
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
                          'Chart Color Scheme',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      // Right Action Capsule (More ... and Save ✓)
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

            // Draggable Colors List Card
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
                          itemCount: _colors.length,
                          onReorder: _onReorder,
                          itemBuilder: (context, index) {
                            final colorHex = _colors[index];
                            final isLast = index == _colors.length - 1;
                            final parsedColor = _parseHexColor(colorHex);

                            return Container(
                              key: ValueKey('color_${colorHex}_$index'),
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
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  // Color Square Badge
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: parsedColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Hex Value Text
                                  Expanded(
                                    child: Text(
                                      colorHex,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: -0.1,
                                      ),
                                    ),
                                  ),
                                  // Delete Button (Red minus circle)
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => _deleteColor(index),
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        width: 22,
                                        height: 22,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE75A4C),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.remove_rounded,
                                            color: Colors.white,
                                            size: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
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

  /// Custom 3 horizontal lines drag handle widget.
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
