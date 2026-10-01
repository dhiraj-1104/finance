import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/core/utils/uuid_helper.dart';
import 'package:ezbookkeeping/features/accounts/widgets/account_color_picker_sheet.dart';
import 'package:ezbookkeeping/features/categories/data/models/add_category_request_model.dart';
import 'package:ezbookkeeping/features/categories/domain/usecases/add_transaction_category_use_case.dart';
import 'package:ezbookkeeping/features/categories/models/category_item.dart';
import 'package:ezbookkeeping/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:ezbookkeeping/features/categories/utils/category_icon_helper.dart';
import 'package:ezbookkeeping/features/categories/widgets/category_icon_picker_sheet.dart';

class AddCategoryScreen extends StatefulWidget {
  final bool isPrimary;
  final String? primaryCategoryName;
  final String? parentId;
  final String categoryType;
  final Color? initialColor;
  final IconData? initialIcon;
  final CategoriesBloc? bloc;
  final AddTransactionCategoryUseCase? addTransactionCategoryUseCase;

  const AddCategoryScreen({
    super.key,
    this.isPrimary = false,
    this.primaryCategoryName,
    this.parentId,
    this.categoryType = 'Expense',
    this.initialColor,
    this.initialIcon,
    this.bloc,
    this.addTransactionCategoryUseCase,
  });

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late IconData _selectedIcon;
  late String _selectedIconId;
  late Color _selectedColor;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();

    _selectedIcon = widget.initialIcon ?? Icons.restaurant_outlined;
    _selectedIconId = CategoryIconHelper.getIconId(_selectedIcon);
    _selectedColor =
        widget.initialColor ??
        (widget.isPrimary ? const Color(0xFF1C1C1E) : const Color(0xFFF97316));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _pickIcon() {
    CategoryIconPickerSheet.show(
      context,
      selectedIcon: _selectedIcon,
      selectedIconId: _selectedIconId,
      onIconSelected: (icon, iconId) {
        setState(() {
          _selectedIcon = icon;
          _selectedIconId = iconId;
        });
      },
    );
  }

  void _pickColor() {
    AccountColorPickerSheet.show(
      context,
      selectedColor: _selectedColor,
      onColorSelected: (color) {
        setState(() {
          _selectedColor = color;
        });
      },
    );
  }

  Future<void> _saveCategory() async {
    if (_isSubmitting) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category name cannot be empty'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final catTypeInt = widget.categoryType.toLowerCase() == 'income'
        ? 1
        : (widget.categoryType.toLowerCase() == 'transfer' ? 3 : 2);

    final parentId = widget.isPrimary ? '0' : (widget.parentId ?? '0');
    final iconString = _selectedIconId;
    final colorHex = CategoryIconHelper.colorToHex(_selectedColor);
    final comment = _descriptionController.text.trim();
    final clientSessionId = UuidHelper.generate();

    final request = AddCategoryRequestModel(
      name: name,
      type: catTypeInt,
      parentId: parentId,
      icon: iconString,
      iconType: 0,
      color: colorHex,
      comment: comment,
      clientSessionId: clientSessionId,
    );

    setState(() => _isSubmitting = true);

    final useCase =
        widget.addTransactionCategoryUseCase ??
        (getIt.isRegistered<AddTransactionCategoryUseCase>()
            ? getIt<AddTransactionCategoryUseCase>()
            : null);

    if (useCase != null) {
      final result = await useCase(request);
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: const Color(0xFFE75A4C),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        (newCategory) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Category "$name" saved'),
              behavior: SnackBarBehavior.floating,
            ),
          );

          final router = GoRouter.maybeOf(context);
          if (router != null && router.canPop()) {
            router.pop(newCategory);
          } else if (Navigator.canPop(context)) {
            Navigator.pop(context, newCategory);
          }
        },
      );
    } else {
      setState(() => _isSubmitting = false);

      final catType = catTypeInt == 1
          ? CategoryType.income
          : (catTypeInt == 3 ? CategoryType.transfer : CategoryType.expense);

      final fallbackCategory = CategoryItem(
        id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        categoryIconId: iconString,
        icon: _selectedIcon,
        color: _selectedColor,
        type: catType,
        isPrimary: widget.isPrimary,
        parentId: widget.isPrimary ? null : widget.primaryCategoryName,
        description: comment.isNotEmpty ? comment : null,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Category "$name" saved'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      final router = GoRouter.maybeOf(context);
      if (router != null && router.canPop()) {
        router.pop(fallbackCategory);
      } else if (Navigator.canPop(context)) {
        Navigator.pop(context, fallbackCategory);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark
        ? const Color(0xFF0F0F11)
        : const Color(0xFFEFF1F5);
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final labelColor = isDark ? Colors.white70 : const Color(0xFF333333);
    final hintColor = isDark ? Colors.white38 : const Color(0xFFB0B4BE);
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

    final titleText = widget.isPrimary
        ? 'Add Primary Category'
        : 'Add Secondary Category';

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

                      // Title
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

                      // Right Checkmark Button (✓)
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
                            onTap: _isSubmitting ? null : _saveCategory,
                            child: Center(
                              child: _isSubmitting
                                  ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              isDark
                                                  ? Colors.white70
                                                  : const Color(0xFF555555),
                                            ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.check_rounded,
                                      color: isDark
                                          ? Colors.white70
                                          : const Color(0xFF555555),
                                      size: 22,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Form Card
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: cardShadow,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Name
                          Text(
                            'Category Name',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: labelColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _nameController,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Your category name',
                              hintStyle: TextStyle(
                                color: hintColor,
                                fontSize: 15,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 6,
                              ),
                            ),
                          ),

                          Divider(
                            height: 24,
                            thickness: 0.8,
                            color: dividerColor,
                          ),

                          // Row with Category Icon and Category Color
                          Row(
                            children: [
                              // Category Icon
                              Expanded(
                                child: InkWell(
                                  onTap: _pickIcon,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Category Icon',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: labelColor,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Icon(
                                          _selectedIcon,
                                          color: _selectedColor,
                                          size: 28,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Category Color
                              Expanded(
                                child: InkWell(
                                  onTap: _pickColor,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Category Color',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: labelColor,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: _selectedColor,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Divider(
                            height: 24,
                            thickness: 0.8,
                            color: dividerColor,
                          ),

                          // Description
                          Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: labelColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _descriptionController,
                            maxLines: 3,
                            minLines: 1,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Your category description (optional)',
                              hintStyle: TextStyle(
                                color: hintColor,
                                fontSize: 15,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 6,
                              ),
                            ),
                          ),
                        ],
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
}
