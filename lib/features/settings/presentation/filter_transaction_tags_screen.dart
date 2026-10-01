import 'package:flutter/material.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/features/tags/domain/usecases/get_transaction_tags_use_case.dart';
import 'package:ezbookkeeping/features/tags/models/tag_item.dart';

/// Screen allowing users to select which transaction tags are included/excluded in Overview Statistics.
/// Matches media_1790832919061.png and media_1790832934076.png UI design with collapsible tag group cards,
/// tag filter state selector ('Default', 'Included', 'Excluded'), and action sheet modal.
class FilterTransactionTagsScreen extends StatefulWidget {
  final List<TagItem>? initialTags;

  const FilterTransactionTagsScreen({
    super.key,
    this.initialTags,
  });

  @override
  State<FilterTransactionTagsScreen> createState() =>
      _FilterTransactionTagsScreenState();
}

class _FilterTransactionTagsScreenState
    extends State<FilterTransactionTagsScreen> {
  static const Color _copperAccent = Color(0xFFC86D3B);

  PreferencesController? _preferencesController;
  final TextEditingController _searchController = TextEditingController();
  final Map<String, String> _tagFilterStates = <String, String>{};
  final Set<String> _collapsedGroups = <String>{};

  List<TagItem> _tags = const [];
  bool _isLoading = false;
  bool _showHiddenTags = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (getIt.isRegistered<PreferencesController>()) {
      _preferencesController = getIt<PreferencesController>();
      final savedFilters = _preferencesController!.overviewTagFilter;
      if (savedFilters.isNotEmpty) {
        _tagFilterStates.addAll(savedFilters);
      }
    }

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });

    if (widget.initialTags != null && widget.initialTags!.isNotEmpty) {
      _tags = widget.initialTags!;
      _initDefaultFiltersIfEmpty();
    } else {
      _loadTags();
    }
  }

  void _initDefaultFiltersIfEmpty() {
    for (final tag in _tags) {
      _tagFilterStates.putIfAbsent(tag.id, () => 'Default');
    }
  }

  Future<void> _loadTags() async {
    setState(() => _isLoading = true);

    if (getIt.isRegistered<GetTransactionTagsUseCase>()) {
      try {
        final tags = await getIt<GetTransactionTagsUseCase>().call();
        if (mounted) {
          setState(() {
            _tags = tags;
            _isLoading = false;
            _initDefaultFiltersIfEmpty();
          });
        }
      } catch (_) {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TagItem> get _visibleTags {
    return _tags.where((tag) {
      if (!_showHiddenTags && tag.hidden) return false;
      return true;
    }).toList();
  }

  void _setAllStates(String state) {
    setState(() {
      for (final tag in _visibleTags) {
        _tagFilterStates[tag.id] = state;
      }
    });
  }

  void _saveAndPop() {
    final visible = _visibleTags;
    String mode = 'Selected Tags';

    final allDefault = visible.every(
      (t) => (_tagFilterStates[t.id] ?? 'Default') == 'Default',
    );
    final allExcluded = visible.isNotEmpty &&
        visible.every(
          (t) => (_tagFilterStates[t.id] ?? 'Default') == 'Excluded',
        );

    if (allDefault) {
      mode = 'All';
    } else if (allExcluded) {
      mode = 'None';
    }

    _preferencesController?.setOverviewTagFilter(
      _tagFilterStates,
      mode: mode,
    );

    Navigator.of(context).pop(_tagFilterStates);
  }

  void _showTagStatePicker(TagItem tag) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    final currentState = _tagFilterStates[tag.id] ?? 'Default';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Container(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      child: Row(
                        children: [
                          Text(
                            '# ${tag.name}',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: dividerColor),
                    for (final state in const ['Default', 'Included', 'Excluded']) ...[
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _tagFilterStates[tag.id] = state;
                            });
                            Navigator.pop(sheetContext);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    state,
                                    style: TextStyle(
                                      color: state == currentState
                                          ? _copperAccent
                                          : textColor,
                                      fontSize: 16,
                                      fontWeight: state == currentState
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                                if (state == currentState)
                                  const Icon(
                                    Icons.check_rounded,
                                    color: _copperAccent,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (state != 'Excluded')
                        Divider(
                          height: 1,
                          indent: 20,
                          endIndent: 20,
                          color: dividerColor,
                        ),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showOptionsMenu() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Action Card 1: Set All to Included / Set All to Default / Set All to Excluded
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionSheetButton(
                          title: 'Set All to Included',
                          onTap: () {
                            Navigator.pop(sheetContext);
                            _setAllStates('Included');
                          },
                        ),
                        Divider(height: 1, thickness: 1, color: dividerColor),
                        _buildActionSheetButton(
                          title: 'Set All to Default',
                          onTap: () {
                            Navigator.pop(sheetContext);
                            _setAllStates('Default');
                          },
                        ),
                        Divider(height: 1, thickness: 1, color: dividerColor),
                        _buildActionSheetButton(
                          title: 'Set All to Excluded',
                          onTap: () {
                            Navigator.pop(sheetContext);
                            _setAllStates('Excluded');
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Action Card 2: Show/Hide Hidden Transaction Tags
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildActionSheetButton(
                      title: _showHiddenTags
                          ? 'Hide Hidden Transaction Tags'
                          : 'Show Hidden Transaction Tags',
                      onTap: () {
                        Navigator.pop(sheetContext);
                        setState(() {
                          _showHiddenTags = !_showHiddenTags;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Action Card 3: Cancel Button
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildActionSheetButton(
                      title: 'Cancel',
                      onTap: () => Navigator.pop(sheetContext),
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

  Widget _buildActionSheetButton({
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 52,
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                color: _copperAccent,
                fontSize: 16.5,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, List<TagItem>> _getGroupedTags() {
    final query = _searchQuery.toLowerCase();
    final groups = <String, List<TagItem>>{};

    for (final tag in _visibleTags) {
      if (query.isNotEmpty && !tag.name.toLowerCase().contains(query)) {
        continue;
      }
      final groupTitle = 'Default Group';
      if (!groups.containsKey(groupTitle)) {
        groups[groupTitle] = [];
      }
      groups[groupTitle]!.add(tag);
    }

    groups.removeWhere((_, list) => list.isEmpty);
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark
        ? const Color(0xFF0F0F11)
        : const Color(0xFFEFF1F5);
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final circleBtnBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subtextColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF8E8E93);
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

    final grouped = _getGroupedTags();

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar matching media_1790832919061.png
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Row(
                    children: [
                      // Back button (<)
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: circleBtnBg,
                          shape: BoxShape.circle,
                          boxShadow: pillShadow,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
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

                      const SizedBox(width: 8),

                      // Centered Title
                      Expanded(
                        child: Text(
                          'Filter Transaction Tags',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Combined Action Pill: [ ••• | ✓ ]
                      Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: circleBtnBg,
                          borderRadius: BorderRadius.circular(21),
                          boxShadow: pillShadow,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 3-dots Menu Button
                            IconButton(
                              icon: Icon(
                                Icons.more_horiz_rounded,
                                color: textColor,
                                size: 22,
                              ),
                              onPressed: _showOptionsMenu,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              constraints: const BoxConstraints(),
                            ),

                            // Divider
                            Container(
                              width: 1,
                              height: 18,
                              color: dividerColor,
                            ),

                            // Checkmark Button (✓)
                            IconButton(
                              icon: const Icon(
                                Icons.check_rounded,
                                color: _copperAccent,
                                size: 22,
                              ),
                              onPressed: _saveAndPop,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Search Bar Pill
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(23),
                      boxShadow: pillShadow,
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: textColor, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Find tag',
                        hintStyle: TextStyle(
                          color: subtextColor,
                          fontSize: 15,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: subtextColor,
                          size: 20,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.cancel_rounded,
                                  color: subtextColor,
                                  size: 18,
                                ),
                                onPressed: () => _searchController.clear(),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Tag List grouped by Group Cards
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: _copperAccent,
                      ),
                    )
                  : grouped.isEmpty
                      ? Center(
                          child: Text(
                            'No tags found',
                            style: TextStyle(
                              color: subtextColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 450),
                              child: Column(
                                children: grouped.entries.map((entry) {
                                  final groupTitle = entry.key;
                                  final tagList = entry.value;
                                  final isCollapsed = _collapsedGroups
                                      .contains(groupTitle);

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: cardShadow,
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // Tag Group Header Row
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              if (isCollapsed) {
                                                _collapsedGroups
                                                    .remove(groupTitle);
                                              } else {
                                                _collapsedGroups
                                                    .add(groupTitle);
                                              }
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              16,
                                              14,
                                              16,
                                              12,
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    groupTitle,
                                                    style: TextStyle(
                                                      color: subtextColor,
                                                      fontSize: 13.5,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                Icon(
                                                  isCollapsed
                                                      ? Icons
                                                          .keyboard_arrow_down_rounded
                                                      : Icons
                                                          .keyboard_arrow_up_rounded,
                                                  color: subtextColor,
                                                  size: 20,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // Tag Items List
                                        if (!isCollapsed)
                                          ListView.separated(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: tagList.length,
                                            separatorBuilder:
                                                (context, index) => Container(
                                                  margin: const EdgeInsets
                                                      .only(left: 44),
                                                  height: 1,
                                                  color: dividerColor,
                                                ),
                                            itemBuilder: (context, index) {
                                              final tag = tagList[index];
                                              final state =
                                                  _tagFilterStates[tag.id] ??
                                                      'Default';

                                              return Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: () =>
                                                      _showTagStatePicker(tag),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                          horizontal: 16,
                                                          vertical: 14,
                                                        ),
                                                    child: Row(
                                                      children: [
                                                        // Tag Icon '#'
                                                        Text(
                                                          '#',
                                                          style: TextStyle(
                                                            color: textColor,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),

                                                        const SizedBox(
                                                          width: 14,
                                                        ),

                                                        // Tag Name
                                                        Expanded(
                                                          child: Text(
                                                            tag.name,
                                                            style: TextStyle(
                                                              color: textColor,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              letterSpacing:
                                                                  -0.1,
                                                            ),
                                                          ),
                                                        ),

                                                        // Trailing Filter State Selector
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              state,
                                                              style: TextStyle(
                                                                color:
                                                                    subtextColor,
                                                                fontSize: 14.5,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Icon(
                                                              Icons
                                                                  .unfold_more_rounded,
                                                              color:
                                                                  subtextColor,
                                                              size: 18,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList(),
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
}
