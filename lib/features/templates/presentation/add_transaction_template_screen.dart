import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/core/utils/uuid_helper.dart';
import 'package:ezbookkeeping/features/accounts/domain/entities/account.dart';
import 'package:ezbookkeeping/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:ezbookkeeping/features/accounts/widgets/account_picker_sheet.dart';
import 'package:ezbookkeeping/features/categories/domain/repositories/categories_repository.dart';
import 'package:ezbookkeeping/features/categories/models/category_item.dart';
import 'package:ezbookkeeping/features/categories/widgets/category_picker_sheet.dart';
import 'package:ezbookkeeping/features/home/widgets/transaction_type_selector.dart';
import 'package:ezbookkeeping/features/tags/domain/repositories/tags_repository.dart';
import 'package:ezbookkeeping/features/tags/models/tag_item.dart';
import 'package:ezbookkeeping/features/templates/data/models/add_transaction_template_request_model.dart';
import 'package:ezbookkeeping/features/templates/domain/repositories/templates_repository.dart';
import 'package:ezbookkeeping/features/templates/domain/usecases/add_transaction_template_use_case.dart';
import 'package:ezbookkeeping/features/templates/models/transaction_template.dart';
import 'package:ezbookkeeping/features/templates/presentation/bloc/templates_bloc.dart';
import 'package:ezbookkeeping/features/templates/presentation/bloc/templates_event.dart';
import 'package:ezbookkeeping/features/templates/presentation/bloc/templates_state.dart';

class AddTransactionTemplateScreen extends StatefulWidget {
  final TransactionType initialType;
  final TransactionTemplate? templateToEdit;
  final TemplatesBloc? bloc;
  final AddTransactionTemplateUseCase? addTransactionTemplateUseCase;
  final TemplatesRepository? templatesRepository;
  final CategoriesRepository? categoriesRepository;
  final AccountsRepository? accountsRepository;
  final TagsRepository? tagsRepository;

  const AddTransactionTemplateScreen({
    super.key,
    this.initialType = TransactionType.expense,
    this.templateToEdit,
    this.bloc,
    this.addTransactionTemplateUseCase,
    this.templatesRepository,
    this.categoriesRepository,
    this.accountsRepository,
    this.tagsRepository,
  });

  @override
  State<AddTransactionTemplateScreen> createState() =>
      _AddTransactionTemplateScreenState();
}

class _AddTransactionTemplateScreenState
    extends State<AddTransactionTemplateScreen> {
  late final TemplatesBloc? _bloc;
  StreamSubscription<TemplatesState>? _blocSubscription;
  late final AddTransactionTemplateUseCase? _addUseCase;
  late final TemplatesRepository? _templatesRepository;
  late final CategoriesRepository? _categoriesRepository;
  late final AccountsRepository? _accountsRepository;
  late final TagsRepository? _tagsRepository;

  late TransactionType _selectedType;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  double _amount = 0.00;
  double _destinationAmount = 0.00;
  bool _hideAmount = false;
  bool _isSubmitting = false;

  late String _categoryParent;
  late String _categoryChild;
  String _selectedCategoryId = '';
  String _sourceAccount = 'Wallet (US Dollar)';
  String _selectedAccountId = '';
  String _destinationAccount = 'Wallet (US Dollar)';
  String? _selectedDestinationAccountId;
  String _tag = 'None';
  String _selectedTagId = '';
  List<TagItem> _availableTags = [];
  List<CategoryItem> _fetchedCategories = [];

  static const Color _copperAccent = Color(0xFFC86D3B);
  static const Color _tealAmount = Color(0xFF0D9488);
  static const Color _redAmount = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();

    if (widget.bloc != null) {
      _bloc = widget.bloc;
    } else if (getIt.isRegistered<TemplatesBloc>()) {
      _bloc = getIt<TemplatesBloc>();
    } else {
      _bloc = null;
    }

    _addUseCase =
        widget.addTransactionTemplateUseCase ??
        (getIt.isRegistered<AddTransactionTemplateUseCase>()
            ? getIt<AddTransactionTemplateUseCase>()
            : null);

    _templatesRepository =
        widget.templatesRepository ??
        (getIt.isRegistered<TemplatesRepository>()
            ? getIt<TemplatesRepository>()
            : null);

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
        if (state is TransactionTemplateAddLoading) {
          setState(() => _isSubmitting = true);
        } else if (state is TransactionTemplateAddSuccess) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Template "${state.template.name}" saved'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          final router = GoRouter.maybeOf(context);
          if (router != null && router.canPop()) {
            router.pop(state.template);
          } else if (Navigator.canPop(context)) {
            Navigator.pop(context, state.template);
          }
        } else if (state is TransactionTemplateAddFailure) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFFE75A4C),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    }

    if (widget.templateToEdit != null) {
      final t = widget.templateToEdit!;
      _selectedType = t.type == 2
          ? TransactionType.income
          : (t.type == 4 ? TransactionType.transfer : TransactionType.expense);
      _nameController.text = t.name;
      _amount = t.amount;
      _destinationAmount = t.destAmount;
      _categoryParent = t.categoryParent;
      _categoryChild = t.categoryChild;
      _selectedCategoryId = t.categoryId ?? '';
      _sourceAccount = t.sourceAccount;
      _selectedAccountId = t.sourceAccountId ?? '';
      _destinationAccount = t.destinationAccount;
      _selectedDestinationAccountId = t.destinationAccountId;
      _tag = t.tag;
      _hideAmount = t.hideAmount;
      if (t.description != null) {
        _descriptionController.text = t.description!;
      }
    } else {
      _selectedType = widget.initialType;
      _updateDefaultsForType(_selectedType);
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
                    (a) => a.name.toLowerCase() == _sourceAccount.toLowerCase(),
                    orElse: () => leafAccounts.first,
                  );
                  setState(() {
                    _sourceAccount = matched.name;
                    _selectedAccountId = matched.id;
                  });
                }
              }
            }
          })
          .catchError((_) {});
    }
  }

  Future<String> _resolveCategoryId() async {
    if (_selectedCategoryId.isNotEmpty && _selectedCategoryId != '0') {
      return _selectedCategoryId;
    }

    final repo = _categoriesRepository;
    if (repo == null) {
      return '3845555742035673099';
    }

    List<CategoryItem> categories = _fetchedCategories;
    if (categories.isEmpty) {
      try {
        categories = await repo.getCategories();
        _fetchedCategories = categories;
      } catch (_) {}
    }

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
      if (chosen.subCategories.isNotEmpty) {
        final matchedSub = chosen.subCategories.firstWhere(
          (s) => s.name.toLowerCase() == _categoryChild.toLowerCase(),
          orElse: () => chosen.subCategories.first,
        );
        _selectedCategoryId = matchedSub.id;
        return matchedSub.id;
      } else {
        _selectedCategoryId = chosen.id;
        return chosen.id;
      }
    }

    return '3845555742035673099';
  }

  Future<String> _resolveAccountId() async {
    if (_selectedAccountId.isNotEmpty && _selectedAccountId != '0') {
      return _selectedAccountId;
    }

    final repo = _accountsRepository;
    if (repo == null) {
      return '3845555741767237633';
    }

    final accountsResult = await repo.getAccounts();
    final accounts = accountsResult.getOrElse(() => []);
    final leafAccounts = _getLeafAccounts(accounts);

    if (leafAccounts.isNotEmpty) {
      final matched = leafAccounts.firstWhere(
        (a) => a.name.toLowerCase() == _sourceAccount.toLowerCase(),
        orElse: () => leafAccounts.first,
      );
      _selectedAccountId = matched.id;
      return matched.id;
    }

    return '3845555741767237633';
  }

  Future<String> _resolveDestinationAccountId() async {
    if (_selectedType != TransactionType.transfer) {
      return '0';
    }
    if (_selectedDestinationAccountId != null &&
        _selectedDestinationAccountId!.isNotEmpty &&
        _selectedDestinationAccountId != '0') {
      return _selectedDestinationAccountId!;
    }

    final repo = _accountsRepository;
    if (repo == null) {
      return '0';
    }

    final accountsResult = await repo.getAccounts();
    final accounts = accountsResult.getOrElse(() => []);
    final leafAccounts = _getLeafAccounts(accounts);

    if (leafAccounts.isNotEmpty) {
      final matched = leafAccounts.firstWhere(
        (a) => a.name.toLowerCase() == _destinationAccount.toLowerCase(),
        orElse: () => leafAccounts.first,
      );
      _selectedDestinationAccountId = matched.id;
      return matched.id;
    }

    return '0';
  }

  @override
  void dispose() {
    _blocSubscription?.cancel();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateDefaultsForType(TransactionType type) {
    switch (type) {
      case TransactionType.expense:
        _categoryParent = 'Food & Drink';
        _categoryChild = 'Food';
        break;
      case TransactionType.income:
        _categoryParent = 'Occupational Earnings';
        _categoryChild = 'Salary Income';
        break;
      case TransactionType.transfer:
        _categoryParent = 'General Transfer';
        _categoryChild = 'Bank Transfer';
        break;
    }
  }

  void _onTypeSelected(TransactionType type) {
    setState(() {
      _selectedType = type;
      _updateDefaultsForType(type);
    });
    _preloadCategories();
  }

  Future<void> _saveTemplate() async {
    if (_isSubmitting) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Template name cannot be empty'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final catId = await _resolveCategoryId();
    final srcAccId = await _resolveAccountId();
    final destAccId = await _resolveDestinationAccountId();

    if (!mounted) return;

    final typeVal = _selectedType == TransactionType.income
        ? 2
        : (_selectedType == TransactionType.transfer ? 4 : 3);

    final clientSessionId = UuidHelper.generate();
    final sourceAmount = (_amount * 100).round();
    final destinationAmount = _selectedType == TransactionType.transfer
        ? (_destinationAmount * 100).round()
        : 0;

    final tagIds = _selectedTagId.isNotEmpty
        ? [_selectedTagId]
        : (_tag == 'None' || _tag.isEmpty ? <String>[] : [_tag]);

    final request = AddTransactionTemplateRequestModel(
      templateType: 1,
      name: name,
      type: typeVal,
      categoryId: catId,
      clientSessionId: clientSessionId,
      comment: _descriptionController.text.trim(),
      destinationAccountId: destAccId,
      destinationAmount: destinationAmount,
      hideAmount: _hideAmount,
      sourceAccountId: srcAccId,
      sourceAmount: sourceAmount,
      tagIds: tagIds,
    );

    final addUseCase = _addUseCase;
    if (addUseCase != null) {
      final result = await addUseCase(request);
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
        (created) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Template "${created.name}" saved'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          final router = GoRouter.maybeOf(context);
          if (router != null && router.canPop()) {
            router.pop(created);
          } else if (Navigator.canPop(context)) {
            Navigator.pop(context, created);
          }
        },
      );
      return;
    }

    final bloc = _bloc;
    if (bloc != null) {
      bloc.add(AddTransactionTemplateRequested.fromRequest(request));
      return;
    }

    final repo = _templatesRepository;
    if (repo != null) {
      final result = await repo.addTransactionTemplate(request);
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
        (created) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Template "${created.name}" saved'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          final router = GoRouter.maybeOf(context);
          if (router != null && router.canPop()) {
            router.pop(created);
          } else if (Navigator.canPop(context)) {
            Navigator.pop(context, created);
          }
        },
      );
      return;
    }

    // Fallback local creation
    setState(() => _isSubmitting = false);
    final localTemplate = TransactionTemplate(
      id: 'tmpl_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: typeVal,
      categoryId: catId,
      sourceAccountId: srcAccId,
      destinationAccountId: destAccId,
      sourceAmount: sourceAmount,
      destinationAmount: destinationAmount,
      hideAmount: _hideAmount,
      tagIds: tagIds,
      comment: _descriptionController.text.trim(),
      categoryParent: _categoryParent,
      categoryChild: _categoryChild,
      sourceAccount: _sourceAccount,
      destinationAccount: _destinationAccount,
      tag: _tag,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Template "$name" saved'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    final router = GoRouter.maybeOf(context);
    if (router != null && router.canPop()) {
      router.pop(localTemplate);
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context, localTemplate);
    }
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
                final isSelected = _selectedTagId == t.id || _tag == t.name;
                return ListTile(
                  title: Text(
                    t.name,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFFC86D3B) : textColor,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_rounded, color: Color(0xFFC86D3B))
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
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showAmountEditDialog({bool isDestination = false}) {
    final controller = TextEditingController(
      text: (isDestination ? _destinationAmount : _amount).toStringAsFixed(2),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            isDestination ? 'Edit Destination Amount' : 'Edit Amount',
            style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
          ),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              prefixText: '\$ ',
              prefixStyle: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: _copperAccent),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _copperAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                final val = double.tryParse(controller.text.trim()) ?? 0.0;
                setState(() {
                  if (isDestination) {
                    _destinationAmount = val;
                  } else {
                    _amount = val;
                  }
                });
                Navigator.pop(ctx);
              },
              child: const Text('OK'),
            ),
          ],
        );
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
      selectedAccountName: _sourceAccount,
      onAccountSelected: (account) {
        setState(() {
          _sourceAccount = account.name;
          _selectedAccountId = account.id;
        });
      },
    );
  }

  void _showSourceAccountPicker() {
    AccountPickerSheet.show(
      context,
      selectedAccountName: _sourceAccount,
      onAccountSelected: (account) {
        setState(() {
          _sourceAccount = account.name;
          _selectedAccountId = account.id;
        });
      },
    );
  }

  void _showDestinationAccountPicker() {
    AccountPickerSheet.show(
      context,
      selectedAccountName: _destinationAccount,
      onAccountSelected: (account) {
        setState(() {
          _destinationAccount = account.name;
          _selectedDestinationAccountId = account.id;
        });
      },
    );
  }

  void _showMoreOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blockBg = isDark
        ? const Color(0xFF2C2C2E).withValues(alpha: 0.95)
        : const Color(0xFFF2F2F7).withValues(alpha: 0.95);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16,
                top: 8,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Block 1: Swap Options (Mockup 5)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: blockBg,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  final temp = _sourceAccount;
                                  _sourceAccount = _destinationAccount;
                                  _destinationAccount = temp;
                                  final tempId = _selectedAccountId;
                                  _selectedAccountId =
                                      _selectedDestinationAccountId ?? '';
                                  _selectedDestinationAccountId = tempId;
                                });
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Accounts swapped'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Swap Account',
                                  style: TextStyle(
                                    color: _copperAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  final temp = _amount;
                                  _amount = _destinationAmount;
                                  _destinationAmount = temp;
                                });
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Amounts swapped'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Swap Amount',
                                  style: TextStyle(
                                    color: _copperAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  final tempAcct = _sourceAccount;
                                  _sourceAccount = _destinationAccount;
                                  _destinationAccount = tempAcct;

                                  final tempAmt = _amount;
                                  _amount = _destinationAmount;
                                  _destinationAmount = tempAmt;
                                });
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Account and amount swapped'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Swap Account and Amount',
                                  style: TextStyle(
                                    color: _copperAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Block 2: Paste / Hide Options
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: blockBg,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Pasted amount'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Paste Amount',
                                  style: TextStyle(
                                    color: _copperAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            InkWell(
                              onTap: () {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Pasted destination amount'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Paste Destination Amount',
                                  style: TextStyle(
                                    color: _copperAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _hideAmount = !_hideAmount;
                                });
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      _hideAmount
                                          ? 'Amount hidden'
                                          : 'Amount shown',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _hideAmount ? 'Show Amount' : 'Hide Amount',
                                  style: const TextStyle(
                                    color: _copperAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Block 3: Cancel
                      Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          color: blockBg,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () => Navigator.pop(ctx),
                            child: const Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: _copperAccent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
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
    final labelColor = isDark ? Colors.white70 : const Color(0xFF1C1C1E);
    final hintColor = isDark ? Colors.white38 : const Color(0xFF9E9EA7);
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

    final Color amountColor = _selectedType == TransactionType.expense
        ? _tealAmount
        : (_selectedType == TransactionType.income
              ? _redAmount
              : _copperAccent);

    final String amountLabel = _selectedType == TransactionType.expense
        ? 'Expense Amount'
        : (_selectedType == TransactionType.income
              ? 'Income Amount'
              : 'Transfer Out Amount');

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
                          'Add Transaction Template',
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

                      // Right Pill Button with '...' and '✓'
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
                                onTap: _saveTemplate,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                    right: 14,
                                    top: 8,
                                    bottom: 8,
                                  ),
                                  child: Icon(
                                    Icons.check_rounded,
                                    color: isDark
                                        ? Colors.white70
                                        : const Color(0xFF555555),
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

            // Segmented Type Selector
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1C1C1E)
                          : const Color(0xFFE2E4EB).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        for (final type in TransactionType.values)
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _onTypeSelected(type),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _selectedType == type
                                      ? (isDark
                                            ? const Color(0xFF2C2C2E)
                                            : Colors.white)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: _selectedType == type
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: isDark ? 0.3 : 0.06,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  type.label,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: _selectedType == type
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: _selectedType == type
                                        ? textColor
                                        : (isDark
                                              ? Colors.white54
                                              : const Color(0xFF6B7280)),
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
                          // Template Name
                          Text(
                            'Template Name',
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
                              hintText: 'Template Name',
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
                            height: 20,
                            thickness: 0.8,
                            color: dividerColor,
                          ),

                          // Amount Display
                          Text(
                            amountLabel,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: amountColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () =>
                                _showAmountEditDialog(isDestination: false),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                _hideAmount
                                    ? '\$ ••••'
                                    : '\$ ${_amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: amountColor,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ),

                          // If Transfer, show Transfer In Amount
                          if (_selectedType == TransactionType.transfer) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Transfer In Amount',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _copperAccent,
                              ),
                            ),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () =>
                                  _showAmountEditDialog(isDestination: true),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Text(
                                  _hideAmount
                                      ? '\$ ••••'
                                      : '\$ ${_destinationAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: _copperAccent,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],

                          Divider(
                            height: 20,
                            thickness: 0.8,
                            color: dividerColor,
                          ),

                          // Category
                          InkWell(
                            onTap: _showCategoryPicker,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Category',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: labelColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        _categoryParent,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      child: Icon(
                                        Icons.chevron_right_rounded,
                                        size: 18,
                                        color: isDark
                                            ? Colors.white38
                                            : const Color(0xFFB0B4BE),
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        _categoryChild,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Divider(
                            height: 20,
                            thickness: 0.8,
                            color: dividerColor,
                          ),

                          // Account / Source & Destination Account
                          if (_selectedType == TransactionType.transfer) ...[
                            InkWell(
                              onTap: _showSourceAccountPicker,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Source Account',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: labelColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _sourceAccount,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              height: 20,
                              thickness: 0.8,
                              color: dividerColor,
                            ),
                            InkWell(
                              onTap: _showDestinationAccountPicker,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Destination Account',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: labelColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _destinationAccount,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            InkWell(
                              onTap: _showAccountPicker,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Account',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: labelColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _sourceAccount,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          Divider(
                            height: 20,
                            thickness: 0.8,
                            color: dividerColor,
                          ),

                          // Tags
                          InkWell(
                            onTap: _showTagsPicker,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tags',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: labelColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF2C2C2E)
                                        : const Color(0xFFF2F2F7),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    _tag,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Divider(
                            height: 20,
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
                              hintText:
                                  'Your transaction description (optional)',
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

            // Bottom Right Save Button (Mockup 2, 3, 4)
            Padding(
              padding: const EdgeInsets.only(right: 24, bottom: 16, top: 4),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: pillShadow,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: _saveTemplate,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Center(
                          child: Text(
                            'Save',
                            style: TextStyle(
                              color: _copperAccent,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
}
