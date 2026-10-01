import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ezbookkeeping/core/error/exceptions.dart';
import 'package:ezbookkeeping/features/statistics/data/models/statistics_request.dart';

/// Contract for fetching statistics data from the remote backend.
abstract class StatisticsRemoteDataSource {
  Future<Map<String, dynamic>> getStatistics(StatisticsRequest request);
}

/// Implementation of [StatisticsRemoteDataSource] using [Dio].
class StatisticsRemoteDataSourceImpl implements StatisticsRemoteDataSource {
  final Dio _dio;

  const StatisticsRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<Map<String, dynamic>> getStatistics(StatisticsRequest request) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/transactions/statistics.json',
        queryParameters: request.toQueryParameters(),
      );

      return response.data ?? <String, dynamic>{};
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
