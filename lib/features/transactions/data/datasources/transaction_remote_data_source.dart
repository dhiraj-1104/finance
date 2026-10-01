import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ezbookkeeping/core/error/exceptions.dart';
import 'package:ezbookkeeping/core/network/api_endpoints.dart';
import 'package:ezbookkeeping/features/transactions/data/models/add_transaction_request_model.dart';
import 'package:ezbookkeeping/features/transactions/data/models/add_transaction_response_model.dart';
import 'package:ezbookkeeping/features/transactions/data/models/transaction_details_response_model.dart';
import 'package:ezbookkeeping/features/transactions/data/models/transaction_list_request.dart';
import 'package:ezbookkeeping/features/transactions/data/models/transaction_list_response_model.dart';

/// Contract for fetching and mutating transaction resources via HTTP.
abstract class TransactionRemoteDataSource {
  /// Fetches a paginated list of transactions with filtering parameters.
  Future<TransactionListResponseModel> getTransactions([
    TransactionListRequest? request,
  ]);

  /// Fetches full transaction details by [id].
  Future<TransactionDetailsResponseModel> getTransactionById(String id);

  /// Creates a new transaction with the specified [request] payload.
  Future<AddTransactionResponseModel> addTransaction(
    AddTransactionRequestModel request,
  );
}

/// Implementation of [TransactionRemoteDataSource] using [Dio].
class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final Dio _dio;

  const TransactionRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<TransactionListResponseModel> getTransactions([
    TransactionListRequest? request,
  ]) async {
    try {
      final queryParams = request?.toQueryParameters() ?? {};
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.transactionList,
        queryParameters: queryParams,
      );

      return TransactionListResponseModel.fromJson(response.data);
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

  @override
  Future<TransactionDetailsResponseModel> getTransactionById(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.transactionGet,
        queryParameters: {
          'id': id,
          'with_pictures': true,
          'trim_account': true,
          'trim_category': true,
          'trim_tag': true,
        },
      );

      return TransactionDetailsResponseModel.fromJson(response.data);
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

  @override
  Future<AddTransactionResponseModel> addTransaction(
    AddTransactionRequestModel request,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.addTransaction,
        data: request.toJson(),
      );

      return AddTransactionResponseModel.fromJson(response.data);
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
