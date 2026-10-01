import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/exchange_rates/domain/entities/latest_exchange_rates.dart';
import 'package:ezbookkeeping/features/exchange_rates/domain/repositories/exchange_rates_repository.dart';

class GetLatestExchangeRatesUseCase {
  final ExchangeRatesRepository repository;

  GetLatestExchangeRatesUseCase(this.repository);

  Future<Either<Failure, LatestExchangeRates>> call({
    bool forceRefresh = false,
  }) {
    return repository.getLatestExchangeRates(forceRefresh: forceRefresh);
  }
}
