import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/features/accounts/domain/entities/account.dart';
import 'package:ezbookkeeping/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:ezbookkeeping/features/accounts/widgets/account_picker_sheet.dart';
import 'package:ezbookkeeping/features/categories/domain/repositories/categories_repository.dart';
import 'package:ezbookkeeping/features/categories/models/category_item.dart';
import 'package:ezbookkeeping/features/categories/widgets/category_picker_sheet.dart';
import 'package:ezbookkeeping/features/home/widgets/amount_keypad_sheet.dart';
import 'package:ezbookkeeping/features/home/widgets/geographic_location_action_sheet.dart';
import 'package:ezbookkeeping/features/home/widgets/transaction_form_card.dart';
import 'package:ezbookkeeping/features/home/widgets/transaction_header.dart';
import 'package:ezbookkeeping/features/home/widgets/transaction_save_button.dart';
import 'package:ezbookkeeping/features/home/widgets/transaction_type_selector.dart';
import 'package:ezbookkeeping/features/settings/widgets/timezone_picker_sheet.dart';
import 'package:ezbookkeeping/features/tags/domain/repositories/tags_repository.dart';
import 'package:ezbookkeeping/features/tags/models/tag_item.dart';
import 'package:ezbookkeeping/features/transactions/data/models/add_transaction_request_model.dart';
import 'package:ezbookkeeping/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:ezbookkeeping/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:ezbookkeeping/features/transactions/presentation/bloc/transaction_state.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionBloc? bloc;
  final CategoriesRepository? categoriesRepository;
  final AccountsRepository? accountsRepository;
  final TagsRepository? tagsRepository;
  final dynamic transactionToEdit;
  final String? pageTitle;

  const AddTransactionScreen({
    super.key,
    this.bloc,
    this.categoriesRepository,
    this.accountsRepository,
    this.tagsRepository,
    this.transactionToEdit,
    this.pageTitle,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  late final TransactionBloc? _bloc;
  StreamSubscription<TransactionState>? _blocSubscription;
  late final CategoriesRepository? _categoriesRepository;
  late final AccountsRepository? _accountsRepository;
  late final TagsRepository? _tagsRepository;
  PreferencesController? _preferencesController;

  TransactionType _selectedType = TransactionType.expense;
  double _amount = 0.00;
  String _categoryParent = 'Food & Drink';
  String _categoryChild = 'Food';
  String _selectedCategoryId = '';
  String _account = 'Wallet (US Dollar)';
  String _selectedAccountId = '';
  String? _selectedDestinationAccountId;
  late DateTime _transactionDateTime;
  String _timezone = '(UTC+05:30) System Default';
  String _location = 'No Location';
  String _tag = 'None';
  String _selectedTagId = '';
  List<TagItem> _availableTags = [];
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _transactionDateTime = DateTime.now();

    if (widget.bloc != null) {
      _bloc = widget.bloc;
    } else if (getIt.isRegistered<TransactionBloc>()) {
      _bloc = getIt<TransactionBloc>();
    } else {
      _bloc = null;
    }

    _categoriesRepository =
        widget.categoriesRepository ??
        (getIt.isRegistered<CategoriesRepository>()
            ? getIt<CategoriesRepository>()
            : null);

    _accountsRepository =
        widget.accountsRepository ??
        (getIt.isRegistered<AccountsRepository>()
            ? getIt<AccountsRepository>()
            : null);

    _tagsRepository =
        widget.tagsRepository ??
        (getIt.isRegistered<TagsRepository>() ? getIt<TagsRepository>() : null);

    final bloc = _bloc;
    if (bloc != null) {
      _blocSubscription = bloc.stream.listen((state) {
        if (!mounted) return;
        if (state is TransactionCreating) {
          setState(() => _isSubmitting = true);
        } else if (state is TransactionCreateSuccess) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Transaction saved (\$ ${_amount.toStringAsFixed(2)})',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: const Color(0xFF1E293B),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
          context.pop(state.transaction);
        } else if (state is TransactionError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFFE75A4C),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      });
    }

    if (getIt.isRegistered<PreferencesController>()) {
      _preferencesController = getIt<PreferencesController>();
      _preferencesController?.addListener(_onPreferencesChanged);
    }

    _preloadCategories();
    _preloadAccounts();
    _preloadTags();
  }

  void _preloadTags() {
    final repo = _tagsRepository;
    if (repo != null) {
      repo
          .getTags()
          .then((tags) {
            if (!mounted) return;
            setState(() {
              _availableTags = tags;
            });
          })
          .catchError((_) {});
    }
  }

  List<CategoryItem> _fetchedCategories = [];

  void _preloadCategories() {
    final repo = _categoriesRepository;
    if (repo != null) {
      repo
          .getCategories()
          .then((categories) {
            if (!mounted) return;
            _fetchedCategories = categories;
            final currentType = _selectedType == TransactionType.income
                ? CategoryType.income
                : (_selectedType == TransactionType.transfer
                      ? CategoryType.transfer
                      : CategoryType.expense);
            final matching = categories
                .where((c) => c.isPrimary && c.type == currentType)
                .toList();
            if (matching.isNotEmpty) {
              final chosen = matching.firstWhere(
                (c) => c.name.toLowerCase() == _categoryParent.toLowerCase(),
                orElse: () => matching.first,
              );
              setState(() {
                _categoryParent = chosen.name;
                if (chosen.subCategories.isNotEmpty) {
                  final matchedSub = chosen.subCategories.firstWhere(
                    (s) => s.name.toLowerCase() == _categoryChild.toLowerCase(),
                    orElse: () => chosen.subCategories.first,
                  );
                  _categoryChild = matchedSub.name;
                  _selectedCategoryId = matchedSub.id;
                } else {
                  _categoryChild = chosen.name;
                  _selectedCategoryId = chosen.id;
                }
              });
            }
          })
          .catchError((_) {});
    }
  }

  List<Account> _getLeafAccounts(List<Account> accounts) {
    final leafAccounts = <Account>[];
    for (final a in accounts) {
      if (a.subAccounts.isEmpty && !a.isParentAccount) {
        leafAccounts.add(a);
      } else {
        for (final sub in a.subAccounts) {
          if (sub.subAccounts.isEmpty && !sub.isParentAccount) {
            leafAccounts.add(sub);
          } else {
            leafAccounts.addAll(_getLeafAccounts(sub.subAccounts));
          }
        }
      }
    }
    return leafAccounts;
  }

  void _preloadAccounts() {
    final repo = _accountsRepository;
    if (repo != null) {
      repo
          .getAccounts()
          .then((accounts) {
            if (!mounted) return;
            if (accounts.isRight()) {
              final accList = accounts.getOrElse(() => []);
              if (accList.isNotEmpty) {
                final leafAccounts = _getLeafAccounts(accList);
                if (leafAccounts.isNotEmpty) {
                  final matched = leafAccounts.firstWhere(
                    (a) => a.name.toLowerCase() == _account.toLowerCase(),
                    orElse: () => leafAccounts.first,
                  );
                  setState(() {
                    _account = matched.name;
                    _selectedAccountId = matched.id;
                  });
                }
              }
            }
          })
          .catchError((_) {});
    }
  }

  @override
  void dispose() {
    _preferencesController?.removeListener(_onPreferencesChanged);
    _blocSubscription?.cancel();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onPreferencesChanged() {
    if (mounted) setState(() {});
  }

  String get _formattedDateTime {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final month = months[_transactionDateTime.month - 1];
    final day = _transactionDateTime.day;
    final year = _transactionDateTime.year;
    final hour = _transactionDateTime.hour;
    final minute = _transactionDateTime.minute.toString().padLeft(2, '0');
    final second = _transactionDateTime.second.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = (hour % 12 == 0 ? 12 : hour % 12).toString().padLeft(
      2,
      '0',
    );
    return '$month $day, $year $formattedHour:$minute:$second $period';
  }

  Future<String> _resolveCategoryId() async {
    if (_selectedType == TransactionType.transfer) {
      return '0';
    }

    final repo = _categoriesRepository;
    List<CategoryItem> categories = _fetchedCategories;
    if (repo != null && categories.isEmpty) {
      try {
        categories = await repo.getCategories();
        _fetchedCategories = categories;
      } catch (_) {}
    }

    final currentType = _selectedType == TransactionType.income
        ? CategoryType.income
        : CategoryType.expense;

    final matchingPrimaries = categories
        .where((c) => c.isPrimary && c.type == currentType)
        .toList();

    // 1. If _selectedCategoryId is already set to a valid remote snowflake ID
    if (_selectedCategoryId.isNotEmpty && _selectedCategoryId != '0') {
      for (final parent in matchingPrimaries) {
        if (parent.id == _selectedCategoryId) return parent.id;
        for (final sub in parent.subCategories) {
          if (sub.id == _selectedCategoryId) return sub.id;
        }
      }
      for (final cat in categories) {
        if (cat.id == _selectedCategoryId) return cat.id;
        for (final sub in cat.subCategories) {
          if (sub.id == _selectedCategoryId) return sub.id;
        }
      }
      if (RegExp(r'^\d{10,}$').hasMatch(_selectedCategoryId)) {
        return _selectedCategoryId;
      }
    }

    // 2. Exact match on parent name AND child name
    for (final parent in matchingPrimaries) {
      if (parent.name.toLowerCase() == _categoryParent.toLowerCase()) {
        for (final sub in parent.subCategories) {
          if (sub.name.toLowerCase() == _categoryChild.toLowerCase()) {
            _selectedCategoryId = sub.id;
            return sub.id;
          }
        }
        if (parent.subCategories.isNotEmpty) {
          _selectedCategoryId = parent.subCategories.first.id;
          return parent.subCategories.first.id;
        }
        _selectedCategoryId = parent.id;
        return parent.id;
      }
    }

    // 3. Match child name in any primary of this type
    for (final parent in matchingPrimaries) {
      for (final sub in parent.subCategories) {
        if (sub.name.toLowerCase() == _categoryChild.toLowerCase()) {
          _selectedCategoryId = sub.id;
          return sub.id;
        }
      }
    }

    // 4. Match parent name
    for (final parent in matchingPrimaries) {
      if (parent.name.toLowerCase() == _categoryParent.toLowerCase()) {
        if (parent.subCategories.isNotEmpty) {
          _selectedCategoryId = parent.subCategories.first.id;
          return parent.subCategories.first.id;
        }
        _selectedCategoryId = parent.id;
        return parent.id;
      }
    }

    // 5. Fallback to first available category's first subcategory in API
    if (matchingPrimaries.isNotEmpty) {
      final first = matchingPrimaries.first;
      if (first.subCategories.isNotEmpty) {
        _selectedCategoryId = first.subCategories.first.id;
        return first.subCategories.first.id;
      }
      _selectedCategoryId = first.id;
      return first.id;
    }

    return _selectedCategoryId.isNotEmpty ? _selectedCategoryId : '0';
  }

  Future<String> _resolveAccountId() async {
    final repo = _accountsRepository;
    List<Account> leafAccounts = [];
    if (repo != null) {
      try {
        final res = await repo.getAccounts();
        final accList = res.getOrElse(() => []);
        if (accList.isNotEmpty) {
          leafAccounts = _getLeafAccounts(accList);
        }
      } catch (_) {}
    }

    // 1. If _selectedAccountId matches a valid leaf account from API, return it
    if (_selectedAccountId.isNotEmpty && _selectedAccountId != '0') {
      for (final leaf in leafAccounts) {
        if (leaf.id == _selectedAccountId) {
          return leaf.id;
        }
      }
      if (RegExp(r'^\d{10,}$').hasMatch(_selectedAccountId)) {
        return _selectedAccountId;
      }
    }

    // 2. Look for name match among leaf accounts
    for (final leaf in leafAccounts) {
      if (leaf.name.toLowerCase() == _account.toLowerCase()) {
        _selectedAccountId = leaf.id;
        return leaf.id;
      }
    }

    // 3. Fallback to first available leaf account from API
    if (leafAccounts.isNotEmpty) {
      _selectedAccountId = leafAccounts.first.id;
      _account = leafAccounts.first.name;
      return leafAccounts.first.id;
    }

    if (_selectedAccountId.isNotEmpty && _selectedAccountId != '0') {
      return _selectedAccountId;
    }

    return '3845184654445379585';
  }

  Future<void> _handleSave() async {
    if (_isSubmitting) return;

    if (_amount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount.'),
          backgroundColor: Color(0xFFE75A4C),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final catId = await _resolveCategoryId();
    final accId = await _resolveAccountId();

    if (!mounted) return;

    final typeVal = _selectedType == TransactionType.income
        ? 2
        : (_selectedType == TransactionType.transfer ? 4 : 3);

    final request = AddTransactionRequestModel(
      type: typeVal,
      categoryId: catId,
      time: _transactionDateTime.millisecondsSinceEpoch ~/ 1000,
      utcOffset: _transactionDateTime.timeZoneOffset.inMinutes,
      sourceAccountId: accId,
      sourceAmount: (_amount * 100).round(),
      destinationAccountId: _selectedType == TransactionType.transfer
          ? _selectedDestinationAccountId
          : null,
      destinationAmount: _selectedType == TransactionType.transfer
          ? (_amount * 100).round()
          : null,
      hideAmount: false,
      tagIds: _selectedTagId.isNotEmpty
          ? [_selectedTagId]
          : (_tag == 'None' || _tag.isEmpty ? const [] : [_tag]),
      comment: _descriptionController.text.trim(),
    );

    final bloc = _bloc;
    if (bloc != null) {
      bloc.add(AddTransactionRequested(request));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Transaction saved (\$ ${_amount.toStringAsFixed(2)})',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF1E293B),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      context.pop(true);
    }
  }

  void _showMoreOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  leading: Icon(Icons.copy_rounded, color: textColor),
                  title: Text(
                    'Duplicate Transaction',
                    style: TextStyle(color: textColor),
                  ),
                  onTap: () => Navigator.pop(ctx),
                ),
                ListTile(
                  leading: Icon(
                    Icons.bookmark_border_rounded,
                    color: textColor,
                  ),
                  title: Text(
                    'Save as Template',
                    style: TextStyle(color: textColor),
                  ),
                  onTap: () => Navigator.pop(ctx),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                  ),
                  title: const Text(
                    'Clear All Fields',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  onTap: () {
                    setState(() {
                      _amount = 0.0;
                      _descriptionController.clear();
                    });
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAmountEditor() {
    AmountKeypadSheet.show(
      context,
      initialAmount: _amount,
      onAmountChanged: (newAmount) {
        setState(() => _amount = newAmount);
      },
      onConfirm: (confirmedAmount) {
        setState(() => _amount = confirmedAmount);
      },
    );
  }

  void _showCategoryPicker() {
    final catType = _selectedType == TransactionType.income
        ? CategoryType.income
        : (_selectedType == TransactionType.transfer
              ? CategoryType.transfer
              : CategoryType.expense);

    CategoryPickerSheet.show(
      context,
      categoryType: catType,
      categoriesRepository: _categoriesRepository,
      initialPrimaryCategory: _categoryParent,
      initialSubCategory: _categoryChild,
      onCategorySelected: (selection) {
        setState(() {
          _categoryParent = selection.parentName;
          _categoryChild = selection.childName;
          _selectedCategoryId =
              selection.subCategory?.id ?? selection.primary.id;
        });
      },
    );
  }

  void _showAccountPicker() {
    AccountPickerSheet.show(
      context,
      selectedAccountName: _account,
      selectedAccountId: _selectedAccountId,
      accountsRepository: _accountsRepository,
      onAccountSelected: (account) {
        setState(() {
          _account = account.name;
          _selectedAccountId = account.id;
        });
      },
    );
  }

  Future<void> _pickDateTime() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _transactionDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Color(0xFFC86D3B),
                    surface: Color(0xFF1C1C1E),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: Color(0xFFC86D3B),
                    surface: Colors.white,
                    onSurface: Color(0xFF1C1C1E),
                  ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_transactionDateTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Color(0xFFC86D3B),
                    surface: Color(0xFF1C1C1E),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: Color(0xFFC86D3B),
                    surface: Colors.white,
                    onSurface: Color(0xFF1C1C1E),
                  ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null || !mounted) return;

    setState(() {
      _transactionDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
        _transactionDateTime.second,
      );
    });
  }

  void _showTimezonePicker() {
    TimezonePickerSheet.show(
      context,
      currentTimezone: _timezone,
      onTimezoneSelected: (tz) {
        setState(() => _timezone = tz);
      },
    );
  }

  void _showLocationPicker() {
    GeographicLocationActionSheet.show(
      context,
      currentLocation: _location,
      onUpdateLocation: (loc) {
        setState(() => _location = loc);
      },
      onClearLocation: () {
        setState(() => _location = 'No Location');
      },
    );
  }

  void _showTagsPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);

    final tags = _availableTags.isNotEmpty
        ? _availableTags
        : [
            const TagItem(id: '1', name: 'Essential'),
            const TagItem(id: '2', name: 'Discretionary'),
            const TagItem(id: '3', name: 'Tax Deductible'),
            const TagItem(id: '4', name: 'Vacation'),
            const TagItem(id: '5', name: 'Gift'),
          ];

    showModalBottomSheet(
      context: context,
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
              Text(
                'Tags',
                style: TextStyle(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(
                  'None',
                  style: TextStyle(
                    color: _tag == 'None' || _tag.isEmpty
                        ? const Color(0xFFC86D3B)
                        : textColor,
                    fontWeight: _tag == 'None' || _tag.isEmpty
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
                trailing: _tag == 'None' || _tag.isEmpty
                    ? const Icon(Icons.check_rounded, color: Color(0xFFC86D3B))
                    : null,
                onTap: () {
                  setState(() {
                    _tag = 'None';
                    _selectedTagId = '';
                  });
                  Navigator.pop(ctx);
                },
              ),
              ...tags.where((t) => t.name != 'None').map((t) {
                final isSelected =
                    t.name == _tag ||
                    (t.id.isNotEmpty && t.id == _selectedTagId);
                return ListTile(
                  title: Text(
                    t.name,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFFC86D3B) : textColor,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          color: Color(0xFFC86D3B),
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _tag = t.name;
                      _selectedTagId = t.id;
                    });
                    Navigator.pop(ctx);
                  },
                );
              }),
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

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Top Header with back button, Add/Edit Transaction, and right pill with ... and ✓
                        TransactionHeader(
                          title: widget.pageTitle ??
                              (widget.transactionToEdit != null
                                  ? 'Edit Transaction'
                                  : 'Add Transaction'),
                          onBackPressed: () => context.pop(),
                          onSavePressed: _isSubmitting ? () {} : _handleSave,
                          onMorePressed: _showMoreOptions,
                        ),
                        const SizedBox(height: 16),

                        // 2. Segmented Pill Tab Bar (Expense | Income | Transfer)
                        TransactionTypeSelector(
                          selectedType: _selectedType,
                          onTypeChanged: (type) {
                            setState(() {
                              _selectedType = type;
                              if (type == TransactionType.income) {
                                _categoryParent = 'Occupational Earnings';
                                _categoryChild = 'Salary Income';
                              } else if (type == TransactionType.transfer) {
                                _categoryParent = 'General Transfer';
                                _categoryChild = 'Bank Transfer';
                              } else {
                                _categoryParent = 'Food & Drink';
                                _categoryChild = 'Food';
                              }
                              _selectedCategoryId = '';
                            });
                            _preloadCategories();
                          },
                        ),
                        const SizedBox(height: 16),

                        // 3. Main Form Card
                        TransactionFormCard(
                          type: _selectedType,
                          amount: _amount,
                          categoryParent: _categoryParent,
                          categoryChild: _categoryChild,
                          account: _account,
                          transactionTime: _formattedDateTime,
                          timezone: _timezone,
                          location: _location,
                          tag: _tag,
                          descriptionController: _descriptionController,
                          onAmountTap: _showAmountEditor,
                          onCategoryTap: _showCategoryPicker,
                          onAccountTap: _showAccountPicker,
                          onTimeTap: _pickDateTime,
                          onTimezoneTap: _showTimezonePicker,
                          onLocationTap: _showLocationPicker,
                          onTagsTap: _showTagsPicker,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom bar with Save button based on Quick Save Button Style preference
            _buildBottomSaveBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSaveBar() {
    final style = _preferencesController?.quickSaveButtonStyle ??
        (getIt.isRegistered<PreferencesController>()
            ? getIt<PreferencesController>().quickSaveButtonStyle
            : 'Bottom Right Floating');

    if (style == 'Disabled') {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: TransactionSaveButton(
            style: style,
            onSave: _isSubmitting ? () {} : _handleSave,
          ),
        ),
      ),
    );
  }
}
