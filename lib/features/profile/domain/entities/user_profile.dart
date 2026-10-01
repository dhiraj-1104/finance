import 'package:equatable/equatable.dart';

/// Pure domain entity representing the authenticated user's profile and preferences.
class UserProfile extends Equatable {
  const UserProfile({
    required this.username,
    required this.email,
    required this.nickname,
    this.avatar = '',
    this.avatarProvider = 'internal',
    this.defaultAccountId = '0',
    this.useLastReconciledTime = false,
    this.transactionEditScope = 1,
    this.language = '',
    this.defaultCurrency = 'USD',
    this.firstDayOfWeek = 0,
    this.fiscalYearStart = 257,
    this.calendarDisplayType = 0,
    this.dateDisplayType = 0,
    this.longDateFormat = 0,
    this.shortDateFormat = 0,
    this.longTimeFormat = 0,
    this.shortTimeFormat = 0,
    this.fiscalYearFormat = 0,
    this.currencyDisplayType = 0,
    this.numeralSystem = 0,
    this.decimalSeparator = 0,
    this.digitGroupingSymbol = 0,
    this.digitGrouping = 0,
    this.coordinateDisplayType = 0,
    this.expenseAmountColor = 0,
    this.incomeAmountColor = 0,
    this.emailVerified = false,
    this.lastLoginAt = 0,
  });

  final String username;
  final String email;
  final String nickname;
  final String avatar;
  final String avatarProvider;
  final String defaultAccountId;
  final bool useLastReconciledTime;
  final int transactionEditScope;
  final String language;
  final String defaultCurrency;
  final int firstDayOfWeek;
  final int fiscalYearStart;
  final int calendarDisplayType;
  final int dateDisplayType;
  final int longDateFormat;
  final int shortDateFormat;
  final int longTimeFormat;
  final int shortTimeFormat;
  final int fiscalYearFormat;
  final int currencyDisplayType;
  final int numeralSystem;
  final int decimalSeparator;
  final int digitGroupingSymbol;
  final int digitGrouping;
  final int coordinateDisplayType;
  final int expenseAmountColor;
  final int incomeAmountColor;
  final bool emailVerified;
  final int lastLoginAt;

  UserProfile copyWith({
    String? username,
    String? email,
    String? nickname,
    String? avatar,
    String? avatarProvider,
    String? defaultAccountId,
    bool? useLastReconciledTime,
    int? transactionEditScope,
    String? language,
    String? defaultCurrency,
    int? firstDayOfWeek,
    int? fiscalYearStart,
    int? calendarDisplayType,
    int? dateDisplayType,
    int? longDateFormat,
    int? shortDateFormat,
    int? longTimeFormat,
    int? shortTimeFormat,
    int? fiscalYearFormat,
    int? currencyDisplayType,
    int? numeralSystem,
    int? decimalSeparator,
    int? digitGroupingSymbol,
    int? digitGrouping,
    int? coordinateDisplayType,
    int? expenseAmountColor,
    int? incomeAmountColor,
    bool? emailVerified,
    int? lastLoginAt,
  }) {
    return UserProfile(
      username: username ?? this.username,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      avatarProvider: avatarProvider ?? this.avatarProvider,
      defaultAccountId: defaultAccountId ?? this.defaultAccountId,
      useLastReconciledTime:
          useLastReconciledTime ?? this.useLastReconciledTime,
      transactionEditScope: transactionEditScope ?? this.transactionEditScope,
      language: language ?? this.language,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      fiscalYearStart: fiscalYearStart ?? this.fiscalYearStart,
      calendarDisplayType: calendarDisplayType ?? this.calendarDisplayType,
      dateDisplayType: dateDisplayType ?? this.dateDisplayType,
      longDateFormat: longDateFormat ?? this.longDateFormat,
      shortDateFormat: shortDateFormat ?? this.shortDateFormat,
      longTimeFormat: longTimeFormat ?? this.longTimeFormat,
      shortTimeFormat: shortTimeFormat ?? this.shortTimeFormat,
      fiscalYearFormat: fiscalYearFormat ?? this.fiscalYearFormat,
      currencyDisplayType: currencyDisplayType ?? this.currencyDisplayType,
      numeralSystem: numeralSystem ?? this.numeralSystem,
      decimalSeparator: decimalSeparator ?? this.decimalSeparator,
      digitGroupingSymbol: digitGroupingSymbol ?? this.digitGroupingSymbol,
      digitGrouping: digitGrouping ?? this.digitGrouping,
      coordinateDisplayType:
          coordinateDisplayType ?? this.coordinateDisplayType,
      expenseAmountColor: expenseAmountColor ?? this.expenseAmountColor,
      incomeAmountColor: incomeAmountColor ?? this.incomeAmountColor,
      emailVerified: emailVerified ?? this.emailVerified,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  List<Object?> get props => [
    username,
    email,
    nickname,
    avatar,
    avatarProvider,
    defaultAccountId,
    useLastReconciledTime,
    transactionEditScope,
    language,
    defaultCurrency,
    firstDayOfWeek,
    fiscalYearStart,
    calendarDisplayType,
    dateDisplayType,
    longDateFormat,
    shortDateFormat,
    longTimeFormat,
    shortTimeFormat,
    fiscalYearFormat,
    currencyDisplayType,
    numeralSystem,
    decimalSeparator,
    digitGroupingSymbol,
    digitGrouping,
    coordinateDisplayType,
    expenseAmountColor,
    incomeAmountColor,
    emailVerified,
    lastLoginAt,
  ];

  @override
  String toString() {
    return 'UserProfile(username: $username, email: $email, nickname: $nickname, defaultCurrency: $defaultCurrency)';
  }
}
