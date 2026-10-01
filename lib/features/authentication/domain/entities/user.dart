import 'package:equatable/equatable.dart';

/// Pure domain entity representing the authenticated user.
class User extends Equatable {
  const User({
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
    return 'User(username: $username, email: $email, nickname: $nickname)';
  }
}
