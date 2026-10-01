import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/exchange_rates/domain/entities/latest_exchange_rates.dart';

abstract class ExchangeRatesRepository {
  Future<Either<Failure, LatestExchangeRates>> getLatestExchangeRates({
    bool forceRefresh = false,
  });
}
