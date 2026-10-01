import 'package:equatable/equatable.dart';
import 'package:ezbookkeeping/features/tags/models/tag_item.dart';

/// Data transfer object for a transaction tag from the backend API.
class TransactionTagModel extends Equatable {
  const TransactionTagModel({
    required this.id,
    required this.name,
    this.groupId = '0',
    this.displayOrder = 0,
    this.hidden = false,
  });

  final String id;
  final String name;
  final String groupId;
  final int displayOrder;
  final bool hidden;

  factory TransactionTagModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TransactionTagModel(id: '', name: '');
    }

    final rawDisplayOrder = json['displayOrder'];
    int parsedOrder = 0;
    if (rawDisplayOrder is int) {
      parsedOrder = rawDisplayOrder;
    } else if (rawDisplayOrder != null) {
      parsedOrder = int.tryParse(rawDisplayOrder.toString()) ?? 0;
    }

    return TransactionTagModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      groupId: json['groupId']?.toString() ?? '0',
      displayOrder: parsedOrder,
      hidden: json['hidden'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'groupId': groupId,
      'displayOrder': displayOrder,
      'hidden': hidden,
    };
  }

  TagItem toEntity() {
    return TagItem(
      id: id,
      name: name,
      groupId: groupId,
      displayOrder: displayOrder,
      hidden: hidden,
    );
  }

  @override
  List<Object?> get props => [id, name, groupId, displayOrder, hidden];
}

/// Convenience alias
typedef TagModel = TransactionTagModel;
