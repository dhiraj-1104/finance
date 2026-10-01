import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_tokens_use_case.dart';
import 'tokens_event.dart';
import 'tokens_state.dart';

/// Flutter BLoC managing user authentication tokens and sessions state.
class TokensBloc extends Bloc<TokensEvent, TokensState> {
  final GetTokensUseCase getTokens;

  TokensBloc({required this.getTokens}) : super(const TokensInitial()) {
    on<LoadTokens>(_onLoadTokens);
  }

  Future<void> _onLoadTokens(
    LoadTokens event,
    Emitter<TokensState> emit,
  ) async {
    emit(const TokensLoading());
    final result = await getTokens(forceRefresh: event.forceRefresh);
    result.fold(
      (failure) => emit(TokensError(message: failure.message)),
      (tokens) => emit(TokensLoaded(tokens: tokens)),
    );
  }
}

/// Convenience alias
typedef TokenBloc = TokensBloc;
