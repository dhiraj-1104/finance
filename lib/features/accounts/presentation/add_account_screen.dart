import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/features/accounts/data/models/add_account_request_model.dart';
import 'package:ezbookkeeping/features/accounts/presentation/bloc/accounts_bloc.dart';
import 'package:ezbookkeeping/features/accounts/presentation/bloc/accounts_event.dart';
import 'package:ezbookkeeping/features/accounts/presentation/bloc/accounts_state.dart';
import 'package:ezbookkeeping/features/accounts/widgets/account_color_picker_sheet.dart';
import 'package:ezbookkeeping/features/accounts/widgets/account_icon_picker_sheet.dart';
import 'package:ezbookkeeping/features/accounts/widgets/currency_picker_sheet.dart';

class AddAccountScreen extends StatefulWidget {
  final AccountsBloc? bloc;

  const AddAccountScreen({super.key, this.bloc});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  late final AccountsBloc? _bloc;
  StreamSubscription<AccountsState>? _blocSubscription;

  String _category = 'Cash';
  String _type = 'Single Account';
  final TextEditingController _nameController = TextEditingController();
  IconData _icon = Icons.account_balance_wallet_outlined;
  Color _color = const Color(0xFF1C1C1E);
  String _currencyName = 'United States Dollar';
  String _currencyCode = 'USD';
  String _currencySymbol = r'$';
  double _balance = 0.00;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.bloc != null) {
      _bloc = widget.bloc;
    } else if (getIt.isRegistered<AccountsBloc>()) {
      _bloc = getIt<AccountsBloc>();
    } else {
      _bloc = null;
    }

    final bloc = _bloc;
    if (bloc != null) {
      _blocSubscription = bloc.stream.listen((state) {
        if (!mounted) return;
        if (state is AccountCreating) {
          setState(() => _isSubmitting = true);
        } else if (state is AccountCreateSuccess) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Account "${state.newAccount.name}" added successfully',
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
          context.pop(true);
        } else if (state is AccountsError) {
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
  }

  @override
  void dispose() {
    _blocSubscription?.cancel();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  int _getCategoryId(String category) {
    switch (category) {
      case 'Cash':
        return 1;
      case 'Checking Account':
        return 2;
      case 'Credit Card':
        return 3;
      case 'Virtual Account':
        return 4;
      case 'Investment Account':
        return 5;
      case 'Savings Account':
        return 6;
      case 'Debt Account':
        return 7;
      case 'Receivables':
        return 8;
      case 'Certificate of Deposit':
        return 9;
      default:
        return 1;
    }
  }

  String _getIconId(IconData icon) {
    if (icon == Icons.account_balance_wallet_outlined) return '1';
    if (icon == Icons.savings_outlined) return '2';
    if (icon == Icons.credit_card_outlined) return '100';
    if (icon == Icons.account_balance_outlined) return '200';
    return '1';
  }

  void _handleSave() {
    final accountName = _nameController.text.trim();
    if (accountName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an account name'),
          backgroundColor: Color(0xFFE75A4C),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final categoryId = _getCategoryId(_category);
    final typeId = _type == 'Multi-sub Account' ? 2 : 1;
    final colorHex = (_color.toARGB32() & 0xFFFFFF)
        .toRadixString(16)
        .padLeft(6, '0');
    final balanceCents = (_balance * 100).round().toString();

    final request = AddAccountRequestModel(
      name: accountName,
      parentId: '0',
      category: categoryId,
      type: typeId,
      icon: _getIconId(_icon),
      iconType: 0,
      color: colorHex,
      currency: _currencyCode,
      balance: balanceCents,
      balanceTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      comment: _descriptionController.text.trim(),
    );

    final bloc = _bloc;
    if (bloc != null) {
      bloc.add(AddAccountRequested(request));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account "$accountName" added successfully'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      context.pop(true);
    }
  }

  void _showCategoryPicker() {
    final categories = getIt.isRegistered<PreferencesController>()
        ? getIt<PreferencesController>().accountCategories
        : PreferencesController.defaultAccountCategories;
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
          child: SingleChildScrollView(
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
                  'Account Category',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ...categories.map((c) {
                  final isSelected = c == _category;
                  return ListTile(
                    title: Text(
                      c,
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
                      setState(() => _category = c);
                      Navigator.pop(ctx);
                    },
                  );
                }),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTypePicker() {
    final types = ['Single Account', 'Multi-sub Account'];
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
          child: SingleChildScrollView(
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
                  'Account Type',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ...types.map((t) {
                  final isSelected = t == _type;
                  return ListTile(
                    title: Text(
                      t,
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
                      setState(() => _type = t);
                      Navigator.pop(ctx);
                    },
                  );
                }),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBalanceEditor() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final inputBg = isDark ? const Color(0xFF242426) : const Color(0xFFF2F3F8);

    final textController = TextEditingController(
      text: _balance == 0 ? '' : _balance.toStringAsFixed(2),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 16,
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
                'Initial Balance',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: textController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                autofocus: true,
                style: TextStyle(
                  color: textColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  prefixText: '$_currencySymbol ',
                  prefixStyle: TextStyle(
                    color: textColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  filled: true,
                  fillColor: inputBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final parsed =
                      double.tryParse(textController.text.trim()) ?? 0.0;
                  setState(() => _balance = parsed);
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC86D3B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Confirm Balance',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMoreOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);

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
              ListTile(
                leading: Icon(Icons.restore_rounded, color: textColor),
                title: Text(
                  'Reset to Default',
                  style: TextStyle(color: textColor),
                ),
                onTap: () {
                  setState(() {
                    _category = 'Cash';
                    _type = 'Single Account';
                    _nameController.clear();
                    _icon = Icons.account_balance_wallet_outlined;
                    _color = const Color(0xFF1C1C1E);
                    _balance = 0.0;
                    _descriptionController.clear();
                  });
                  Navigator.pop(ctx);
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
        ? const Color(0xFF94A3B8)
        : const Color(0xFF8E8E93);
    final chevronColor = isDark
        ? const Color(0xFF636366)
        : const Color(0xFFC7C7CC);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.05);

    final cardShadow = [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
        blurRadius: 12,
        offset: const Offset(0, 2),
      ),
    ];

    final pillShadow = isDark
        ? null
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ];

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
                            onTap: () => context.pop(),
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

                      // Title "Add Account"
                      Expanded(
                        child: Text(
                          'Add Account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),

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
                                onTap: _isSubmitting ? null : _handleSave,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                    right: 14,
                                    top: 8,
                                    bottom: 8,
                                  ),
                                  child: _isSubmitting
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  textColor,
                                                ),
                                          ),
                                        )
                                      : Icon(
                                          Icons.check_rounded,
                                          color: textColor,
                                          size: 20,
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

            // Main Scrollable Form Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // CARD 1: Account Classification
                        Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: cardShadow,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Account Category
                              _buildFieldTile(
                                label: 'Account Category',
                                child: Text(
                                  _category,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                onTap: _showCategoryPicker,
                              ),
                              _buildDivider(dividerColor),
                              // Account Type
                              _buildFieldTile(
                                label: 'Account Type',
                                child: Text(
                                  _type,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                onTap: _showTypePicker,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // CARD 2: Account Details
                        Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: cardShadow,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 1. Account Name
                              _buildFieldTile(
                                label: 'Account Name',
                                child: TextField(
                                  controller: _nameController,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Your account name',
                                    hintStyle: TextStyle(
                                      color: isDark
                                          ? const Color(0xFF64748B)
                                          : const Color(0xFF9E9EA7),
                                      fontSize: 15,
                                    ),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              _buildDivider(dividerColor),

                              // 2. Row with Account Icon & Account Color
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    // Column 1: Account Icon
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          AccountIconPickerSheet.show(
                                            context,
                                            selectedIcon: _icon,
                                            onIconSelected: (icon) =>
                                                setState(() => _icon = icon),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Account Icon',
                                              style: TextStyle(
                                                color: subtextColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Icon(
                                              _icon,
                                              size: 24,
                                              color: textColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Column 2: Account Color
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          AccountColorPickerSheet.show(
                                            context,
                                            selectedColor: _color,
                                            onColorSelected: (color) =>
                                                setState(() => _color = color),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Account Color',
                                              style: TextStyle(
                                                color: subtextColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color: _color,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _buildDivider(dividerColor),

                              // 3. Currency
                              _buildFieldTile(
                                label: 'Currency',
                                onTap: () {
                                  CurrencyPickerSheet.show(
                                    context,
                                    selectedCurrencyCode: _currencyCode,
                                    onCurrencySelected: (curr) {
                                      setState(() {
                                        _currencyName = curr['name']!;
                                        _currencyCode = curr['code']!;
                                        _currencySymbol = curr['symbol']!;
                                      });
                                    },
                                  );
                                },
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          text: '$_currencyName ',
                                          style: TextStyle(
                                            color: textColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: _currencyCode,
                                              style: TextStyle(
                                                color: subtextColor,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 20,
                                      color: chevronColor,
                                    ),
                                  ],
                                ),
                              ),
                              _buildDivider(dividerColor),

                              // 4. Account Balance
                              _buildFieldTile(
                                label: 'Account Balance',
                                onTap: _showBalanceEditor,
                                child: Text(
                                  '$_currencySymbol ${_balance.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              _buildDivider(dividerColor),

                              // 5. Description
                              _buildFieldTile(
                                label: 'Description',
                                child: TextField(
                                  controller: _descriptionController,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 15,
                                  ),
                                  decoration: InputDecoration(
                                    hintText:
                                        'Your account description (optional)',
                                    hintStyle: TextStyle(
                                      color: isDark
                                          ? const Color(0xFF64748B)
                                          : const Color(0xFF9E9EA7),
                                      fontSize: 15,
                                    ),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
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

  Widget _buildFieldTile({
    required String label,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      height: 1,
      color: color,
    );
  }
}
