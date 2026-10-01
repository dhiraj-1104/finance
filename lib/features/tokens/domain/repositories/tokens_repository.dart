import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import '../entities/token.dart';

/// Contract for accessing authentication tokens / user sessions.
abstract class TokensRepository {
  /// Retrieves the list of active user tokens/sessions.
  Future<Either<Failure, List<Token>>> getTokens({bool forceRefresh = false});

  /// Clears in-memory tokens cache.
  void clearCache();

  /// Whether tokens cache is currently valid.
  bool get isCacheValid;
}

/// Convenience alias
typedef TokenRepository = TokensRepository;
