import 'package:flutter/material.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/features/categories/domain/usecases/get_transaction_categories_use_case.dart';
import 'package:ezbookkeeping/features/categories/models/category_item.dart';

/// Screen allowing users to select which transaction categories are included in Overview Statistics.
/// Matches media_1790832240089.png and media_1790832256968.png UI design with collapsible category cards,
/// indented subcategories, hidden categories toggle, and bottom sheet action menu.
class FilterTransactionCategoriesScreen extends StatefulWidget {
  final List<CategoryItem>? initialCategories;

  const FilterTransactionCategoriesScreen({
    super.key,
    this.initialCategories,
  });

  @override
  State<FilterTransactionCategoriesScreen> createState() =>
      _FilterTransactionCategoriesScreenState();
}

class _FilterTransactionCategoriesScreenState
    extends State<FilterTransactionCategoriesScreen> {
  static const Color _copperAccent = Color(0xFFC86D3B);

  PreferencesController? _preferencesController;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedCategoryIds = <String>{};
  final Set<String> _collapsedGroups = <String>{};

  List<CategoryItem> _categories = const [];
  bool _isLoading = false;
  bool _showHiddenCategories = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (getIt.isRegistered<PreferencesController>()) {
      _preferencesController = getIt<PreferencesController>();
      final savedIds = _preferencesController!.overviewCategoryIds;
      if (savedIds.isNotEmpty) {
        _selectedCategoryIds.addAll(savedIds);
      }
    }

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });

    if (widget.initialCategories != null &&
        widget.initialCategories!.isNotEmpty) {
      _categories = widget.initialCategories!;
      _initDefaultSelectionIfEmpty();
    } else {
      _loadCategories();
    }
  }

  void _initDefaultSelectionIfEmpty() {
    if (_preferencesController?.categoriesInOverview == 'All' ||
        _selectedCategoryIds.isEmpty) {
      for (final cat in _allFlattenedCategories) {
        _selectedCategoryIds.add(cat.id);
      }
    }
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);

    if (getIt.isRegistered<GetTransactionCategoriesUseCase>()) {
      try {
        final categories =
            await getIt<GetTransactionCategoriesUseCase>().call();
        if (mounted) {
          setState(() {
            _categories = categories;
            _isLoading = false;
            _initDefaultSelectionIfEmpty();
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

  List<CategoryItem> get _allFlattenedCategories {
    final list = <CategoryItem>[];
    for (final cat in _categories) {
      if (!_showHiddenCategories && cat.hidden) continue;
      list.add(cat);
      for (final sub in cat.subCategories) {
        if (!_showHiddenCategories && sub.hidden) continue;
        list.add(sub);
      }
    }
    return list;
  }

  void _selectAll() {
    setState(() {
      for (final cat in _allFlattenedCategories) {
        _selectedCategoryIds.add(cat.id);
      }
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedCategoryIds.clear();
    });
  }

  void _invertSelection() {
    setState(() {
      final all = _allFlattenedCategories;
      for (final cat in all) {
        if (_selectedCategoryIds.contains(cat.id)) {
          _selectedCategoryIds.remove(cat.id);
        } else {
          _selectedCategoryIds.add(cat.id);
        }
      }
    });
  }

  void _togglePrimaryCategory(CategoryItem primary) {
    setState(() {
      final ids = <String>[primary.id];
      for (final sub in primary.subCategories) {
        if (_showHiddenCategories || !sub.hidden) {
          ids.add(sub.id);
        }
      }

      final allSelected = ids.every(_selectedCategoryIds.contains);
      if (allSelected) {
        _selectedCategoryIds.removeAll(ids);
      } else {
        _selectedCategoryIds.addAll(ids);
      }
    });
  }

  void _toggleSubCategory(CategoryItem sub, CategoryItem parent) {
    setState(() {
      if (_selectedCategoryIds.contains(sub.id)) {
        _selectedCategoryIds.remove(sub.id);
      } else {
        _selectedCategoryIds.add(sub.id);
        // Also ensure parent is selected if any subcategory is selected
        _selectedCategoryIds.add(parent.id);
      }
    });
  }

  void _saveAndPop() {
    final all = _allFlattenedCategories;
    String mode = 'Selected Categories';

    if (_selectedCategoryIds.isEmpty) {
      mode = 'None';
    } else if (all.isNotEmpty && _selectedCategoryIds.length >= all.length) {
      mode = 'All';
    }

    _preferencesController?.setOverviewCategoryIds(
      _selectedCategoryIds.toList(),
      mode: mode,
    );

    Navigator.of(context).pop(_selectedCategoryIds.toList());
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
                  // Action Card 1: Select All / Select None / Invert Selection
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
                          title: 'Select All',
                          onTap: () {
                            Navigator.pop(sheetContext);
                            _selectAll();
                          },
                        ),
                        Divider(height: 1, thickness: 1, color: dividerColor),
                        _buildActionSheetButton(
                          title: 'Select None',
                          onTap: () {
                            Navigator.pop(sheetContext);
                            _deselectAll();
                          },
                        ),
                        Divider(height: 1, thickness: 1, color: dividerColor),
                        _buildActionSheetButton(
                          title: 'Invert Selection',
                          onTap: () {
                            Navigator.pop(sheetContext);
                            _invertSelection();
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Action Card 2: Show/Hide Hidden Categories
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildActionSheetButton(
                      title: _showHiddenCategories
                          ? 'Hide Hidden Transaction Categories'
                          : 'Show Hidden Transaction Categories',
                      onTap: () {
                        Navigator.pop(sheetContext);
                        setState(() {
                          _showHiddenCategories = !_showHiddenCategories;
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

  String _getCategoryGroupTitle(CategoryType type) {
    switch (type) {
      case CategoryType.expense:
        return 'Expense Categories';
      case CategoryType.income:
        return 'Income Categories';
      case CategoryType.transfer:
        return 'Transfer Categories';
    }
  }

  Map<String, List<CategoryItem>> _getGroupedPrimaryCategories() {
    final query = _searchQuery.toLowerCase();
    final groups = <String, List<CategoryItem>>{
      'Expense Categories': [],
      'Income Categories': [],
      'Transfer Categories': [],
    };

    for (final cat in _categories) {
      if (!_showHiddenCategories && cat.hidden) continue;

      final groupTitle = _getCategoryGroupTitle(cat.type);
      if (!groups.containsKey(groupTitle)) {
        groups[groupTitle] = [];
      }

      if (query.isEmpty) {
        groups[groupTitle]!.add(cat);
      } else {
        final matchesPrimary = cat.name.toLowerCase().contains(query);
        final matchingSubs = cat.subCategories.where((sub) {
          if (!_showHiddenCategories && sub.hidden) return false;
          return sub.name.toLowerCase().contains(query);
        }).toList();

        if (matchesPrimary || matchingSubs.isNotEmpty) {
          if (matchesPrimary) {
            groups[groupTitle]!.add(cat);
          } else {
            groups[groupTitle]!.add(cat.copyWith(subCategories: matchingSubs));
          }
        }
      }
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

    final grouped = _getGroupedPrimaryCategories();

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar matching media_1790832240089.png
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
                          'Filter Transaction Categories',
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
                        hintText: 'Find category',
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

            // Category List grouped by Type Cards
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
                            'No categories found',
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
                                  final primaryCategories = entry.value;
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
                                        // Category Group Header Row
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

                                        // Primary and Subcategory items
                                        if (!isCollapsed)
                                          _buildCategoryItemsList(
                                            primaryCategories:
                                                primaryCategories,
                                            textColor: textColor,
                                            subtextColor: subtextColor,
                                            dividerColor: dividerColor,
                                            isDark: isDark,
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

  Widget _buildCategoryItemsList({
    required List<CategoryItem> primaryCategories,
    required Color textColor,
    required Color subtextColor,
    required Color dividerColor,
    required bool isDark,
  }) {
    final List<Widget> items = [];

    for (int pIdx = 0; pIdx < primaryCategories.length; pIdx++) {
      final primary = primaryCategories[pIdx];
      final visibleSubs = primary.subCategories.where((s) {
        if (!_showHiddenCategories && s.hidden) return false;
        return true;
      }).toList();

      final isPrimarySelected = _selectedCategoryIds.contains(primary.id);

      // Primary Category Row
      items.add(
        _buildCategoryRow(
          category: primary,
          isSelected: isPrimarySelected,
          isSubcategory: false,
          textColor: textColor,
          isDark: isDark,
          onTap: () => _togglePrimaryCategory(primary),
        ),
      );

      // Subcategories Rows (indented matching media_1790832240089.png)
      for (final sub in visibleSubs) {
        final isSubSelected = _selectedCategoryIds.contains(sub.id);
        items.add(
          _buildCategoryRow(
            category: sub,
            isSelected: isSubSelected,
            isSubcategory: true,
            textColor: textColor,
            isDark: isDark,
            onTap: () => _toggleSubCategory(sub, primary),
          ),
        );
      }
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(left: 54),
        height: 1,
        color: dividerColor,
      ),
      itemBuilder: (context, index) => items[index],
    );
  }

  Widget _buildCategoryRow({
    required CategoryItem category,
    required bool isSelected,
    required bool isSubcategory,
    required Color textColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.only(
            left: isSubcategory ? 34 : 16,
            right: 16,
            top: 13,
            bottom: 13,
          ),
          child: Row(
            children: [
              // Selection Checkbox Circle
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? _copperAccent : Colors.transparent,
                  border: isSelected
                      ? null
                      : Border.all(
                          color: isDark ? Colors.white24 : const Color(0xFFC7C7CC),
                          width: 1.5,
                        ),
                ),
                child: isSelected
                    ? const Center(
                        child: Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                      )
                    : null,
              ),

              const SizedBox(width: 12),

              // Category Icon
              Icon(
                category.icon,
                size: 22,
                color: category.color,
              ),

              const SizedBox(width: 12),

              // Category Name
              Expanded(
                child: Text(
                  category.name,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
