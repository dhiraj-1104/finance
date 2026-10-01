import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ezbookkeeping/features/authentication/domain/usecases/login.dart';
import 'package:ezbookkeeping/features/authentication/domain/usecases/logout.dart';
import 'package:ezbookkeeping/features/authentication/domain/usecases/register.dart';
import 'package:ezbookkeeping/features/authentication/presentation/bloc/authentication_event.dart';
import 'package:ezbookkeeping/features/authentication/presentation/bloc/authentication_state.dart';
import 'package:ezbookkeeping/features/categories/domain/repositories/categories_repository.dart';

/// Flutter Bloc managing Authentication states and events.
/// Uses constructor injection without direct GetIt lookups.
class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final Login login;
  final Register? register;
  final Logout? logout;
  final CategoriesRepository? categoriesRepository;

  AuthenticationBloc({
    required this.login,
    this.register,
    this.logout,
    this.categoriesRepository,
  }) : super(const AuthenticationInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(const AuthenticationLoading());
    final resultEither = await login(
      loginName: event.loginName,
      password: event.password,
    );
    resultEither.fold(
      (failure) => emit(AuthenticationFailure(message: failure.message)),
      (result) => emit(AuthenticationSuccess(loginResult: result)),
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    if (register == null) return;
    emit(const AuthenticationLoading());
    final resultEither = await register!(
      username: event.username,
      email: event.email,
      nickname: event.nickname,
      password: event.password,
      language: event.language,
      defaultCurrency: event.defaultCurrency,
    );
    resultEither.fold(
      (failure) => emit(AuthenticationFailure(message: failure.message)),
      (result) => emit(AuthenticationSuccess(loginResult: result)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(const AuthenticationLoading());
    if (logout != null) {
      await logout!();
    }
    categoriesRepository?.clearCache();
    emit(const AuthenticationInitial());
  }
}
