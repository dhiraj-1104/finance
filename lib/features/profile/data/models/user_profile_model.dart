import 'package:ezbookkeeping/features/profile/domain/entities/user_profile.dart';

/// Strongly-typed data model representing the `result` object of the user profile API.
class UserProfileModel {
  const UserProfileModel({
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

  /// Defensive JSON deserialization with safe type casting and fallback defaults.
  factory UserProfileModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const UserProfileModel(username: '', email: '', nickname: '');
    }

    return UserProfileModel(
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      avatarProvider: json['avatarProvider']?.toString() ?? 'internal',
      defaultAccountId: json['defaultAccountId']?.toString() ?? '0',
      useLastReconciledTime: json['useLastReconciledTime'] as bool? ?? false,
      transactionEditScope: _parseInt(json['transactionEditScope'], 1),
      language: json['language']?.toString() ?? '',
      defaultCurrency: json['defaultCurrency']?.toString() ?? 'USD',
      firstDayOfWeek: _parseInt(json['firstDayOfWeek'], 0),
      fiscalYearStart: _parseInt(json['fiscalYearStart'], 257),
      calendarDisplayType: _parseInt(json['calendarDisplayType'], 0),
      dateDisplayType: _parseInt(json['dateDisplayType'], 0),
      longDateFormat: _parseInt(json['longDateFormat'], 0),
      shortDateFormat: _parseInt(json['shortDateFormat'], 0),
      longTimeFormat: _parseInt(json['longTimeFormat'], 0),
      shortTimeFormat: _parseInt(json['shortTimeFormat'], 0),
      fiscalYearFormat: _parseInt(json['fiscalYearFormat'], 0),
      currencyDisplayType: _parseInt(json['currencyDisplayType'], 0),
      numeralSystem: _parseInt(json['numeralSystem'], 0),
      decimalSeparator: _parseInt(json['decimalSeparator'], 0),
      digitGroupingSymbol: _parseInt(json['digitGroupingSymbol'], 0),
      digitGrouping: _parseInt(json['digitGrouping'], 0),
      coordinateDisplayType: _parseInt(json['coordinateDisplayType'], 0),
      expenseAmountColor: _parseInt(json['expenseAmountColor'], 0),
      incomeAmountColor: _parseInt(json['incomeAmountColor'], 0),
      emailVerified: json['emailVerified'] as bool? ?? false,
      lastLoginAt: _parseInt(json['lastLoginAt'], 0),
    );
  }

  static int _parseInt(dynamic value, int defaultValue) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'nickname': nickname,
      'avatar': avatar,
      'avatarProvider': avatarProvider,
      'defaultAccountId': defaultAccountId,
      'useLastReconciledTime': useLastReconciledTime,
      'transactionEditScope': transactionEditScope,
      'language': language,
      'defaultCurrency': defaultCurrency,
      'firstDayOfWeek': firstDayOfWeek,
      'fiscalYearStart': fiscalYearStart,
      'calendarDisplayType': calendarDisplayType,
      'dateDisplayType': dateDisplayType,
      'longDateFormat': longDateFormat,
      'shortDateFormat': shortDateFormat,
      'longTimeFormat': longTimeFormat,
      'shortTimeFormat': shortTimeFormat,
      'fiscalYearFormat': fiscalYearFormat,
      'currencyDisplayType': currencyDisplayType,
      'numeralSystem': numeralSystem,
      'decimalSeparator': decimalSeparator,
      'digitGroupingSymbol': digitGroupingSymbol,
      'digitGrouping': digitGrouping,
      'coordinateDisplayType': coordinateDisplayType,
      'expenseAmountColor': expenseAmountColor,
      'incomeAmountColor': incomeAmountColor,
      'emailVerified': emailVerified,
      'lastLoginAt': lastLoginAt,
    };
  }

  /// Converts this [UserProfileModel] to the domain [UserProfile] entity.
  UserProfile toEntity() {
    return UserProfile(
      username: username,
      email: email,
      nickname: nickname,
      avatar: avatar,
      avatarProvider: avatarProvider,
      defaultAccountId: defaultAccountId,
      useLastReconciledTime: useLastReconciledTime,
      transactionEditScope: transactionEditScope,
      language: language,
      defaultCurrency: defaultCurrency,
      firstDayOfWeek: firstDayOfWeek,
      fiscalYearStart: fiscalYearStart,
      calendarDisplayType: calendarDisplayType,
      dateDisplayType: dateDisplayType,
      longDateFormat: longDateFormat,
      shortDateFormat: shortDateFormat,
      longTimeFormat: longTimeFormat,
      shortTimeFormat: shortTimeFormat,
      fiscalYearFormat: fiscalYearFormat,
      currencyDisplayType: currencyDisplayType,
      numeralSystem: numeralSystem,
      decimalSeparator: decimalSeparator,
      digitGroupingSymbol: digitGroupingSymbol,
      digitGrouping: digitGrouping,
      coordinateDisplayType: coordinateDisplayType,
      expenseAmountColor: expenseAmountColor,
      incomeAmountColor: incomeAmountColor,
      emailVerified: emailVerified,
      lastLoginAt: lastLoginAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfileModel &&
        other.username == username &&
        other.email == email &&
        other.nickname == nickname &&
        other.avatar == avatar &&
        other.avatarProvider == avatarProvider &&
        other.defaultAccountId == defaultAccountId &&
        other.useLastReconciledTime == useLastReconciledTime &&
        other.transactionEditScope == transactionEditScope &&
        other.language == language &&
        other.defaultCurrency == defaultCurrency &&
        other.firstDayOfWeek == firstDayOfWeek &&
        other.fiscalYearStart == fiscalYearStart &&
        other.calendarDisplayType == calendarDisplayType &&
        other.dateDisplayType == dateDisplayType &&
        other.longDateFormat == longDateFormat &&
        other.shortDateFormat == shortDateFormat &&
        other.longTimeFormat == longTimeFormat &&
        other.shortTimeFormat == shortTimeFormat &&
        other.fiscalYearFormat == fiscalYearFormat &&
        other.currencyDisplayType == currencyDisplayType &&
        other.numeralSystem == numeralSystem &&
        other.decimalSeparator == decimalSeparator &&
        other.digitGroupingSymbol == digitGroupingSymbol &&
        other.digitGrouping == digitGrouping &&
        other.coordinateDisplayType == coordinateDisplayType &&
        other.expenseAmountColor == expenseAmountColor &&
        other.incomeAmountColor == incomeAmountColor &&
        other.emailVerified == emailVerified &&
        other.lastLoginAt == lastLoginAt;
  }

  @override
  int get hashCode => Object.hash(
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
  );

  @override
  String toString() {
    return 'UserProfileModel(username: $username, email: $email, nickname: $nickname, defaultCurrency: $defaultCurrency)';
  }
}
