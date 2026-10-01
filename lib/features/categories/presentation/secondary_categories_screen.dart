import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ezbookkeeping/app/router/app_routes.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/features/categories/domain/repositories/categories_repository.dart';
import 'package:ezbookkeeping/features/categories/models/category_item.dart';

class SecondaryCategoriesScreen extends StatefulWidget {
  final String primaryCategoryName;
  final String? parentId;
  final String categoryType;
  final CategoriesRepository? categoriesRepository;

  const SecondaryCategoriesScreen({
    super.key,
    this.primaryCategoryName = 'Food & Drink',
    this.parentId,
    this.categoryType = 'Expense',
    this.categoriesRepository,
  });

  @override
  State<SecondaryCategoriesScreen> createState() =>
      _SecondaryCategoriesScreenState();
}

class _SecondaryCategoriesScreenState extends State<SecondaryCategoriesScreen> {
  CategoryItem? _primaryCategory;
  List<CategoryItem> _categories = [];
  bool _isLoading = false;

  CategoryType get _parsedType {
    if (widget.categoryType.toLowerCase() == 'income') {
      return CategoryType.income;
    }
    if (widget.categoryType.toLowerCase() == 'transfer') {
      return CategoryType.transfer;
    }
    return CategoryType.expense;
  }

  CategoriesRepository? get _repo =>
      widget.categoriesRepository ??
      (getIt.isRegistered<CategoriesRepository>()
          ? getIt<CategoriesRepository>()
          : null);

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories({bool forceRefresh = false}) async {
    final repo = _repo;
    if (repo == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final all = await repo.getCategories(forceRefresh: forceRefresh);
      if (!mounted) return;
      final matching = all.firstWhere(
        (c) =>
            c.isPrimary &&
            c.type == _parsedType &&
            (widget.parentId != null && widget.parentId!.isNotEmpty
                ? c.id == widget.parentId
                : c.name.toLowerCase() ==
                      widget.primaryCategoryName.toLowerCase()),
        orElse: () => CategoryItem(
          id: widget.parentId ?? '',
          name: widget.primaryCategoryName,
          icon: Icons.category,
          color: Colors.grey,
        ),
      );

      setState(() {
        _primaryCategory = matching;
        _categories = List.of(matching.subCategories);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMoreOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : const Color(0xFFE2E4EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.sort_by_alpha_rounded, color: textColor),
                title: Text('Sort by Name', style: TextStyle(color: textColor)),
                onTap: () {
                  setState(() {
                    _categories.sort((a, b) => a.name.compareTo(b.name));
                  });
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: Icon(Icons.refresh_rounded, color: textColor),
                title: Text(
                  'Reset to Default',
                  style: TextStyle(color: textColor),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _loadCategories(forceRefresh: true);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark
        ? const Color(0xFF0F0F11)
        : const Color(0xFFEFF1F5);
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subtextColor = isDark
        ? const Color(0xFF8E8E93)
        : const Color(0xFF6B7280);
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

    final titleText = '${widget.categoryType} Secondary Categories';

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Row(
                    children: [
                      // Back Button (<)
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: cardBg,
                          shape: BoxShape.circle,
                          boxShadow: pillShadow,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              final router = GoRouter.maybeOf(context);
                              if (router != null && router.canPop()) {
                                router.pop();
                              } else if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                            },
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

                      // Title "Expense Secondary Categories"
                      Expanded(
                        child: Text(
                          titleText,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Right Pill Button with '...' and '+'
                      Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(21),
                          boxShadow: pillShadow,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(21),
                                ),
                                onTap: _showMoreOptions,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 14,
                                    right: 8,
                                    top: 8,
                                    bottom: 8,
                                  ),
                                  child: Icon(
                                    Icons.more_horiz_rounded,
                                    color: textColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                              InkWell(
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(21),
                                ),
                                onTap: () async {
                                  final newCategory = await context
                                      .push<CategoryItem>(
                                        AppRoutes.addCategory,
                                        extra: {
                                          'isPrimary': false,
                                          'primaryCategoryName':
                                              widget.primaryCategoryName,
                                          'parentId':
                                              _primaryCategory?.id ??
                                              widget.parentId ??
                                              '0',
                                          'categoryType': widget.categoryType,
                                        },
                                      );
                                  if (newCategory != null && mounted) {
                                    setState(() {
                                      final existingIndex = _categories
                                          .indexWhere(
                                            (c) => c.id == newCategory.id,
                                          );
                                      if (existingIndex >= 0) {
                                        _categories[existingIndex] =
                                            newCategory;
                                      } else {
                                        _categories.add(newCategory);
                                      }
                                    });
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                    right: 14,
                                    top: 8,
                                    bottom: 8,
                                  ),
                                  child: Icon(
                                    Icons.add_rounded,
                                    color: textColor,
                                    size: 22,
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
              ),
            ),

            // Secondary Categories Card or Loading
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_categories.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'No subcategories found',
                    style: TextStyle(
                      color: subtextColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            else
              Padding(
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
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: cardShadow,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (int i = 0; i < _categories.length; i++) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  // Icon
                                  Icon(
                                    _categories[i].icon,
                                    size: 22,
                                    color: _categories[i].color,
                                  ),
                                  const SizedBox(width: 14),

                                  // Name
                                  Expanded(
                                    child: Text(
                                      _categories[i].name,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (i < _categories.length - 1)
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                ),
                                height: 1,
                                color: dividerColor,
                              ),
                          ],
                        ],
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
