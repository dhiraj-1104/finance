import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ezbookkeeping/core/error/exceptions.dart';
import 'package:ezbookkeeping/core/network/api_endpoints.dart';
import 'package:ezbookkeeping/features/home/data/models/transaction_amounts_response_model.dart';
import 'package:ezbookkeeping/features/home/data/utils/transaction_time_range_builder.dart';

/// Abstract contract for fetching transaction amounts from the remote data source.
abstract class HomeRemoteDataSource {
  /// Fetches monthly transaction overview amounts.
  Future<TransactionAmountsResponseModel> getTransactionAmounts({
    int firstDayOfWeek = 0,
    DateTime? now,
    bool useTransactionTimezone = false,
  });
}

/// Concrete implementation of [HomeRemoteDataSource] using [Dio].
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio _dio;

  HomeRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<TransactionAmountsResponseModel> getTransactionAmounts({
    int firstDayOfWeek = 0,
    DateTime? now,
    bool useTransactionTimezone = false,
  }) async {
    try {
      final query = TransactionTimeRangeBuilder.buildAmountsQuery(
        now: now,
        firstDayOfWeek: firstDayOfWeek,
      );

      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.transactionAmounts,
        queryParameters: {
          'query': query,
          'use_transaction_timezone': useTransactionTimezone,
        },
      );

      final data = response.data;
      if (data == null) {
        throw const ServerException('Empty response data from server.');
      }

      return TransactionAmountsResponseModel.fromJson(data);
    } on SocketException {
      throw const NoInternetConnectionException();
    } on TimeoutException {
      throw const NetworkException();
    } on DioException catch (e) {
      if (e.error is SocketException ||
          e.type == DioExceptionType.connectionError) {
        throw const NoInternetConnectionException();
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      } else if (e.response?.statusCode == HttpStatus.unauthorized ||
          e.response?.statusCode == HttpStatus.forbidden) {
        throw UnauthorizedException(
          e.message ?? 'Unauthorized',
          e.response?.statusCode,
        );
      } else if (e.response?.statusCode == HttpStatus.badRequest ||
          e.response?.statusCode == HttpStatus.unprocessableEntity) {
        throw ValidationException(
          e.message ?? 'Validation error',
          e.response?.statusCode,
        );
      } else {
        throw ServerException(
          e.message ?? 'Server error',
          e.response?.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
