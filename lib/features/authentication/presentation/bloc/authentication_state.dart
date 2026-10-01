import 'package:equatable/equatable.dart';
import 'package:ezbookkeeping/features/authentication/domain/entities/login_result.dart';

/// Base class for all authentication states.
abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object?> get props => [];
}

/// Initial unauthenticated state.
class AuthenticationInitial extends AuthenticationState {
  const AuthenticationInitial();
}

/// State indicating an in-flight authentication request.
class AuthenticationLoading extends AuthenticationState {
  const AuthenticationLoading();
}

/// State indicating successful authentication with the returned [LoginResult].
class AuthenticationSuccess extends AuthenticationState {
  final LoginResult loginResult;

  const AuthenticationSuccess({required this.loginResult});

  @override
  List<Object?> get props => [loginResult];

  @override
  String toString() => 'AuthenticationSuccess(loginResult: $loginResult)';
}

/// State indicating authentication failure with an error [message].
class AuthenticationFailure extends AuthenticationState {
  final String message;

  const AuthenticationFailure({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'AuthenticationFailure(message: $message)';
}
