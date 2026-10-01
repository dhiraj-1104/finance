import 'package:equatable/equatable.dart';

/// Base class for all authentication events.
abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when a user submits their login credentials.
class LoginRequested extends AuthenticationEvent {
  final String loginName;
  final String password;

  const LoginRequested({required this.loginName, required this.password});

  @override
  List<Object?> get props => [loginName, password];

  @override
  String toString() =>
      'LoginRequested(loginName: $loginName, password: [PROTECTED])';
}

/// Event triggered when a user submits registration details.
class RegisterRequested extends AuthenticationEvent {
  final String username;
  final String email;
  final String nickname;
  final String password;
  final String language;
  final String defaultCurrency;

  const RegisterRequested({
    required this.username,
    required this.email,
    required this.nickname,
    required this.password,
    required this.language,
    this.defaultCurrency = 'USD',
  });

  @override
  List<Object?> get props => [
    username,
    email,
    nickname,
    password,
    language,
    defaultCurrency,
  ];

  @override
  String toString() =>
      'RegisterRequested(username: $username, email: $email, nickname: $nickname, language: $language, defaultCurrency: $defaultCurrency, password: [PROTECTED])';
}

/// Event triggered when a user requests to log out.
class LogoutRequested extends AuthenticationEvent {
  const LogoutRequested();
}
