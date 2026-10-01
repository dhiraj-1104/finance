import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ezbookkeeping/core/error/exceptions.dart';
import 'package:ezbookkeeping/core/network/api_endpoints.dart';
import 'package:ezbookkeeping/features/tags/data/models/add_transaction_tag_request_model.dart';
import 'package:ezbookkeeping/features/tags/data/models/tag_list_response_model.dart';
import 'package:ezbookkeeping/features/tags/data/models/transaction_tag_model.dart';

/// Contract for fetching and creating transaction tags from the remote backend.
abstract class TagsRemoteDataSource {
  Future<TagListResponseModel> getTransactionTags();

  Future<TransactionTagModel> addTag(AddTransactionTagRequestModel request);
}

/// Implementation of [TagsRemoteDataSource] using [Dio].
class TagsRemoteDataSourceImpl implements TagsRemoteDataSource {
  const TagsRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<TagListResponseModel> getTransactionTags() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.transactionTagsList,
      );

      return TagListResponseModel.fromJson(response.data);
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
  Future<TransactionTagModel> addTag(
    AddTransactionTagRequestModel request,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.addTransactionTag,
        data: request.toJson(),
      );

      final data = response.data;
      final success = data?['success'] as bool? ?? false;
      if (!success || data?['result'] == null) {
        throw ServerException(
          data?['errorMessage']?.toString() ??
              'Failed to create transaction tag.',
          data?['errorCode'] as int? ?? response.statusCode ?? 400,
        );
      }

      return TransactionTagModel.fromJson(
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
