import 'package:equatable/equatable.dart';

/// Request payload model for `POST /api/v1/transaction/tags/add.json`.
class AddTransactionTagRequestModel extends Equatable {
  const AddTransactionTagRequestModel({required this.name, this.groupId = '0'});

  final String name;
  final String groupId;

  Map<String, dynamic> toJson() {
    return {'name': name, 'groupId': groupId};
  }

  factory AddTransactionTagRequestModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AddTransactionTagRequestModel(name: '', groupId: '0');
    }

    return AddTransactionTagRequestModel(
      name: json['name']?.toString() ?? '',
      groupId: json['groupId']?.toString() ?? '0',
    );
  }

  @override
  List<Object?> get props => [name, groupId];

  @override
  String toString() {
    return 'AddTransactionTagRequestModel(name: $name, groupId: $groupId)';
  }
}

/// Convenience alias matching clean architecture conventions
typedef AddTransactionTagRequest = AddTransactionTagRequestModel;
typedef AddTagRequestModel = AddTransactionTagRequestModel;
