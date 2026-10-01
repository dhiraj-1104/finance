import 'package:equatable/equatable.dart';
import 'package:ezbookkeeping/features/accounts/data/models/account_model.dart';

/// Top-level API response envelope for single account operations such as `POST /api/v1/accounts/add.json`.
class AccountResponseModel extends Equatable {
  final AccountModel? result;
  final bool success;

  const AccountResponseModel({this.result, required this.success});

  factory AccountResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AccountResponseModel(result: null, success: false);
    }

    return AccountResponseModel(
      result: json['result'] != null
          ? AccountModel.fromJson(json['result'] as Map<String, dynamic>?)
          : null,
      success: json['success'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'result': result?.toJson(), 'success': success};
  }

  @override
  List<Object?> get props => [result, success];

  @override
  String toString() {
    return 'AccountResponseModel(success: $success, result: $result)';
  }
}
