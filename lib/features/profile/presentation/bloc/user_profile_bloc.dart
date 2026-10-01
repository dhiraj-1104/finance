import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ezbookkeeping/features/profile/domain/usecases/get_user_profile_use_case.dart';
import 'package:ezbookkeeping/features/profile/presentation/bloc/user_profile_event.dart';
import 'package:ezbookkeeping/features/profile/presentation/bloc/user_profile_state.dart';

/// Flutter Bloc managing User Profile fetching and state.
class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final GetUserProfileUseCase getUserProfile;

  UserProfileBloc({required this.getUserProfile})
    : super(const UserProfileInitial()) {
    on<GetUserProfileRequested>(_onGetUserProfileRequested);
    on<RefreshUserProfileRequested>(_onRefreshUserProfileRequested);
  }

  Future<void> _onGetUserProfileRequested(
    GetUserProfileRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(const UserProfileLoading());
    final resultEither = await getUserProfile();
    resultEither.fold(
      (failure) => emit(UserProfileError(message: failure.message)),
      (profile) => emit(UserProfileLoaded(profile: profile)),
    );
  }

  Future<void> _onRefreshUserProfileRequested(
    RefreshUserProfileRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    final resultEither = await getUserProfile();
    resultEither.fold(
      (failure) => emit(UserProfileError(message: failure.message)),
      (profile) => emit(UserProfileLoaded(profile: profile)),
    );
  }
}
