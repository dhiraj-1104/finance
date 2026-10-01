import 'package:ezbookkeeping/features/transactions/domain/entities/transaction_picture_info.dart';

/// Data model representing transaction picture information.
class TransactionPictureModel {
  const TransactionPictureModel({
    required this.id,
    this.pictureId,
    this.originalUrl,
    this.thumbnailUrl,
  });

  final String id;
  final String? pictureId;
  final String? originalUrl;
  final String? thumbnailUrl;

  factory TransactionPictureModel.fromJson(dynamic json) {
    if (json == null) {
      return const TransactionPictureModel(id: '');
    }
    if (json is String) {
      return TransactionPictureModel(id: json);
    }
    if (json is Map<String, dynamic>) {
      return TransactionPictureModel(
        id: json['id']?.toString() ?? json['pictureId']?.toString() ?? '',
        pictureId: json['pictureId']?.toString(),
        originalUrl: json['originalUrl']?.toString() ?? json['url']?.toString(),
        thumbnailUrl:
            json['thumbnailUrl']?.toString() ?? json['thumbUrl']?.toString(),
      );
    }
    return const TransactionPictureModel(id: '');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (pictureId != null) 'pictureId': pictureId,
      if (originalUrl != null) 'originalUrl': originalUrl,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
    };
  }

  TransactionPictureInfo toEntity() {
    return TransactionPictureInfo(
      id: id,
      pictureId: pictureId,
      originalUrl: originalUrl,
      thumbnailUrl: thumbnailUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionPictureModel &&
        other.id == id &&
        other.pictureId == pictureId &&
        other.originalUrl == originalUrl &&
        other.thumbnailUrl == thumbnailUrl;
  }

  @override
  int get hashCode => Object.hash(id, pictureId, originalUrl, thumbnailUrl);
}
