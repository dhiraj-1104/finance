import 'package:equatable/equatable.dart';

/// Represents a transaction tag entity in ezBookkeeping.
class TagItem extends Equatable {
  final String id;
  final String name;
  final String groupId;
  final int displayOrder;
  final bool hidden;

  const TagItem({
    required this.id,
    required this.name,
    this.groupId = '0',
    this.displayOrder = 0,
    this.hidden = false,
  });

  /// Convenience getter for backward compatibility with UI components expecting `title`
  String get title => name;

  /// Convenience getter for backward compatibility with UI components expecting `isHidden`
  bool get isHidden => hidden;

  TagItem copyWith({
    String? id,
    String? name,
    String? title,
    String? groupId,
    int? displayOrder,
    bool? hidden,
    bool? isHidden,
  }) {
    return TagItem(
      id: id ?? this.id,
      name: name ?? title ?? this.name,
      groupId: groupId ?? this.groupId,
      displayOrder: displayOrder ?? this.displayOrder,
      hidden: hidden ?? isHidden ?? this.hidden,
    );
  }

  @override
  List<Object?> get props => [id, name, groupId, displayOrder, hidden];
}

/// Represents a transaction tag group in ezBookkeeping.
class TagGroup extends Equatable {
  final String id;
  final String name;

  const TagGroup({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
