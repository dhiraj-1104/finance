import 'package:equatable/equatable.dart';
import 'package:ezbookkeeping/features/authentication/domain/entities/user.dart';

/// Pure domain entity representing the result of successful authentication.
class LoginResult extends Equatable {
  const LoginResult({
    required this.token,
    required this.need2FA,
    required this.user,
    this.notificationContent,
    this.needVerifyEmail = false,
    this.presetCategoriesSaved = false,
  });

  /// JWT authentication token.
  final String token;

  /// Whether two-factor authentication is required.
  final bool need2FA;

  /// Authenticated user profile entity.
  final User user;

  /// Optional server notification message.
  final String? notificationContent;

  /// Whether email verification is required.
  final bool needVerifyEmail;

  /// Whether preset categories were saved.
  final bool presetCategoriesSaved;

  @override
  List<Object?> get props => [
    token,
    need2FA,
    user,
    notificationContent,
    needVerifyEmail,
    presetCategoriesSaved,
  ];

  @override
  String toString() {
    return 'LoginResult(need2FA: $need2FA, user: $user, hasNotification: ${notificationContent != null}, needVerifyEmail: $needVerifyEmail, presetCategoriesSaved: $presetCategoriesSaved)';
  }
}
