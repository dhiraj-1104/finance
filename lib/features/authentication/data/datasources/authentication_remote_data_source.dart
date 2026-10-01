import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ezbookkeeping/core/error/exceptions.dart';
import 'package:ezbookkeeping/core/network/api_endpoints.dart';
import 'package:ezbookkeeping/core/network/interceptors/auth_interceptor.dart';
import 'package:ezbookkeeping/features/authentication/data/models/login_request_model.dart';
import 'package:ezbookkeeping/features/authentication/data/models/login_response_model.dart';
import 'package:ezbookkeeping/features/authentication/data/models/login_result_model.dart';
import 'package:ezbookkeeping/features/authentication/data/models/register_request_model.dart';

/// Contract for remote authentication API interactions.
abstract class AuthenticationRemoteDataSource {
  /// Calls the authorization endpoint with login credentials.
  Future<LoginResultModel?> login(LoginRequestModel request);

  /// Calls the register endpoint with registration details.
  Future<LoginResponseModel> register(RegisterRequestModel request);

  /// Calls the logout endpoint to invalidate the current session token.
  Future<bool> logout();
}

/// Implementation of [AuthenticationRemoteDataSource] using [Dio].
class AuthenticationRemoteDataSourceImpl
    implements AuthenticationRemoteDataSource {
  final Dio _dio;

  AuthenticationRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<LoginResultModel?> login(LoginRequestModel request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.authorize,
        data: request.toJson(),
        options: Options(extra: {AuthInterceptor.requiresAuthKey: false}),
      );

      if (response.statusCode == HttpStatus.ok && response.data != null) {
        return LoginResultModel.fromJson(response.data?['result']);
      }
      return null;
    } on SocketException {
      throw const NoInternetConnectionException();
    } on TimeoutException {
      throw const NetworkException();
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<LoginResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.register,
        data: request.toJson(),
        options: Options(extra: {AuthInterceptor.requiresAuthKey: false}),
      );

      return LoginResponseModel.fromJson(response.data);
    } on SocketException {
      throw const NoInternetConnectionException();
    } on TimeoutException {
      throw const NetworkException();
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      // final response = await _dio.post<Map<String, dynamic>>(
      //   ApiEndpoints.logout,
      // );
      // final data = response.data;
      // if (data != null && data['success'] == true) {
      //   return data['result'] == true;
      // }
      return true;
    } on SocketException {
      throw const NoInternetConnectionException();
    } on TimeoutException {
      throw const NetworkException();
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  Never _handleDioError(DioException e) {
    if (e.error is SocketException ||
        e.type == DioExceptionType.connectionError) {
      throw const NoInternetConnectionException();
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw const NetworkException();
    } else if (e.response?.statusCode == HttpStatus.unauthorized) {
      final message = e.response?.data is Map
          ? (e.response?.data['errorMessage']?.toString() ??
                'Unauthorized or session expired. Please log in again.')
          : 'Unauthorized or session expired. Please log in again.';
      throw UnauthorizedException(message, e.response?.statusCode);
    } else if (e.response?.statusCode == HttpStatus.internalServerError) {
      throw const ServerException();
    } else if (e.response?.statusCode == HttpStatus.badRequest) {
      final message = e.response?.data is Map
          ? (e.response?.data['errorMessage']?.toString() ?? 'Bad request.')
          : 'Bad request.';
      throw BadRequestException(message, e.response?.statusCode);
    } else {
      throw ServerException(
        e.message ?? 'Server error',
        e.response?.statusCode,
      );
    }
  }
}
