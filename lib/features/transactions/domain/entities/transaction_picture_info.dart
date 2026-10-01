import 'package:equatable/equatable.dart';

/// Domain entity representing picture metadata attached to a transaction.
class TransactionPictureInfo extends Equatable {
  const TransactionPictureInfo({
    required this.id,
    this.pictureId,
    this.originalUrl,
    this.thumbnailUrl,
  });

  final String id;
  final String? pictureId;
  final String? originalUrl;
  final String? thumbnailUrl;

  @override
  List<Object?> get props => [id, pictureId, originalUrl, thumbnailUrl];

  @override
  String toString() =>
      'TransactionPictureInfo(id: $id, pictureId: $pictureId, originalUrl: $originalUrl)';
}
