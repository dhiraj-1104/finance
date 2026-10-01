import 'package:equatable/equatable.dart';
import 'package:ezbookkeeping/features/exchange_rates/domain/entities/exchange_rate.dart';

/// Domain entity representing the latest exchange rates with metadata.
class LatestExchangeRates extends Equatable {
  final String dataSource;
  final String referenceUrl;
  final DateTime updateTime;
  final String baseCurrency;
  final List<ExchangeRate> exchangeRates;

  const LatestExchangeRates({
    required this.dataSource,
    required this.referenceUrl,
    required this.updateTime,
    required this.baseCurrency,
    required this.exchangeRates,
  });

  /// Map of currency code (uppercase) to rate against [baseCurrency].
  Map<String, double> get ratesByCurrency {
    final map = <String, double>{};
    for (final rate in exchangeRates) {
      if (rate.currency.isNotEmpty && rate.rate > 0) {
        map[rate.currency.toUpperCase()] = rate.rate;
      }
    }
    // Guarantee base currency is present with rate 1.0
    if (baseCurrency.isNotEmpty && !map.containsKey(baseCurrency.toUpperCase())) {
      map[baseCurrency.toUpperCase()] = 1.0;
    }
    return map;
  }

  @override
  List<Object?> get props => [
        dataSource,
        referenceUrl,
        updateTime,
        baseCurrency,
        exchangeRates,
      ];
}
