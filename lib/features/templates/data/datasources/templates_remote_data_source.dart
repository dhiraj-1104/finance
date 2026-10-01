import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ezbookkeeping/core/error/exceptions.dart';
import 'package:ezbookkeeping/core/network/api_endpoints.dart';
import 'package:ezbookkeeping/features/templates/data/models/add_transaction_template_request_model.dart';
import 'package:ezbookkeeping/features/templates/data/models/template_list_response_model.dart';
import 'package:ezbookkeeping/features/templates/data/models/transaction_template_model.dart';

/// Contract for fetching and creating transaction templates from the remote backend.
abstract class TemplatesRemoteDataSource {
  Future<TemplateListResponseModel> getTransactionTemplates();

  Future<TransactionTemplateModel> addTransactionTemplate(
    AddTransactionTemplateRequestModel request,
  );
}

/// Implementation of [TemplatesRemoteDataSource] using [Dio].
class TemplatesRemoteDataSourceImpl implements TemplatesRemoteDataSource {
  const TemplatesRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<TemplateListResponseModel> getTransactionTemplates() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.transactionTemplatesList,
      );

      return TemplateListResponseModel.fromJson(response.data);
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
        final message = e.response?.data is Map
            ? (e.response?.data['errorMessage']?.toString() ?? 'Unauthorized')
            : 'Unauthorized';
        throw UnauthorizedException(message, e.response?.statusCode);
      } else if (e.response?.statusCode == HttpStatus.badRequest ||
          e.response?.statusCode == HttpStatus.unprocessableEntity) {
        final message = e.response?.data is Map
            ? (e.response?.data['errorMessage']?.toString() ??
                  'Validation error')
            : 'Validation error';
        throw ValidationException(message, e.response?.statusCode);
      } else {
        final message = e.response?.data is Map
            ? (e.response?.data['errorMessage']?.toString() ?? '')
            : (e.message ?? '');
        throw ServerException(message, e.response?.statusCode);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TransactionTemplateModel> addTransactionTemplate(
    AddTransactionTemplateRequestModel request,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.addTransactionTemplate,
        data: request.toJson(),
      );

      final data = response.data;
      final success = data?['success'] as bool? ?? false;
      if (!success || data?['result'] == null) {
        throw ServerException(
          data?['errorMessage']?.toString() ??
              'Failed to create transaction template.',
          data?['errorCode'] as int? ?? response.statusCode ?? 400,
        );
      }

      return TransactionTemplateModel.fromJson(
        data!['result'] as Map<String, dynamic>,
      );
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
        final message = e.response?.data is Map
            ? (e.response?.data['errorMessage']?.toString() ?? 'Unauthorized')
            : 'Unauthorized';
        throw UnauthorizedException(message, e.response?.statusCode);
      } else if (e.response?.statusCode == HttpStatus.badRequest ||
          e.response?.statusCode == HttpStatus.unprocessableEntity) {
        final message = e.response?.data is Map
            ? (e.response?.data['errorMessage']?.toString() ??
                  'Validation error')
            : 'Validation error';
        throw ValidationException(message, e.response?.statusCode);
      } else {
        final message = e.response?.data is Map
            ? (e.response?.data['errorMessage']?.toString() ?? '')
            : (e.message ?? '');
        throw ServerException(message, e.response?.statusCode);
      }
    } catch (e) {
      rethrow;
    }
  }
}
