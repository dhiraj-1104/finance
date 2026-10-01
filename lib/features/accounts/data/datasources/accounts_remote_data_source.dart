import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ezbookkeeping/core/error/exceptions.dart';
import 'package:ezbookkeeping/core/network/api_endpoints.dart';
import 'package:ezbookkeeping/features/accounts/data/models/account_list_response_model.dart';
import 'package:ezbookkeeping/features/accounts/data/models/account_model.dart';
import 'package:ezbookkeeping/features/accounts/data/models/account_response_model.dart';
import 'package:ezbookkeeping/features/accounts/data/models/add_account_request_model.dart';

/// Contract for fetching and managing accounts from the remote ezBookkeeping backend.
abstract class AccountsRemoteDataSource {
  /// Fetches the user's accounts list.
  Future<AccountListResponseModel> getAccounts({bool visibleOnly = false});

  /// Creates a new account on the backend.
  Future<AccountModel> addAccount(AddAccountRequestModel request);
}

/// Implementation of [AccountsRemoteDataSource] using [Dio].
class AccountsRemoteDataSourceImpl implements AccountsRemoteDataSource {
  const AccountsRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<AccountListResponseModel> getAccounts({
    bool visibleOnly = false,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.accountList,
        queryParameters: {'visible_only': visibleOnly},
      );

      return AccountListResponseModel.fromJson(response.data);
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
          e.message ?? 'Failed to retrieve accounts',
          e.response?.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AccountModel> addAccount(AddAccountRequestModel request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.addAccount,
        data: request.toJson(),
      );

      final responseModel = AccountResponseModel.fromJson(response.data);

      if (!responseModel.success || responseModel.result == null) {
        throw ServerException('Failed to create account.', response.statusCode);
      }

      return responseModel.result!;
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
          e.message ?? 'Failed to create account',
          e.response?.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
