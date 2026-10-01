import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ezbookkeeping/app/router/app_routes.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/core/localization/app_language.dart';
import 'package:ezbookkeeping/core/localization/language_selector_modal.dart';
import 'package:ezbookkeeping/features/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:ezbookkeeping/features/authentication/presentation/bloc/authentication_event.dart';
import 'package:ezbookkeeping/features/authentication/presentation/bloc/authentication_state.dart';
import 'package:ezbookkeeping/core/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class CurrencyItem {
  final String name;
  final String code;

  const CurrencyItem({required this.name, required this.code});
}

class SubCategoryItem {
  final String title;
  final IconData? icon;
  final Widget? customIcon;

  const SubCategoryItem({required this.title, this.icon, this.customIcon});
}

class TransactionCategory {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<SubCategoryItem> subcategories;

  const TransactionCategory({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.subcategories,
  });
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final AuthenticationBloc _authBloc;

  // Form Controllers
  final _usernameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedLanguage = 'English';
  CurrencyItem _selectedCurrency = _currencies[0];
  String _selectedFirstDay = 'Sunday';

  bool _usePresetCategories = false;
  bool _isLoading = false;
  final Set<String> _expandedCategories = {'Occupational Earnings'};

  static Widget _buildSideJobIcon(Color color) {
    return SizedBox(
      width: 22,
      height: 22,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Icon(Icons.person_outline, size: 19, color: color),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.schedule, size: 11, color: color),
            ),
          ),
        ],
      ),
    );
  }

  static const List<CurrencyItem> _currencies = [
    CurrencyItem(name: 'United States Dollar', code: 'USD'),
    CurrencyItem(name: 'Euro', code: 'EUR'),
    CurrencyItem(name: 'British Pound', code: 'GBP'),
    CurrencyItem(name: 'Japanese Yen', code: 'JPY'),
    CurrencyItem(name: 'Chinese Yuan', code: 'CNY'),
    CurrencyItem(name: 'Indian Rupee', code: 'INR'),
    CurrencyItem(name: 'Canadian Dollar', code: 'CAD'),
    CurrencyItem(name: 'Australian Dollar', code: 'AUD'),
  ];

  static const List<String> _daysOfWeek = ['Sunday', 'Monday', 'Saturday'];

  static final List<TransactionCategory> _incomeCategories = [
    TransactionCategory(
      title: 'Occupational Earnings',
      icon: Icons.business_center_outlined,
      iconColor: const Color(0xFFF97316),
      subcategories: [
        const SubCategoryItem(
          title: 'Salary Income',
          icon: Icons.account_balance_wallet_outlined,
        ),
        const SubCategoryItem(
          title: 'Bonus Income',
          icon: Icons.emoji_events_outlined,
        ),
        const SubCategoryItem(
          title: 'Overtime Pay',
          icon: Icons.lightbulb_outline,
        ),
        SubCategoryItem(
          title: 'Side Job Income',
          customIcon: _buildSideJobIcon(const Color(0xFFF97316)),
        ),
      ],
    ),
    const TransactionCategory(
      title: 'Finance & Investment',
      icon: Icons.account_balance_outlined,
      iconColor: Color(0xFFEAB308),
      subcategories: [
        SubCategoryItem(title: 'Dividends', icon: Icons.savings_outlined),
        SubCategoryItem(title: 'Interest', icon: Icons.trending_up_outlined),
        SubCategoryItem(
          title: 'Capital Gains',
          icon: Icons.show_chart_outlined,
        ),
        SubCategoryItem(title: 'Rental Income', icon: Icons.home_work_outlined),
      ],
    ),
    const TransactionCategory(
      title: 'Miscellaneous',
      icon: Icons.edit_outlined,
      iconColor: Color(0xFF94A3B8),
      subcategories: [
        SubCategoryItem(title: 'Gifts', icon: Icons.card_giftcard_outlined),
        SubCategoryItem(
          title: 'Lottery',
          icon: Icons.confirmation_number_outlined,
        ),
        SubCategoryItem(
          title: 'Refunds',
          icon: Icons.currency_exchange_outlined,
        ),
        SubCategoryItem(title: 'Other Income', icon: Icons.more_horiz_outlined),
      ],
    ),
  ];

  static const List<TransactionCategory> _expenseCategories = [
    TransactionCategory(
      title: 'Food & Drink',
      icon: Icons.restaurant_outlined,
      iconColor: Color(0xFFFB923C),
      subcategories: [
        SubCategoryItem(title: 'Groceries', icon: Icons.shopping_cart_outlined),
        SubCategoryItem(title: 'Dining Out', icon: Icons.restaurant_outlined),
        SubCategoryItem(title: 'Coffee & Tea', icon: Icons.coffee_outlined),
        SubCategoryItem(title: 'Alcohol', icon: Icons.local_bar_outlined),
      ],
    ),
    TransactionCategory(
      title: 'Clothing & Appearance',
      icon: Icons.checkroom_outlined,
      iconColor: Color(0xFFA855F7),
      subcategories: [
        SubCategoryItem(title: 'Clothing', icon: Icons.checkroom_outlined),
        SubCategoryItem(title: 'Shoes', icon: Icons.shopping_bag_outlined),
        SubCategoryItem(title: 'Cosmetics', icon: Icons.brush_outlined),
        SubCategoryItem(title: 'Haircut', icon: Icons.content_cut_outlined),
      ],
    ),
    TransactionCategory(
      title: 'Housing & Houseware',
      icon: Icons.home_outlined,
      iconColor: Color(0xFF64748B),
      subcategories: [
        SubCategoryItem(title: 'Rent', icon: Icons.home_outlined),
        SubCategoryItem(title: 'Utilities', icon: Icons.power_outlined),
        SubCategoryItem(title: 'Furniture', icon: Icons.chair_outlined),
        SubCategoryItem(title: 'Maintenance', icon: Icons.build_outlined),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _authBloc = getIt<AuthenticationBloc>();
  }

  void _handleAuthState(BuildContext context, AuthenticationState state) {
    if (!mounted) return;
    if (state is AuthenticationLoading) {
      setState(() => _isLoading = true);
    } else if (state is AuthenticationSuccess) {
      setState(() => _isLoading = false);
      final notification = state.loginResult.notificationContent;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            notification != null && notification.isNotEmpty
                ? notification
                : 'Registered successfully!',
          ),
          backgroundColor: const Color(0xFF00897B),
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (state.loginResult.token.isNotEmpty) {
        context.go(AppRoutes.home);
      } else {
        context.go(AppRoutes.login);
      }
    } else if (state is AuthenticationFailure) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (state is AuthenticationInitial) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _authBloc.close();
    _usernameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final email = _emailController.text.trim();

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your username'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your password'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (confirmPassword != password) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final langItem = AppLanguage.supportedLanguages.firstWhere(
      (lang) => lang.englishName == _selectedLanguage,
      orElse: () => AppLanguage.defaultLanguage,
    );

    _authBloc.add(
      RegisterRequested(
        username: username,
        email: email,
        nickname: _nicknameController.text.trim().isNotEmpty
            ? _nicknameController.text.trim()
            : username,
        password: password,
        language: langItem.code,
        defaultCurrency: _selectedCurrency.code,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF0F2F7);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final dividerColor = isDark ? Colors.white10 : const Color(0xFFF1F3F7);
    final labelColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF475569);
    final hintColor = isDark ? Colors.white30 : const Color(0xFFB0B7C3);
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        bloc: _authBloc,
        listener: _handleAuthState,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 4),

                    // Top Header: Circular Back, "Sign Up", Circular Checkmark
                    _buildHeader(isDark: isDark, primaryColor: primaryColor),

                    const SizedBox(height: 18),

                    // Card 1: User Credentials Form
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.2 : 0.03,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildInputField(
                            label: 'Username',
                            hint: 'Your username',
                            controller: _usernameController,
                            labelColor: labelColor,
                            hintColor: hintColor,
                            textColor: textColor,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z0-9]'),
                              ),
                            ],
                          ),
                          Divider(
                            height: 1,
                            thickness: 0.8,
                            color: dividerColor,
                          ),
                          _buildInputField(
                            label: 'Password',
                            hint: 'Your password, at least 6 characters',
                            controller: _passwordController,
                            obscureText: true,
                            labelColor: labelColor,
                            hintColor: hintColor,
                            textColor: textColor,
                          ),
                          Divider(
                            height: 1,
                            thickness: 0.8,
                            color: dividerColor,
                          ),
                          _buildInputField(
                            label: 'Confirm Password',
                            hint: 'Re-enter the password',
                            controller: _confirmPasswordController,
                            obscureText: true,
                            labelColor: labelColor,
                            hintColor: hintColor,
                            textColor: textColor,
                          ),
                          Divider(
                            height: 1,
                            thickness: 0.8,
                            color: dividerColor,
                          ),
                          _buildInputField(
                            label: 'E-mail',
                            hint: 'Your email address',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            labelColor: labelColor,
                            hintColor: hintColor,
                            textColor: textColor,
                          ),
                          Divider(
                            height: 1,
                            thickness: 0.8,
                            color: dividerColor,
                          ),
                          _buildInputField(
                            label: 'Nickname',
                            hint: 'Your nickname',
                            controller: _nicknameController,
                            labelColor: labelColor,
                            hintColor: hintColor,
                            textColor: textColor,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Card 2: Preferences (Language, Default Currency, First Day of Week)
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.2 : 0.03,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildPreferenceRow(
                            label: 'Language',
                            valueWidget: Text(
                              _selectedLanguage,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                            onTap: () => _showLanguagePicker(context),
                            labelColor: labelColor,
                          ),
                          Divider(
                            height: 1,
                            thickness: 0.8,
                            color: dividerColor,
                          ),
                          _buildPreferenceRow(
                            label: 'Default Currency',
                            valueWidget: Row(
                              children: [
                                Text(
                                  _selectedCurrency.name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _selectedCurrency.code,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: labelColor,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => _showCurrencyPicker(context),
                            labelColor: labelColor,
                          ),
                          Divider(
                            height: 1,
                            thickness: 0.8,
                            color: dividerColor,
                          ),
                          _buildPreferenceRow(
                            label: 'First Day of Week',
                            valueWidget: Text(
                              _selectedFirstDay,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                            onTap: () => _showFirstDayPicker(context),
                            labelColor: labelColor,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Card 3: Use preset transaction categories
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.2 : 0.03,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _showPresetCategoriesPreview(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Use preset transaction categories',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                Transform.scale(
                                  scale: 0.85,
                                  child: CupertinoSwitch(
                                    value: _usePresetCategories,
                                    activeTrackColor: primaryColor,
                                    onChanged: (val) {
                                      setState(
                                        () => _usePresetCategories = val,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.chevron_right,
                                  size: 18,
                                  color: Color(0xFFC4C8D2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Top custom navigation bar with circular buttons
  Widget _buildHeader({required bool isDark, required Color primaryColor}) {
    final iconColor = isDark ? Colors.white : const Color(0xFF334155);
    final titleColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Circular Back Button
          _buildCircleButton(
            child: Icon(Icons.chevron_left, size: 22, color: iconColor),
            isDark: isDark,
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.login);
              }
            },
          ),

          // Title: "Sign Up"
          Text(
            'Sign Up',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),

          // Circular Checkmark Submit Button
          _buildCircleButton(
            child: _isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: primaryColor,
                    ),
                  )
                : Icon(Icons.check, size: 20, color: iconColor),
            isDark: isDark,
            onTap: _isLoading ? () {} : _handleSubmit,
          ),
        ],
      ),
    );
  }

  /// Circular elevated icon button for navigation bar
  Widget _buildCircleButton({
    required Widget child,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 38, height: 38, child: Center(child: child)),
      ),
    );
  }

  /// Individual input field within Card 1
  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    required Color labelColor,
    required Color hintColor,
    required Color textColor,
    List<TextInputFormatter> inputFormatters = const [],
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: labelColor,
            ),
          ),
          const SizedBox(height: 4),
          CustomTextFormField(
            inputFormatters: inputFormatters,
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: 14, color: textColor),
            variant: CustomTextFieldVariant.none,
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14,
              color: hintColor,
              fontWeight: FontWeight.w400,
            ),
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  /// Individual preference row within Card 2
  Widget _buildPreferenceRow({
    required String label,
    required Widget valueWidget,
    required VoidCallback onTap,
    required Color labelColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 11.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: labelColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  valueWidget,
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFFC4C8D2)),
          ],
        ),
      ),
    );
  }

  /// Modal Bottom Sheet for Language Selection
  Future<void> _showLanguagePicker(BuildContext context) async {
    final selected = await LanguageSelectorModal.show(context);
    if (selected != null) {
      setState(() => _selectedLanguage = selected.englishName);
    }
  }

  /// Modal Bottom Sheet for Currency Selection
  void _showCurrencyPicker(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final cardColor = theme.cardColor;

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Currency',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _currencies.length,
                  itemBuilder: (ctx, index) {
                    final currency = _currencies[index];
                    final isSelected = currency.code == _selectedCurrency.code;

                    return ListTile(
                      title: Text(currency.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currency.code,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.check, color: primaryColor),
                          ],
                        ],
                      ),
                      onTap: () {
                        setState(() => _selectedCurrency = currency);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Modal Bottom Sheet for First Day of Week Selection
  void _showFirstDayPicker(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final cardColor = theme.cardColor;

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'First Day of Week',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              for (final day in _daysOfWeek)
                ListTile(
                  title: Text(day),
                  trailing: day == _selectedFirstDay
                      ? Icon(Icons.check, color: primaryColor)
                      : null,
                  onTap: () {
                    setState(() => _selectedFirstDay = day);
                    Navigator.pop(ctx);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  /// Modal Bottom Sheet to preview Preset Categories
  void _showPresetCategoriesPreview(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              expand: false,
              builder: (innerCtx, scrollController) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Preset Categories Preview',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => Navigator.pop(sheetCtx),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        children: [
                          const Text(
                            'Income Categories',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          for (final cat in _incomeCategories)
                            _buildCategoryAccordionItem(
                              category: cat,
                              theme: theme,
                              onToggle: () {
                                setSheetState(() {
                                  if (_expandedCategories.contains(cat.title)) {
                                    _expandedCategories.remove(cat.title);
                                  } else {
                                    _expandedCategories.add(cat.title);
                                  }
                                });
                              },
                            ),
                          const SizedBox(height: 20),
                          const Text(
                            'Expense Categories',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          for (final cat in _expenseCategories)
                            _buildCategoryAccordionItem(
                              category: cat,
                              theme: theme,
                              onToggle: () {
                                setSheetState(() {
                                  if (_expandedCategories.contains(cat.title)) {
                                    _expandedCategories.remove(cat.title);
                                  } else {
                                    _expandedCategories.add(cat.title);
                                  }
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  /// Category item in preview sheet
  Widget _buildCategoryAccordionItem({
    required TransactionCategory category,
    required ThemeData theme,
    required VoidCallback onToggle,
  }) {
    final isExpanded = _expandedCategories.contains(category.title);
    final onSurface = theme.colorScheme.onSurface;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(category.icon, color: category.iconColor, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      category.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                    color: onSurface.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            for (final sub in category.subcategories) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 18),
                    if (sub.customIcon != null)
                      sub.customIcon!
                    else if (sub.icon != null)
                      Icon(sub.icon, color: category.iconColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        sub.title,
                        style: TextStyle(fontSize: 13, color: onSurface),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
