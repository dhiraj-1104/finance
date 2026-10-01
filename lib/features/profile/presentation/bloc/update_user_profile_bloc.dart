import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ezbookkeeping/features/profile/domain/usecases/update_user_profile_use_case.dart';
import 'package:ezbookkeeping/features/profile/presentation/bloc/update_user_profile_event.dart';
import 'package:ezbookkeeping/features/profile/presentation/bloc/update_user_profile_state.dart';

/// Flutter Bloc managing user profile update operations and state.
class UpdateUserProfileBloc
    extends Bloc<UpdateUserProfileEvent, UpdateUserProfileState> {
  final UpdateUserProfileUseCase updateUserProfile;

  UpdateUserProfileBloc({required this.updateUserProfile})
    : super(const UpdateUserProfileInitial()) {
    on<UpdateUserProfileSubmitted>(_onUpdateUserProfileSubmitted);
    on<ResetUpdateUserProfileState>(_onResetUpdateUserProfileState);
  }

  Future<void> _onUpdateUserProfileSubmitted(
    UpdateUserProfileSubmitted event,
    Emitter<UpdateUserProfileState> emit,
  ) async {
    emit(const UpdateUserProfileLoading());
    final resultEither = await updateUserProfile(event.request);
    resultEither.fold(
      (failure) => emit(UpdateUserProfileFailure(message: failure.message)),
      (profile) => emit(UpdateUserProfileSuccess(updatedProfile: profile)),
    );
  }

  void _onResetUpdateUserProfileState(
    ResetUpdateUserProfileState event,
    Emitter<UpdateUserProfileState> emit,
  ) {
    emit(const UpdateUserProfileInitial());
  }
}
