import 'package:equatable/equatable.dart';

/// Base class for all Tokens events.
sealed class TokensEvent extends Equatable {
  const TokensEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers loading or refreshing of user session tokens from the backend.
final class LoadTokens extends TokensEvent {
  final bool forceRefresh;

  const LoadTokens({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

/// Convenience aliases
typedef LoadTokensRequested = LoadTokens;
typedef GetTokensRequested = LoadTokens;
