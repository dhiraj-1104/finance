import 'package:ezbookkeeping/features/authentication/data/models/user_model.dart';
import 'package:ezbookkeeping/features/authentication/domain/entities/login_result.dart';

/// Model encapsulating the payload of a successful login authentication.
class LoginResultModel {
  const LoginResultModel({
    required this.token,
    required this.need2FA,
    required this.user,
    this.notificationContent,
    this.needVerifyEmail = false,
    this.presetCategoriesSaved = false,
  });

  /// JWT authentication token.
  final String token;

  /// Indicates if two-factor authentication verification is needed.
  final bool need2FA;

  /// User profile details and configuration.
  final UserModel user;

  /// Optional server notification message (e.g., demo environment notice).
  final String? notificationContent;

  /// Indicates if email verification is needed.
  final bool needVerifyEmail;

  /// Indicates if preset categories were saved.
  final bool presetCategoriesSaved;

  factory LoginResultModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const LoginResultModel(
        token: '',
        need2FA: false,
        user: UserModel(username: '', email: '', nickname: ''),
      );
    }

    return LoginResultModel(
      token: json['token']?.toString() ?? '',
      need2FA: json['need2FA'] as bool? ?? false,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>?),
      notificationContent: json['notificationContent'] as String?,
      needVerifyEmail: json['needVerifyEmail'] as bool? ?? false,
      presetCategoriesSaved: json['presetCategoriesSaved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'need2FA': need2FA,
      'user': user.toJson(),
      'notificationContent': notificationContent,
      'needVerifyEmail': needVerifyEmail,
      'presetCategoriesSaved': presetCategoriesSaved,
    };
  }

  LoginResultModel copyWith({
    String? token,
    bool? need2FA,
    UserModel? user,
    String? notificationContent,
    bool? needVerifyEmail,
    bool? presetCategoriesSaved,
  }) {
    return LoginResultModel(
      token: token ?? this.token,
      need2FA: need2FA ?? this.need2FA,
      user: user ?? this.user,
      notificationContent: notificationContent ?? this.notificationContent,
      needVerifyEmail: needVerifyEmail ?? this.needVerifyEmail,
      presetCategoriesSaved:
          presetCategoriesSaved ?? this.presetCategoriesSaved,
    );
  }

  @override
  String toString() {
    return 'LoginResultModel(need2FA: $need2FA, user: $user, hasNotification: ${notificationContent != null}, needVerifyEmail: $needVerifyEmail, presetCategoriesSaved: $presetCategoriesSaved)';
  }

  /// Converts this [LoginResultModel] to the pure domain [LoginResult] entity.
  LoginResult toEntity() {
    return LoginResult(
      token: token,
      need2FA: need2FA,
      user: user.toEntity(),
      notificationContent: notificationContent,
      needVerifyEmail: needVerifyEmail,
      presetCategoriesSaved: presetCategoriesSaved,
    );
  }
}
