import 'package:equatable/equatable.dart';
import '../../domain/entities/token.dart';

/// Base class for all Tokens states.
sealed class TokensState extends Equatable {
  const TokensState();

  @override
  List<Object?> get props => [];
}

/// Initial state before tokens are loaded.
final class TokensInitial extends TokensState {
  const TokensInitial();
}

/// State emitted while loading tokens.
final class TokensLoading extends TokensState {
  const TokensLoading();
}

/// State emitted when tokens are successfully loaded.
final class TokensLoaded extends TokensState {
  final List<Token> tokens;

  const TokensLoaded({required this.tokens});

  @override
  List<Object?> get props => [tokens];
}

/// State emitted when fetching tokens fails.
final class TokensError extends TokensState {
  final String message;

  const TokensError({required this.message});

  @override
  List<Object?> get props => [message];
}
