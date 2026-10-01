import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/exceptions.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/exchange_rates/data/datasources/exchange_rates_remote_data_source.dart';
import 'package:ezbookkeeping/features/exchange_rates/domain/entities/latest_exchange_rates.dart';
import 'package:ezbookkeeping/features/exchange_rates/domain/repositories/exchange_rates_repository.dart';

class ExchangeRatesRepositoryImpl implements ExchangeRatesRepository {
  final ExchangeRatesRemoteDataSource remoteDataSource;
  LatestExchangeRates? _cachedRates;

  ExchangeRatesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, LatestExchangeRates>> getLatestExchangeRates({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedRates != null) {
      return Right(_cachedRates!);
    }

    try {
      final model = await remoteDataSource.getLatestExchangeRates();
      final entity = model.toEntity();
      _cachedRates = entity;
      return Right(entity);
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
