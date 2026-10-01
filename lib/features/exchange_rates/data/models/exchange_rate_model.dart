import 'package:ezbookkeeping/features/exchange_rates/domain/entities/exchange_rate.dart';

class ExchangeRateModel {
  final String currency;
  final double rate;

  const ExchangeRateModel({
    required this.currency,
    required this.rate,
  });

  factory ExchangeRateModel.fromJson(Map<String, dynamic> json) {
    final currency = json['currency']?.toString() ?? '';
    final rawRate = json['rate'];
    final rate = double.tryParse(rawRate?.toString() ?? '') ?? 0.0;
    return ExchangeRateModel(
      currency: currency,
      rate: rate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'rate': rate.toString(),
    };
  }

  ExchangeRate toEntity() {
    return ExchangeRate(
      currency: currency,
      rate: rate,
    );
  }
}
