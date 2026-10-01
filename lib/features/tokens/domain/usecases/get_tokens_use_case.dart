import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import '../entities/token.dart';
import '../repositories/tokens_repository.dart';

/// Clean Architecture Use Case for fetching active tokens/sessions.
class GetTokensUseCase {
  final TokensRepository repository;

  const GetTokensUseCase(this.repository);

  Future<Either<Failure, List<Token>>> call({
    bool forceRefresh = false,
  }) async {
    return await repository.getTokens(forceRefresh: forceRefresh);
  }
}

/// Convenience aliases
typedef GetTokens = GetTokensUseCase;
typedef GetTokensListUseCase = GetTokensUseCase;
