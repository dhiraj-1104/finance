import 'package:equatable/equatable.dart';
import 'package:ezbookkeeping/features/profile/domain/entities/user_profile.dart';

/// Strongly-typed request model for POST /api/v1/users/profile/update.json.
///
/// Encapsulates all 26 preference and profile fields expected by the backend update API.
/// Sensitive fields (password, oldPassword) are masked in [toString] for security.
class UpdateUserProfileRequestModel extends Equatable {
  const UpdateUserProfileRequestModel({
    required this.email,
    required this.nickname,
    this.password = '',
    this.oldPassword = '',
    this.calendarDisplayType = 0,
    this.coordinateDisplayType = 0,
    this.currencyDisplayType = 0,
    this.dateDisplayType = 0,
    this.decimalSeparator = 0,
    this.defaultAccountId = '0',
    this.defaultCurrency = 'USD',
    this.digitGrouping = 0,
    this.digitGroupingSymbol = 0,
    this.expenseAmountColor = 0,
    this.firstDayOfWeek = 0,
    this.fiscalYearFormat = 0,
    this.fiscalYearStart = 257,
    this.incomeAmountColor = 0,
    this.language = '',
    this.longDateFormat = 0,
    this.longTimeFormat = 0,
    this.numeralSystem = 0,
    this.shortDateFormat = 0,
    this.shortTimeFormat = 0,
    this.transactionEditScope = 1,
    this.useLastReconciledTime = false,
  });

  final String email;
  final String nickname;
  final String password;
  final String oldPassword;
  final int calendarDisplayType;
  final int coordinateDisplayType;
  final int currencyDisplayType;
  final int dateDisplayType;
  final int decimalSeparator;
  final String defaultAccountId;
  final String defaultCurrency;
  final int digitGrouping;
  final int digitGroupingSymbol;
  final int expenseAmountColor;
  final int firstDayOfWeek;
  final int fiscalYearFormat;
  final int fiscalYearStart;
  final int incomeAmountColor;
  final String language;
  final int longDateFormat;
  final int longTimeFormat;
  final int numeralSystem;
  final int shortDateFormat;
  final int shortTimeFormat;
  final int transactionEditScope;
  final bool useLastReconciledTime;

  /// Creates a request model initialized with values from an existing [UserProfile] entity.
  factory UpdateUserProfileRequestModel.fromUserProfile(
    UserProfile profile, {
    String password = '',
    String oldPassword = '',
    String? email,
    String? nickname,
    String? language,
    String? defaultCurrency,
    String? defaultAccountId,
    bool? useLastReconciledTime,
    int? transactionEditScope,
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
  }) {
    return UpdateUserProfileRequestModel(
      email: email ?? profile.email,
      nickname: nickname ?? profile.nickname,
      password: password,
      oldPassword: oldPassword,
      calendarDisplayType: calendarDisplayType ?? profile.calendarDisplayType,
      coordinateDisplayType:
          coordinateDisplayType ?? profile.coordinateDisplayType,
      currencyDisplayType: currencyDisplayType ?? profile.currencyDisplayType,
      dateDisplayType: dateDisplayType ?? profile.dateDisplayType,
      decimalSeparator: decimalSeparator ?? profile.decimalSeparator,
      defaultAccountId: defaultAccountId ?? profile.defaultAccountId,
      defaultCurrency: defaultCurrency ?? profile.defaultCurrency,
      digitGrouping: digitGrouping ?? profile.digitGrouping,
      digitGroupingSymbol: digitGroupingSymbol ?? profile.digitGroupingSymbol,
      expenseAmountColor: expenseAmountColor ?? profile.expenseAmountColor,
      firstDayOfWeek: firstDayOfWeek ?? profile.firstDayOfWeek,
      fiscalYearFormat: fiscalYearFormat ?? profile.fiscalYearFormat,
      fiscalYearStart: fiscalYearStart ?? profile.fiscalYearStart,
      incomeAmountColor: incomeAmountColor ?? profile.incomeAmountColor,
      language: language ?? profile.language,
      longDateFormat: longDateFormat ?? profile.longDateFormat,
      longTimeFormat: longTimeFormat ?? profile.longTimeFormat,
      numeralSystem: numeralSystem ?? profile.numeralSystem,
      shortDateFormat: shortDateFormat ?? profile.shortDateFormat,
      shortTimeFormat: shortTimeFormat ?? profile.shortTimeFormat,
      transactionEditScope:
          transactionEditScope ?? profile.transactionEditScope,
      useLastReconciledTime:
          useLastReconciledTime ?? profile.useLastReconciledTime,
    );
  }

  /// Deserializes JSON defensively with type fallback.
  factory UpdateUserProfileRequestModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const UpdateUserProfileRequestModel(email: '', nickname: '');
    }

    return UpdateUserProfileRequestModel(
      email: json['email']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      oldPassword: json['oldPassword']?.toString() ?? '',
      calendarDisplayType: _parseInt(json['calendarDisplayType'], 0),
      coordinateDisplayType: _parseInt(json['coordinateDisplayType'], 0),
      currencyDisplayType: _parseInt(json['currencyDisplayType'], 0),
      dateDisplayType: _parseInt(json['dateDisplayType'], 0),
      decimalSeparator: _parseInt(json['decimalSeparator'], 0),
      defaultAccountId: json['defaultAccountId']?.toString() ?? '0',
      defaultCurrency: json['defaultCurrency']?.toString() ?? 'USD',
      digitGrouping: _parseInt(json['digitGrouping'], 0),
      digitGroupingSymbol: _parseInt(json['digitGroupingSymbol'], 0),
      expenseAmountColor: _parseInt(json['expenseAmountColor'], 0),
      firstDayOfWeek: _parseInt(json['firstDayOfWeek'], 0),
      fiscalYearFormat: _parseInt(json['fiscalYearFormat'], 0),
      fiscalYearStart: _parseInt(json['fiscalYearStart'], 257),
      incomeAmountColor: _parseInt(json['incomeAmountColor'], 0),
      language: json['language']?.toString() ?? '',
      longDateFormat: _parseInt(json['longDateFormat'], 0),
      longTimeFormat: _parseInt(json['longTimeFormat'], 0),
      numeralSystem: _parseInt(json['numeralSystem'], 0),
      shortDateFormat: _parseInt(json['shortDateFormat'], 0),
      shortTimeFormat: _parseInt(json['shortTimeFormat'], 0),
      transactionEditScope: _parseInt(json['transactionEditScope'], 1),
      useLastReconciledTime: json['useLastReconciledTime'] as bool? ?? false,
    );
  }

  /// Serializes request to exact JSON body for the POST API.
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'nickname': nickname,
      'password': password,
      'oldPassword': oldPassword,
      'calendarDisplayType': calendarDisplayType,
      'coordinateDisplayType': coordinateDisplayType,
      'currencyDisplayType': currencyDisplayType,
      'dateDisplayType': dateDisplayType,
      'decimalSeparator': decimalSeparator,
      'defaultAccountId': defaultAccountId,
      'defaultCurrency': defaultCurrency,
      'digitGrouping': digitGrouping,
      'digitGroupingSymbol': digitGroupingSymbol,
      'expenseAmountColor': expenseAmountColor,
      'firstDayOfWeek': firstDayOfWeek,
      'fiscalYearFormat': fiscalYearFormat,
      'fiscalYearStart': fiscalYearStart,
      'incomeAmountColor': incomeAmountColor,
      'language': language,
      'longDateFormat': longDateFormat,
      'longTimeFormat': longTimeFormat,
      'numeralSystem': numeralSystem,
      'shortDateFormat': shortDateFormat,
      'shortTimeFormat': shortTimeFormat,
      'transactionEditScope': transactionEditScope,
      'useLastReconciledTime': useLastReconciledTime,
    };
  }

  /// Converts request model into [UserProfile] entity representation.
  UserProfile toEntity({
    String username = '',
    String avatar = '',
    String avatarProvider = 'internal',
    bool emailVerified = false,
    int lastLoginAt = 0,
  }) {
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

  static int _parseInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  @override
  List<Object?> get props => [
    email,
    nickname,
    password,
    oldPassword,
    calendarDisplayType,
    coordinateDisplayType,
    currencyDisplayType,
    dateDisplayType,
    decimalSeparator,
    defaultAccountId,
    defaultCurrency,
    digitGrouping,
    digitGroupingSymbol,
    expenseAmountColor,
    firstDayOfWeek,
    fiscalYearFormat,
    fiscalYearStart,
    incomeAmountColor,
    language,
    longDateFormat,
    longTimeFormat,
    numeralSystem,
    shortDateFormat,
    shortTimeFormat,
    transactionEditScope,
    useLastReconciledTime,
  ];

  @override
  String toString() {
    return 'UpdateUserProfileRequestModel('
        'email: $email, '
        'nickname: $nickname, '
        'password: ***, '
        'oldPassword: ***, '
        'defaultCurrency: $defaultCurrency, '
        'language: $language, '
        'defaultAccountId: $defaultAccountId, '
        'useLastReconciledTime: $useLastReconciledTime, '
        'firstDayOfWeek: $firstDayOfWeek'
        ')';
  }
}
