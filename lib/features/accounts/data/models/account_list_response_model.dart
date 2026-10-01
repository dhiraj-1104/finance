import 'package:ezbookkeeping/features/accounts/data/models/account_model.dart';

/// Top-level API response envelope for account list queries.
class AccountListResponseModel {
  const AccountListResponseModel({
    this.result = const [],
    required this.success,
  });

  final List<AccountModel> result;
  final bool success;

  factory AccountListResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AccountListResponseModel(result: [], success: false);
    }

    final rawResult = json['result'] as List<dynamic>?;
    final List<AccountModel> items = rawResult != null
        ? rawResult
              .whereType<Map<String, dynamic>>()
              .map(AccountModel.fromJson)
              .toList()
        : const [];

    return AccountListResponseModel(
      result: items,
      success: json['success'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result': result.map((e) => e.toJson()).toList(),
      'success': success,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AccountListResponseModel &&
        other.success == success &&
        _listEquals(other.result, result);
  }

  @override
  int get hashCode => Object.hash(result, success);

  @override
  String toString() {
    return 'AccountListResponseModel(success: $success, resultCount: ${result.length})';
  }

  static bool _listEquals(List<AccountModel> a, List<AccountModel> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
