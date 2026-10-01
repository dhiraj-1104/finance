import 'dart:async';
import 'package:ezbookkeeping/core/localization/app_language.dart';
import 'package:ezbookkeeping/core/localization/language_selector_modal.dart';
import 'package:ezbookkeeping/features/profile/data/models/update_user_profile_request_model.dart';
import 'package:ezbookkeeping/features/profile/domain/entities/user_profile.dart';
import 'package:ezbookkeeping/features/profile/presentation/bloc/update_user_profile_bloc.dart';
import 'package:ezbookkeeping/features/profile/presentation/bloc/update_user_profile_event.dart';
import 'package:ezbookkeeping/features/profile/presentation/bloc/update_user_profile_state.dart';
import 'package:ezbookkeeping/features/profile/presentation/bloc/user_profile_bloc.dart';
import 'package:ezbookkeeping/features/profile/presentation/bloc/user_profile_event.dart';
import 'package:ezbookkeeping/features/profile/presentation/bloc/user_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ezbookkeeping/features/accounts/widgets/currency_picker_sheet.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  UserProfileBloc? _profileBloc;
  UpdateUserProfileBloc? _updateProfileBloc;
  StreamSubscription<UserProfileState>? _profileSubscription;
  StreamSubscription<UpdateUserProfileState>? _updateProfileSubscription;
  UserProfile? _currentProfile;
  bool _isLoading = false;
  String? _errorMessage;
  bool _emailVerified = false;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController(
    text: 'ezbookkeeping@mayswind.net',
  );
  final TextEditingController _nicknameController = TextEditingController(
    text: 'demo',
  );

  // Account Preferences
  String _defaultAccount = 'Unspecified';
  String _useLastReconciledTime = 'Disabled';
  String _editableTransactionRange = 'All';

  // Regional & Localization
  String _defaultCurrency = 'United States Dollar USD';
  String _firstDayOfWeek = 'Sunday';
  String _fiscalYearStartDate = 'January 1';

  // Date & Time Display Formats
  String _calendarDisplayType = 'Language Default (Gregorian)';
  String _dateDisplayType = 'Language Default (Gregorian)';
  String _longDateFormat = 'Language Default (September 11, 2026)';
  String _shortDateFormat = 'Language Default (9/11/2026)';
  String _longTimeFormat = 'Language Default (11:42:25 AM)';
  String _shortTimeFormat = 'Language Default (11:42 AM)';
  String _fiscalYearFormat = 'Language Default (FY 2026)';

  // Number & Currency Formats
  String _currencyDisplayMode = r'Language Default ($ 123.45)';
  String _numeralSystem = 'Language Default (0123456789)';
  String _digitGrouping = 'Language Default (Thousands Separator)';
  String _digitGroupingSymbol = 'Language Default (,)';
  String _decimalSeparator = 'Language Default (.)';

  // Geographic Location
  String _geographicLocationFormat = 'System Default (Latitude Longitude D....';

  // Transaction Colors
  String _expenseAmountColor = 'System Default (Green)';
  String _incomeAmountColor = 'System Default (Red)';

  @override
  void initState() {
    super.initState();
    _profileBloc = BlocProvider.of<UserProfileBloc>(context);
    _updateProfileBloc = BlocProvider.of<UpdateUserProfileBloc>(context);
    _profileSubscription = _profileBloc!.stream.listen(_handleProfileState);
    _updateProfileSubscription = _updateProfileBloc!.stream.listen(
      _handleUpdateProfileState,
    );
    _profileBloc!.add(const GetUserProfileRequested());
  }

  void _handleProfileState(UserProfileState state) {
    if (!mounted) return;
    if (state is UserProfileLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    } else if (state is UserProfileLoaded) {
      final p = state.profile;
      _currentProfile = p;
      setState(() {
        _isLoading = false;
        _errorMessage = null;
        if (p.email.isNotEmpty) {
          _emailController.text = p.email;
        }
        if (p.nickname.isNotEmpty) {
          _nicknameController.text = p.nickname;
        }
        _emailVerified = p.emailVerified;
        if (p.defaultCurrency.isNotEmpty) {
          if (p.defaultCurrency == 'USD') {
            _defaultCurrency = 'United States Dollar USD';
          } else if (p.defaultCurrency == 'EUR') {
            _defaultCurrency = 'Euro EUR';
          } else {
            _defaultCurrency = p.defaultCurrency;
          }
        }
        _useLastReconciledTime = p.useLastReconciledTime
            ? 'Enabled'
            : 'Disabled';
      });
    } else if (state is UserProfileError) {
      setState(() {
        _isLoading = false;
        _errorMessage = state.message;
      });
    }
  }

  void _handleUpdateProfileState(UpdateUserProfileState state) {
    if (!mounted) return;
    if (state is UpdateUserProfileLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    } else if (state is UpdateUserProfileSuccess) {
      final p = state.updatedProfile;
      _currentProfile = p;
      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User profile saved successfully'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      final router = GoRouter.maybeOf(context);
      if (router != null && router.canPop()) {
        router.pop();
      } else if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } else if (state is UpdateUserProfileFailure) {
      setState(() {
        _isLoading = false;
        _errorMessage = state.message;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: const Color(0xFFC62828),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    _updateProfileSubscription?.cancel();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email cannot be empty'),
          backgroundColor: Color(0xFFC62828),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    if (password.isNotEmpty && password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Color(0xFFC62828),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final nickname = _nicknameController.text.trim().isNotEmpty
        ? _nicknameController.text.trim()
        : (_currentProfile?.nickname ?? 'demo');

    final currencyCode = _defaultCurrency.contains('USD')
        ? 'USD'
        : _defaultCurrency.contains('EUR')
        ? 'EUR'
        : _defaultCurrency.trim();

    final request = _currentProfile != null
        ? UpdateUserProfileRequestModel.fromUserProfile(
            _currentProfile!,
            email: email,
            nickname: nickname,
            password: password,
            defaultCurrency: currencyCode,
            useLastReconciledTime: _useLastReconciledTime == 'Enabled',
          )
        : UpdateUserProfileRequestModel(
            email: email,
            nickname: nickname,
            password: password,
            defaultCurrency: currencyCode,
            useLastReconciledTime: _useLastReconciledTime == 'Enabled',
          );

    _updateProfileBloc?.add(UpdateUserProfileSubmitted(request));
  }

  void _showOptionsSheet() {
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
                leading: Icon(Icons.restore_rounded, color: textColor),
                title: Text(
                  'Reset to Default',
                  style: TextStyle(color: textColor),
                ),
                onTap: () {
                  setState(() {
                    _passwordController.clear();
                    _confirmPasswordController.clear();
                    _emailController.text = 'ezbookkeeping@mayswind.net';
                    _nicknameController.text = 'demo';
                    _defaultAccount = 'Unspecified';
                    _useLastReconciledTime = 'Disabled';
                    _editableTransactionRange = 'All';
                    _defaultCurrency = 'United States Dollar USD';
                    _firstDayOfWeek = 'Sunday';
                    _fiscalYearStartDate = 'January 1';
                    _calendarDisplayType = 'Language Default (Gregorian)';
                    _dateDisplayType = 'Language Default (Gregorian)';
                    _longDateFormat = 'Language Default (September 11, 2026)';
                    _shortDateFormat = 'Language Default (9/11/2026)';
                    _longTimeFormat = 'Language Default (11:42:25 AM)';
                    _shortTimeFormat = 'Language Default (11:42 AM)';
                    _fiscalYearFormat = 'Language Default (FY 2026)';
                    _currencyDisplayMode = r'Language Default ($ 123.45)';
                    _numeralSystem = 'Language Default (0123456789)';
                    _digitGrouping = 'Language Default (Thousands Separator)';
                    _digitGroupingSymbol = 'Language Default (,)';
                    _decimalSeparator = 'Language Default (.)';
                    _geographicLocationFormat =
                        'System Default (Latitude Longitude D....';
                    _expenseAmountColor = 'System Default (Green)';
                    _incomeAmountColor = 'System Default (Red)';
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reset to default values'),
                      duration: Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showSingleSelectPicker({
    required String title,
    required List<String> options,
    required String currentValue,
    required ValueChanged<String> onSelected,
  }) {
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
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ...options.map((opt) {
                  final isSelected = opt == currentValue;
                  return ListTile(
                    title: Text(
                      opt,
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
                      onSelected(opt);
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark
        ? const Color(0xFF0F0F11)
        : const Color(0xFFEFF1F5);
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final hintColor = isDark
        ? const Color(0xFF64748B)
        : const Color(0xFF9E9EA7);
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

                      // Title "User Profile"
                      Expanded(
                        child: Text(
                          'User Profile',
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
                                onTap: _showOptionsSheet,
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
                                onTap: _handleSave,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                    right: 14,
                                    top: 8,
                                    bottom: 8,
                                  ),
                                  child: Icon(
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

            if (_isLoading)
              const LinearProgressIndicator(
                minHeight: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC86D3B)),
              ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Color(0xFFE75A4C),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // Scrollable Content
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
                        // CARD 1: Account Security & Identity
                        _buildCard(
                          cardBg: cardBg,
                          cardShadow: cardShadow,
                          children: [
                            _buildInputFieldTile(
                              label: 'Password',
                              hintText: 'Your password',
                              controller: _passwordController,
                              obscureText: true,
                              textColor: textColor,
                              hintColor: hintColor,
                            ),
                            _buildDivider(dividerColor),
                            _buildInputFieldTile(
                              label: 'Confirm Password',
                              hintText: 'Re-enter the password',
                              controller: _confirmPasswordController,
                              obscureText: true,
                              textColor: textColor,
                              hintColor: hintColor,
                            ),
                            _buildDivider(dividerColor),
                            _buildInputFieldTile(
                              label: _emailVerified
                                  ? 'E-mail (Verified)'
                                  : 'E-mail (Not Verified)',
                              controller: _emailController,
                              textColor: textColor,
                              hintColor: hintColor,
                              showClearButton: true,
                            ),
                            _buildDivider(dividerColor),
                            _buildInputFieldTile(
                              label: 'Nickname',
                              controller: _nicknameController,
                              textColor: textColor,
                              hintColor: hintColor,
                              showClearButton: true,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // CARD 2: Account Preferences
                        _buildCard(
                          cardBg: cardBg,
                          cardShadow: cardShadow,
                          children: [
                            _buildSelectionTile(
                              label: 'Default Account',
                              value: _defaultAccount,
                              textColor: textColor,
                              onTap: () {
                                _showSingleSelectPicker(
                                  title: 'Default Account',
                                  options: [
                                    'Unspecified',
                                    'Wallet (US Dollar)',
                                    'Wallet (Euro)',
                                    'Checking Account',
                                  ],
                                  currentValue: _defaultAccount,
                                  onSelected: (val) =>
                                      setState(() => _defaultAccount = val),
                                );
                              },
                            ),
                            _buildDivider(dividerColor),
                            _buildSelectionTile(
                              label: 'Use Last Reconciled Time',
                              value: _useLastReconciledTime,
                              textColor: textColor,
                              trailingIcon: Icons.unfold_more_rounded,
                              onTap: () {
                                _showSingleSelectPicker(
                                  title: 'Use Last Reconciled Time',
                                  options: ['Disabled', 'Enabled'],
                                  currentValue: _useLastReconciledTime,
                                  onSelected: (val) => setState(
                                    () => _useLastReconciledTime = val,
                                  ),
                                );
                              },
                            ),
                            _buildDivider(dividerColor),
                            _buildSelectionTile(
                              label: 'Editable Transaction Range',
                              value: _editableTransactionRange,
                              textColor: textColor,
                              chevronColor: chevronColor,
                              onTap: () {
                                _showSingleSelectPicker(
                                  title: 'Editable Transaction Range',
                                  options: [
                                    'All',
                                    'Past 3 Months',
                                    'Past 6 Months',
                                    'Past 1 Year',
                                  ],
                                  currentValue: _editableTransactionRange,
                                  onSelected: (val) => setState(
                                    () => _editableTransactionRange = val,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // CARD 3: Regional & Localization
                        _buildCard(
                          cardBg: cardBg,
                          cardShadow: cardShadow,
                          children: [
                            _buildSelectionTile(
                              label: 'Language',
                              value: AppLanguage.fromLocale(
                                Localizations.localeOf(context),
                              ).nativeName,
                              textColor: textColor,
                              chevronColor: chevronColor,
                              onTap: () async {
                                await LanguageSelectorModal.show(context);
                                if (mounted) {
                                  setState(() {});
                                }
                              },
                            ),
                            _buildDivider(dividerColor),
                            _buildSelectionTile(
                              label: 'Default Currency',
                              value: _defaultCurrency,
                              textColor: textColor,
                              chevronColor: chevronColor,
                              onTap: () {
                                CurrencyPickerSheet.show(
                                  context,
                                  selectedCurrencyCode: 'USD',
                                  onCurrencySelected: (curr) {
                                    setState(() {
                                      _defaultCurrency =
                                          '${curr['name']} ${curr['code']}';
                                    });
                                  },
                                );
                              },
                            ),
                            _buildDivider(dividerColor),
                            _buildSelectionTile(
                              label: 'First Day of Week',
                              value: _firstDayOfWeek,
                              textColor: textColor,
                              chevronColor: chevronColor,
                              onTap: () {
                                _showSingleSelectPicker(
                                  title: 'First Day of Week',
                                  options: ['Sunday', 'Monday', 'Saturday'],
                                  currentValue: _firstDayOfWeek,
                                  onSelected: (val) =>
                                      setState(() => _firstDayOfWeek = val),
                                );
                              },
                            ),
                            _buildDivider(dividerColor),
                            _buildSelectionTile(
                              label: 'Fiscal Year Start Date',
                              value: _fiscalYearStartDate,
                              textColor: textColor,
                              onTap: () {
                                _showSingleSelectPicker(
                                  title: 'Fiscal Year Start Date',
                                  options: [
                                    'January 1',
                                    'April 1',
                                    'July 1',
                                    'October 1',
                                  ],
                                  currentValue: _fiscalYearStartDate,
                                  onSelected: (val) => setState(
                                    () => _fiscalYearStartDate = val,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // CARD 4: Date & Time Display Formats
                        _buildCard(
                          cardBg: cardBg,
                          cardShadow: cardShadow,
                          children: [
                            _buildSelectionTile(
                              label: 'Calendar Display Type',
                              value: _calendarDisplayType,
                              textColor: textColor,
                              chevronColor: chevronColor,
                              onTap: () {
                                _showSingleSelectPicker(
                                  title: 'Calendar Display Type',
                                  options: [
                                    'Language Default (Gregorian)',
                                    'Gregorian Calendar',
                                  ],
                                  currentValue: _calendarDisplayType,
                                  onSelected: (val) => setState(
                                    () => _calendarDisplayType = val,
                                  ),
                                );
                              },
                            ),
                            _buildDivider(dividerColor),
                            _buildSelectionTile(
                              label: 'Date Display Type',
                              value: _dateDisplayType,
                              textColor: textColor,
                              chevronColor: chevronColor,
                              onTap: () {
                                _showSingleSelectPicker(
                                  title: 'Date Display Type',
                                  options: [
                                    'Language Default (Gregorian)',
                                    'Gregorian Calendar',
                                  ],
                                  currentValue: _dateDisplayType,
                                  onSelected: (val) =>
                                      setState(() => _dateDisplayType = val),
                                );
                              },
                            ),
                            _buildDivider(dividerColor),
                            _buildSelectionTile(
                              label: 'Long Date Format',
                              value: _longDateFormat,
                              textColor: textColor,
                              chevronColor: chevronColor,
                              onTap: () {
                                _showSingleSelectPicker(
                                  title: 'Long Date Format',
                                  options: [
                                    'Language Default (September 11, 2026)',
                                    'yyyy-MM-dd',
                                    'MM/dd/yyyy',
                                    'dd/MM/yyyy',
                                  ],
                                  currentValue: _longDateFormat,
                                  onSelected: (val) =>
                                      setState(() => _longDateFormat = val),
                                );
                              },
                            ),
                            _buildDivider(dividerColor),
                            _buildSelectionTile(
                              label: 'Short Date Format',
                              value: _shortDateFormat,
                              textColor: textColor,
                              chevronColor: chevronColor,
                              onTap: () {
                                _showSingleSelectPicker(
                                  title: 'Short Date Format',
                                  options: [
                                    'Language Default (9/11/2026)',
                                    'yyyy-MM-dd',
                                    'MM/dd/yyyy',
                                    'dd/MM/yyyy',
                                  ],
                                  currentValue: _shortDateFormat,
                                  onSelected: (val) =>
                                      setState(() => _shortDateFormat = val),
                                );
                              },
                            ),
                            _buildDivider(dividerColor),
                            _buildSelectionTile(
                              label: 'Long Time Format',
                              value: _longTimeFormat,
                              textColor: textColor,
                              chevronColor: chevronColor,
                              onTap: () {
                                _showSingleSelectPicker(
                                  title: 'Long Time Format',
                                  options: [
                                    'Language Default (11:42:25 AM)',
                                    'HH:mm:ss',
                                    'hh:mm:ss a',
                                  ],
                                  currentValue: _longTimeFormat,
                                  onSelected: (val) =>
                                      setState(() => _longTimeFormat = val),
                                );
                              },
                            ),
                            _buildDivider(dividerColor),
                            _buildSelectionTile(
                              label: 'Short Time Format',
                              value: _shortTimeFormat,
                              textColor: textColor,
                              chevronColor: chevronColor,
                              onTap: () {
                                _showSingleSelectPicker(
                                  title: 'Short Time Format',
                                  options: [
                                    'Language Default (11:42 AM)',
                                    'HH:mm',
                                    'hh:mm a',
                                  ],
                                  currentValue: _shortTimeFormat,
                                  onSelected: (val) =>
                                      setState(() => _shortTimeFormat = val),
                                );
                              },
                            ),
                            _buildDivider(dividerColor),
                            _buildSelectionTile(
                              label: 'Fiscal Year Format',
                              value: _fiscalYearFormat,
                              textColor: textColor,
                              chevronColor: chevronColor,
                              onTap: () {
                                _showSingleSelectPicker(
                                  title: 'Fiscal Year Format',
                                  options: [
                                    'Language Default (FY 2026)',
                                    'FY 2026',
                                    'FY26',
                                    '2025-2026',
                                  ],
                                  currentValue: _fiscalYearFormat,
                                  onSelected: (val) =>
                                      setState(() => _fiscalYearFormat = val),
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // CARD 5: Number & Currency Formats
                        _buildCard(
                          cardBg: cardBg,
                          cardShadow: cardShadow,
                          children: [
                            _buildSelectionTile(
                              label: 'Currency Display Mode',
                              value: _currencyDisplayMode,
                              textColor: textColor,
                              chevronColor: chevronColor,
                              onTap: () {
                                _showSingleSelectPicker(
                                  title: 'Currency Display Mode',
                                  options: [
                                    r'Language Default ($ 123.45)',
                                    r'$ 123.45',
                                    r'123.45 $',
                                    'USD 123.45',
                                  ],
                                  currentValue: _currencyDisplayMode,
                                  onSelected: (val) => setState(
                                    () => _currencyDisplayMode = val,
                                  ),
                                );
                              },
                            ),
                            _buildDivider(dividerColor),
                            _buildSelectionTile(
                              label: 'Numeral System',
                              value: _numeralSystem,
                              textColor: textColor,
                              chevronColor: chevronColor,
                              onTap: () {
                                _showSingleSelectPicker(
                                  title: 'Numeral System',
                                  options: [
                                    'Language Default (0123456789)',
                                    'Arabic-Indic (٠١٢٣٤٥٦٧٨٩)',
                                  ],
                                  currentValue: _numeralSystem,
                                  onSelected: (val) =>
                                      setState(() => _numeralSystem = val),
                                );
                              },
                            ),
                            _buildDivider(dividerColor),
                            _buildSelectionTile(
                              label: 'Digit Grouping',
                              value: _digitGrouping,
                              textColor: textColor,
                              chevronColor: chevronColor,
                              onTap: () {
                                _showSingleSelectPicker(
                                  title: 'Digit Grouping',
                                  options: [
                                    'Language Default (Thousands Separator)',
                                    'Thousands Separator',
                                    'None',
                                  ],
                                  currentValue: _digitGrouping,
                                  onSelected: (val) =>
                                      setState(() => _digitGrouping = val),
                                );
                              },
                            ),
                            _buildDivider(dividerColor),
                            _buildSelectionTile(
                              label: 'Digit Grouping Symbol',
                              value: _digitGroupingSymbol,
                              textColor: textColor,
                              chevronColor: chevronColor,
                              onTap: () {
                                _showSingleSelectPicker(
                                  title: 'Digit Grouping Symbol',
                                  options: [
                                    'Language Default (,)',
                                    ', (Comma)',
                                    '. (Period)',
                                    '  (Space)',
                                  ],
                                  currentValue: _digitGroupingSymbol,
                                  onSelected: (val) => setState(
                                    () => _digitGroupingSymbol = val,
                                  ),
                                );
                              },
                            ),
                            _buildDivider(dividerColor),
                            _buildSelectionTile(
                              label: 'Decimal Separator',
                              value: _decimalSeparator,
                              textColor: textColor,
                              chevronColor: chevronColor,
                              onTap: () {
                                _showSingleSelectPicker(
                                  title: 'Decimal Separator',
                                  options: [
                                    'Language Default (.)',
                                    '. (Period)',
                                    ', (Comma)',
                                  ],
                                  currentValue: _decimalSeparator,
                                  onSelected: (val) =>
                                      setState(() => _decimalSeparator = val),
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // CARD 6: Geographic Location
                        _buildCard(
                          cardBg: cardBg,
                          cardShadow: cardShadow,
                          children: [
                            _buildSelectionTile(
                              label: 'Geographic Location Format',
                              value: _geographicLocationFormat,
                              textColor: textColor,
                              chevronColor: chevronColor,
                              onTap: () {
                                _showSingleSelectPicker(
                                  title: 'Geographic Location Format',
                                  options: [
                                    'System Default (Latitude Longitude D....',
                                    'Decimal Degrees',
                                    'Degrees Minutes Seconds',
                                  ],
                                  currentValue: _geographicLocationFormat,
                                  onSelected: (val) => setState(
                                    () => _geographicLocationFormat = val,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // CARD 7: Transaction Colors
                        _buildCard(
                          cardBg: cardBg,
                          cardShadow: cardShadow,
                          children: [
                            _buildSelectionTile(
                              label: 'Expense Amount Color',
                              value: _expenseAmountColor,
                              textColor: textColor,
                              chevronColor: chevronColor,
                              onTap: () {
                                _showSingleSelectPicker(
                                  title: 'Expense Amount Color',
                                  options: [
                                    'System Default (Green)',
                                    'Red',
                                    'Green',
                                    'Orange',
                                    'Teal',
                                  ],
                                  currentValue: _expenseAmountColor,
                                  onSelected: (val) =>
                                      setState(() => _expenseAmountColor = val),
                                );
                              },
                            ),
                            _buildDivider(dividerColor),
                            _buildSelectionTile(
                              label: 'Income Amount Color',
                              value: _incomeAmountColor,
                              textColor: textColor,
                              chevronColor: chevronColor,
                              onTap: () {
                                _showSingleSelectPicker(
                                  title: 'Income Amount Color',
                                  options: [
                                    'System Default (Red)',
                                    'Green',
                                    'Red',
                                    'Orange',
                                    'Blue',
                                  ],
                                  currentValue: _incomeAmountColor,
                                  onSelected: (val) =>
                                      setState(() => _incomeAmountColor = val),
                                );
                              },
                            ),
                          ],
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

  Widget _buildCard({
    required Color cardBg,
    required List<BoxShadow> cardShadow,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildInputFieldTile({
    required String label,
    String? hintText,
    required TextEditingController controller,
    required Color textColor,
    required Color hintColor,
    bool obscureText = false,
    bool showClearButton = false,
  }) {
    return Padding(
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
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: hintColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 2),
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (showClearButton)
                InkWell(
                  onTap: () {
                    controller.clear();
                    setState(() {});
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.cancel_rounded,
                      size: 18,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionTile({
    required String label,
    required String value,
    required Color textColor,
    Color? chevronColor,
    IconData? trailingIcon,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            children: [
              Expanded(
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
                    Text(
                      value,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (trailingIcon != null)
                Icon(
                  trailingIcon,
                  size: 20,
                  color: chevronColor ?? const Color(0xFF8E8E93),
                )
              else if (chevronColor != null)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: chevronColor,
                ),
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
