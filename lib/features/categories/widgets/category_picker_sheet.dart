import 'package:flutter/material.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/features/categories/domain/repositories/categories_repository.dart';
import 'package:ezbookkeeping/features/categories/models/category_item.dart';

/// Modal Category Picker Bottom Sheet matching the ezBookkeeping UI design.
class CategoryPickerSheet extends StatefulWidget {
  final CategoryType categoryType;
  final CategoriesRepository? categoriesRepository;
  final List<CategoryItem>? categories;
  final String? initialPrimaryCategory;
  final String? initialSubCategory;
  final ValueChanged<CategorySelection> onCategorySelected;

  const CategoryPickerSheet({
    super.key,
    this.categoryType = CategoryType.expense,
    this.categoriesRepository,
    this.categories,
    this.initialPrimaryCategory,
    this.initialSubCategory,
    required this.onCategorySelected,
  });

  /// Displays the [CategoryPickerSheet] modal bottom sheet.
  static Future<CategorySelection?> show(
    BuildContext context, {
    CategoryType categoryType = CategoryType.expense,
    CategoriesRepository? categoriesRepository,
    List<CategoryItem>? categories,
    String? initialPrimaryCategory,
    String? initialSubCategory,
    required ValueChanged<CategorySelection> onCategorySelected,
  }) {
    return showModalBottomSheet<CategorySelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CategoryPickerSheet(
        categoryType: categoryType,
        categoriesRepository: categoriesRepository,
        categories: categories,
        initialPrimaryCategory: initialPrimaryCategory,
        initialSubCategory: initialSubCategory,
        onCategorySelected: onCategorySelected,
      ),
    );
  }

  @override
  State<CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<CategoryPickerSheet> {
  late final TextEditingController _searchController;
  late final Set<String> _expandedPrimaryCategoryNames;
  List<CategoryItem> _allCategories = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _expandedPrimaryCategoryNames = <String>{};

    if (widget.categories != null) {
      _allCategories = widget.categories!;
      _initExpandedState();
    } else {
      _loadCategoriesFromApi();
    }
  }

  void _initExpandedState() {
    if (widget.initialPrimaryCategory != null &&
        widget.initialPrimaryCategory!.isNotEmpty) {
      _expandedPrimaryCategoryNames.add(widget.initialPrimaryCategory!);
    } else if (_allCategories.isNotEmpty) {
      _expandedPrimaryCategoryNames.add(_allCategories.first.name);
    }
  }

  void _loadCategoriesFromApi() {
    final repo =
        widget.categoriesRepository ??
        (getIt.isRegistered<CategoriesRepository>()
            ? getIt<CategoriesRepository>()
            : null);

    if (repo != null) {
      setState(() {
        _isLoading = true;
      });

      repo
          .getCategories()
          .then((apiCategories) {
            if (!mounted) return;
            final matching = apiCategories
                .where((c) => c.isPrimary && c.type == widget.categoryType)
                .toList();
            setState(() {
              _allCategories = matching;
              _isLoading = false;
              _initExpandedState();
            });
          })
          .catchError((_) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
            });
          });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleCategoryExpansion(String categoryName) {
    setState(() {
      if (_expandedPrimaryCategoryNames.contains(categoryName)) {
        _expandedPrimaryCategoryNames.remove(categoryName);
      } else {
        _expandedPrimaryCategoryNames.add(categoryName);
      }
    });
  }

  void _selectCategory(CategoryItem primary, [CategoryItem? subCategory]) {
    final selection = CategorySelection(
      primary: primary,
      subCategory: subCategory,
    );
    widget.onCategorySelected(selection);
    Navigator.of(context).pop(selection);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final sheetBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final searchBg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6);
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subtextColor = isDark
        ? const Color(0xFF9E9EA4)
        : const Color(0xFF6B7280);
    final circleBtnBg = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final selectedHighlightBg = isDark
        ? const Color(0xFF3D2F24)
        : const Color(0xFFF8EBE3);

    final shadow = isDark
        ? null
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ];

    // Filter categories based on search query
    final query = _searchQuery.trim().toLowerCase();
    final List<CategoryItem> displayedCategories;

    if (query.isEmpty) {
      displayedCategories = _allCategories;
    } else {
      displayedCategories = _allCategories
          .map((primary) {
            final primaryMatches = primary.name.toLowerCase().contains(query);
            final matchingSubs = primary.subCategories
                .where((sub) => sub.name.toLowerCase().contains(query))
                .toList();

            if (primaryMatches || matchingSubs.isNotEmpty) {
              return CategoryItem(
                id: primary.id,
                name: primary.name,
                categoryIconId: primary.categoryIconId,
                icon: primary.icon,
                color: primary.color,
                type: primary.type,
                isPrimary: true,
                parentId: primary.parentId,
                description: primary.description,
                subCategories: matchingSubs.isNotEmpty
                    ? matchingSubs
                    : primary.subCategories,
              );
            }
            return null;
          })
          .whereType<CategoryItem>()
          .toList();
    }

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),

            // Top Drag Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : const Color(0xFFB0B3BC),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Top Header: Circular Close Button + Pill Search Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Circular Close Button (✕)
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
                        onTap: () => Navigator.of(context).pop(),
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

                  // Pill Search Input: "🔍 Find category"
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: searchBg,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: subtextColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(
                                fontSize: 14,
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Find category',
                                hintStyle: TextStyle(
                                  color: subtextColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val;
                                });
                              },
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                              child: Icon(
                                Icons.cancel_rounded,
                                color: subtextColor,
                                size: 18,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Loading or Category Tree List
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Flexible(
                child: displayedCategories.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 40,
                                color: subtextColor.withValues(alpha: 0.6),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'No matching categories found'
                                    : 'No categories available',
                                style: TextStyle(
                                  color: subtextColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        itemCount: displayedCategories.length,
                        itemBuilder: (context, index) {
                          final primary = displayedCategories[index];
                          final hasSubCategories =
                              primary.subCategories.isNotEmpty;
                          final isExpanded =
                              query.isNotEmpty ||
                              _expandedPrimaryCategoryNames.contains(
                                primary.name,
                              );

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Primary Category Row
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    if (hasSubCategories) {
                                      _toggleCategoryExpansion(primary.name);
                                    } else {
                                      _selectCategory(primary);
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      children: [
                                        // Expand/Collapse Chevron Indicator (▼ / ▶)
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: hasSubCategories
                                              ? Icon(
                                                  isExpanded
                                                      ? Icons
                                                            .arrow_drop_down_rounded
                                                      : Icons
                                                            .arrow_right_rounded,
                                                  color: subtextColor,
                                                  size: 22,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 4),

                                        // Primary Category Icon
                                        Icon(
                                          primary.icon,
                                          size: 22,
                                          color: primary.color,
                                        ),
                                        const SizedBox(width: 12),

                                        // Primary Category Name
                                        Expanded(
                                          child: Text(
                                            primary.name,
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Subcategories list (when expanded)
                              if (hasSubCategories && isExpanded)
                                Padding(
                                  padding: const EdgeInsets.only(left: 28),
                                  child: Column(
                                    children: primary.subCategories.map((sub) {
                                      final isSelected =
                                          widget.initialPrimaryCategory ==
                                              primary.name &&
                                          widget.initialSubCategory == sub.name;

                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 1.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? selectedHighlightBg
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            onTap: () =>
                                                _selectCategory(primary, sub),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 10,
                                                  ),
                                              child: Row(
                                                children: [
                                                  // Subcategory Icon
                                                  Icon(
                                                    sub.icon,
                                                    size: 20,
                                                    color: sub.color,
                                                  ),
                                                  const SizedBox(width: 12),

                                                  // Subcategory Name
                                                  Expanded(
                                                    child: Text(
                                                      sub.name,
                                                      style: TextStyle(
                                                        color: textColor,
                                                        fontSize: 14,
                                                        fontWeight: isSelected
                                                            ? FontWeight.w700
                                                            : FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),

                                                  if (isSelected)
                                                    Icon(
                                                      Icons.check_rounded,
                                                      color: theme
                                                          .colorScheme
                                                          .primary,
                                                      size: 18,
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                            ],
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
