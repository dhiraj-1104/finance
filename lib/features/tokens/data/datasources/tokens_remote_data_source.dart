import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ezbookkeeping/core/error/exceptions.dart';
import 'package:ezbookkeeping/core/network/api_endpoints.dart';
import '../models/token_model.dart';

/// Contract for fetching tokens/sessions from the remote backend.
abstract class TokensRemoteDataSource {
  Future<List<TokenModel>> getTokens();
}

/// Implementation of [TokensRemoteDataSource] using [Dio].
class TokensRemoteDataSourceImpl implements TokensRemoteDataSource {
  const TokensRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<List<TokenModel>> getTokens() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.tokensList,
      );

      final data = response.data;
      final success = data?['success'] as bool? ?? false;
      if (!success) {
        throw ServerException(
          data?['errorMessage']?.toString() ?? 'Failed to retrieve tokens list.',
          data?['errorCode'] as int? ?? response.statusCode ?? 400,
        );
      }

      final listResponse = TokenListResponseModel.fromJson(data);
      return listResponse.tokens;
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
            ? (e.response?.data['errorMessage']?.toString() ?? 'Validation error')
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
