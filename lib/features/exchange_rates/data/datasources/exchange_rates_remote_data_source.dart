import 'package:dio/dio.dart';
import 'package:ezbookkeeping/core/error/exceptions.dart';
import 'package:ezbookkeeping/core/network/api_endpoints.dart';
import 'package:ezbookkeeping/features/exchange_rates/data/models/latest_exchange_rates_model.dart';

abstract class ExchangeRatesRemoteDataSource {
  Future<LatestExchangeRatesModel> getLatestExchangeRates();
}

class ExchangeRatesRemoteDataSourceImpl
    implements ExchangeRatesRemoteDataSource {
  final Dio dio;

  ExchangeRatesRemoteDataSourceImpl({required this.dio});

  @override
  Future<LatestExchangeRatesModel> getLatestExchangeRates() async {
    try {
      final response = await dio.get(ApiEndpoints.exchangeRatesLatest);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          if (data['success'] == true || data.containsKey('result')) {
            return LatestExchangeRatesModel.fromJson(data);
          } else {
            final errorMessage = data['message']?.toString() ??
                'Failed to load latest exchange rates';
            throw ServerException(errorMessage, response.statusCode ?? 500);
          }
        }
        throw const ServerException('Invalid response format', 500);
      } else {
        throw ServerException(
          'Server returned code ${response.statusCode}',
          response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      final message = e.response?.data is Map<String, dynamic>
          ? e.response?.data['message']?.toString() ?? e.message
          : e.message;
      throw ServerException(
        message ?? 'Network error occurred',
        e.response?.statusCode ?? 500,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString(), 500);
    }
  }
}
