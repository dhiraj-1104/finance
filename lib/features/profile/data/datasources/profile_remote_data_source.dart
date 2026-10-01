import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ezbookkeeping/core/error/exceptions.dart';
import 'package:ezbookkeeping/core/network/api_endpoints.dart';
import 'package:ezbookkeeping/features/profile/data/models/update_user_profile_request_model.dart';
import 'package:ezbookkeeping/features/profile/data/models/user_profile_response_model.dart';

/// Contract for fetching and updating authenticated user profile resources via HTTP.
abstract class ProfileRemoteDataSource {
  /// Fetches the authenticated user's profile details.
  Future<UserProfileResponseModel> getUserProfile();

  /// Updates the authenticated user's profile details and preferences.
  Future<UserProfileResponseModel> updateUserProfile(
    UpdateUserProfileRequestModel request,
  );
}

/// Implementation of [ProfileRemoteDataSource] using [Dio].
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio _dio;

  const ProfileRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<UserProfileResponseModel> getUserProfile() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.userProfile,
      );

      return UserProfileResponseModel.fromJson(response.data);
    } on SocketException {
      throw const NoInternetConnectionException();
    } on TimeoutException {
      throw const NetworkException();
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserProfileResponseModel> updateUserProfile(
    UpdateUserProfileRequestModel request,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.userProfileUpdate,
        data: request.toJson(),
      );

      return UserProfileResponseModel.fromJson(response.data);
    } on SocketException {
      throw const NoInternetConnectionException();
    } on TimeoutException {
      throw const NetworkException();
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      rethrow;
    }
  }

  AppException _handleDioException(DioException e) {
    if (e.error is SocketException ||
        e.type == DioExceptionType.connectionError) {
      return const NoInternetConnectionException();
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkException();
    } else if (e.response?.statusCode == HttpStatus.unauthorized ||
        e.response?.statusCode == HttpStatus.forbidden) {
      final message = e.response?.data is Map
          ? (e.response?.data['errorMessage']?.toString() ??
                'Unauthorized or session expired. Please log in again.')
          : 'Unauthorized or session expired. Please log in again.';
      return UnauthorizedException(message, e.response?.statusCode);
    } else if (e.response?.statusCode == HttpStatus.badRequest ||
        e.response?.statusCode == HttpStatus.unprocessableEntity) {
      final message = e.response?.data is Map
          ? (e.response?.data['errorMessage']?.toString() ?? 'Bad request.')
          : 'Bad request.';
      return BadRequestException(message, e.response?.statusCode);
    } else {
      return ServerException(
        e.message ?? 'Server error',
        e.response?.statusCode,
      );
    }
  }
}
