import 'package:ezbookkeeping/features/exchange_rates/data/models/exchange_rate_model.dart';
import 'package:ezbookkeeping/features/exchange_rates/domain/entities/latest_exchange_rates.dart';

class LatestExchangeRatesModel {
  final String dataSource;
  final String referenceUrl;
  final int updateTime;
  final String baseCurrency;
  final List<ExchangeRateModel> exchangeRates;

  const LatestExchangeRatesModel({
    required this.dataSource,
    required this.referenceUrl,
    required this.updateTime,
    required this.baseCurrency,
    required this.exchangeRates,
  });

  factory LatestExchangeRatesModel.fromJson(Map<String, dynamic> json) {
    final result = json['result'] is Map<String, dynamic>
        ? json['result'] as Map<String, dynamic>
        : json;

    final ratesList = result['exchangeRates'] as List<dynamic>? ?? [];
    final exchangeRates = ratesList
        .whereType<Map<String, dynamic>>()
        .map((e) => ExchangeRateModel.fromJson(e))
        .where((model) => model.currency.isNotEmpty && model.rate > 0)
        .toList();

    return LatestExchangeRatesModel(
      dataSource: result['dataSource']?.toString() ?? '',
      referenceUrl: result['referenceUrl']?.toString() ?? '',
      updateTime: (result['updateTime'] as num?)?.toInt() ?? 0,
      baseCurrency: result['baseCurrency']?.toString() ?? 'EUR',
      exchangeRates: exchangeRates,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dataSource': dataSource,
      'referenceUrl': referenceUrl,
      'updateTime': updateTime,
      'baseCurrency': baseCurrency,
      'exchangeRates': exchangeRates.map((e) => e.toJson()).toList(),
    };
  }

  LatestExchangeRates toEntity() {
    return LatestExchangeRates(
      dataSource: dataSource,
      referenceUrl: referenceUrl,
      updateTime: DateTime.fromMillisecondsSinceEpoch(updateTime * 1000),
      baseCurrency: baseCurrency,
      exchangeRates: exchangeRates.map((e) => e.toEntity()).toList(),
    );
  }
}
