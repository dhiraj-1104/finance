import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/exceptions.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import '../../domain/entities/token.dart';
import '../../domain/repositories/tokens_repository.dart';
import '../datasources/tokens_remote_data_source.dart';

/// Concrete implementation of [TokensRepository] providing in-memory caching
/// and error mapping.
class TokensRepositoryImpl implements TokensRepository {
  final TokensRemoteDataSource remoteDataSource;

  List<Token>? _cachedTokens;
  Future<List<Token>>? _inFlightFuture;

  TokensRepositoryImpl({required this.remoteDataSource});

  @override
  bool get isCacheValid => _cachedTokens != null;

  @override
  Future<Either<Failure, List<Token>>> getTokens({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedTokens != null) {
      return Right(_cachedTokens!);
    }

    if (_inFlightFuture != null) {
      try {
        final tokens = await _inFlightFuture!;
        return Right(tokens);
      } on AppException catch (e) {
        return Left(e.toFailure());
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    }

    _inFlightFuture = _fetchTokensFromRemote();
    try {
      final tokens = await _inFlightFuture!;
      _cachedTokens = tokens;
      return Right(tokens);
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    } finally {
      _inFlightFuture = null;
    }
  }

  @override
  void clearCache() {
    _cachedTokens = null;
    _inFlightFuture = null;
  }

  Future<List<Token>> _fetchTokensFromRemote() async {
    final models = await remoteDataSource.getTokens();
    return models.map((m) => m.toEntity()).toList();
  }
}

/// Convenience alias
typedef TokenRepositoryImpl = TokensRepositoryImpl;
