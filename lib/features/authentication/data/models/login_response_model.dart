import 'package:ezbookkeeping/features/authentication/data/models/login_result_model.dart';

/// Top-level model representing the complete login API response envelope.
class LoginResponseModel {
  const LoginResponseModel({this.result, required this.success});

  /// The inner payload if the authentication succeeded.
  final LoginResultModel? result;

  /// Indicates if the API request was successful.
  final bool success;

  factory LoginResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const LoginResponseModel(result: null, success: false);
    }

    return LoginResponseModel(
      result: json['result'] != null
          ? LoginResultModel.fromJson(json['result'] as Map<String, dynamic>?)
          : null,
      success: json['success'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'result': result?.toJson(), 'success': success};
  }

  LoginResponseModel copyWith({LoginResultModel? result, bool? success}) {
    return LoginResponseModel(
      result: result ?? this.result,
      success: success ?? this.success,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginResponseModel &&
        other.result == result &&
        other.success == success;
  }

  @override
  int get hashCode {
    return Object.hash(result, success);
  }

  @override
  String toString() {
    return 'LoginResponseModel(success: $success, result: $result)';
  }
}
