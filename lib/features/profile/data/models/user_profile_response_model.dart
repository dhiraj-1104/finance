import 'package:ezbookkeeping/features/profile/data/models/user_profile_model.dart';

/// Top-level API response envelope for GET /api/v1/users/profile/get.json.
class UserProfileResponseModel {
  const UserProfileResponseModel({this.result, required this.success});

  final UserProfileModel? result;
  final bool success;

  factory UserProfileResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const UserProfileResponseModel(result: null, success: false);
    }

    return UserProfileResponseModel(
      result: json['result'] != null
          ? UserProfileModel.fromJson(json['result'] as Map<String, dynamic>?)
          : null,
      success: json['success'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'result': result?.toJson(), 'success': success};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfileResponseModel &&
        other.result == result &&
        other.success == success;
  }

  @override
  int get hashCode => Object.hash(result, success);

  @override
  String toString() {
    return 'UserProfileResponseModel(success: $success, result: $result)';
  }
}
