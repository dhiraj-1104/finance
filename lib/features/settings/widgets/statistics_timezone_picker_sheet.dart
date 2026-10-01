import 'package:flutter/material.dart';
import 'package:ezbookkeeping/core/preferences/preferences_controller.dart';
import 'package:ezbookkeeping/features/settings/widgets/timezone_picker_sheet.dart';

/// Modal bottom sheet for choosing the timezone used for overview and statistics.
/// Matches media_1790770217007.png layout with circular action buttons and left checkmark indicators.
class StatisticsTimezonePickerSheet extends StatefulWidget {
  final String currentTimezone;
  final ValueChanged<String>? onTimezoneSelected;

  const StatisticsTimezonePickerSheet({
    super.key,
    required this.currentTimezone,
    this.onTimezoneSelected,
  });

  static Future<String?> show(
    BuildContext context, {
    required String currentTimezone,
    ValueChanged<String>? onTimezoneSelected,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatisticsTimezonePickerSheet(
        currentTimezone: currentTimezone,
        onTimezoneSelected: onTimezoneSelected,
      ),
    );
  }

  @override
  State<StatisticsTimezonePickerSheet> createState() =>
      _StatisticsTimezonePickerSheetState();
}

class _StatisticsTimezonePickerSheetState
    extends State<StatisticsTimezonePickerSheet> {
  static const Color _copperColor = Color(0xFFC86D3B);

  late final ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String get _appTimezoneOption =>
      PreferencesController.formattedApplicationTimezone;

  static const String _transactionTimezoneOption = 'Transaction Timezone';

  List<String> get _allOptions {
    final list = <String>[_appTimezoneOption, _transactionTimezoneOption];
    for (final tz in TimezonePickerSheet.defaultTimezones) {
      if (!list.contains(tz)) {
        list.add(tz);
      }
    }
    return list;
  }

  List<String> get _visibleOptions {
    if (_isSearching && _searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      return _allOptions
          .where((item) => item.toLowerCase().contains(query))
          .toList();
    } else if (_isSearching) {
      return _allOptions;
    } else {
      // Default view: Show primary choices + current selection if custom
      final list = <String>[_appTimezoneOption, _transactionTimezoneOption];
      if (widget.currentTimezone.isNotEmpty &&
          !list.contains(widget.currentTimezone) &&
          !widget.currentTimezone.startsWith('Application Timezone')) {
        list.add(widget.currentTimezone);
      }
      return list;
    }
  }

  bool _isOptionSelected(String option) {
    if (widget.currentTimezone == option) {
      return true;
    }
    if (option == _appTimezoneOption &&
        (widget.currentTimezone.startsWith('Application Timezone') ||
            widget.currentTimezone == 'Application Default' ||
            widget.currentTimezone.isEmpty)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final circleBtnBg = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final iconColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final hintColor = isDark ? Colors.white38 : const Color(0xFF8E8E93);

    final circleShadow = isDark
        ? null
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ];

    final sheetHeight = _isSearching
        ? MediaQuery.of(context).size.height * 0.88
        : MediaQuery.of(context).size.height * 0.55;

    final options = _visibleOptions;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top Header Bar matching media_1790770217007.png
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
                        onTap: () {
                          if (_isSearching) {
                            setState(() {
                              _isSearching = false;
                              _searchController.clear();
                            });
                          } else {
                            Navigator.pop(context);
                          }
                        },
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

                  // Center: Title or Search Field
                  Expanded(
                    child: _isSearching
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search timezone...',
                                hintStyle: TextStyle(
                                  color: hintColor,
                                  fontSize: 15,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.clear_rounded,
                                          size: 18,
                                        ),
                                        onPressed: () =>
                                            _searchController.clear(),
                                      )
                                    : null,
                              ),
                            ),
                          )
                        : Text(
                            'Timezone Used for Statistics',
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
                        onTap: () {
                          setState(() {
                            _isSearching = !_isSearching;
                            if (!_isSearching) {
                              _searchController.clear();
                            }
                          });
                        },
                        child: Center(
                          child: Icon(
                            _isSearching
                                ? Icons.search_off_rounded
                                : Icons.search_rounded,
                            color: _isSearching ? _copperColor : iconColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Options List
            Expanded(
              child: options.isEmpty
                  ? Center(
                      child: Text(
                        'No matching timezone',
                        style: TextStyle(
                          color: hintColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: options.length,
                      padding: const EdgeInsets.only(bottom: 24, top: 4),
                      itemBuilder: (context, index) {
                        final option = options[index];
                        final isSelected = _isOptionSelected(option);

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              widget.onTimezoneSelected?.call(option);
                              Navigator.pop(context, option);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 13,
                              ),
                              child: Row(
                                children: [
                                  // Left Checkmark indicator matching media_1790770217007.png
                                  SizedBox(
                                    width: 24,
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check_rounded,
                                            size: 19,
                                            color: _copperColor,
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                  const SizedBox(width: 8),

                                  // Option text
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 15,
                                        fontWeight: isSelected
                                            ? FontWeight.w500
                                            : FontWeight.w400,
                                        letterSpacing: -0.1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
