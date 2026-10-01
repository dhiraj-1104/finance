import 'package:equatable/equatable.dart';

/// Domain entity representing an active authentication token / user session.
class Token extends Equatable {
  final String tokenId;
  final int tokenType;
  final String userAgent;
  final int lastSeen;
  final bool isCurrent;

  const Token({
    required this.tokenId,
    required this.tokenType,
    required this.userAgent,
    required this.lastSeen,
    required this.isCurrent,
  });

  @override
  List<Object?> get props => [
        tokenId,
        tokenType,
        userAgent,
        lastSeen,
        isCurrent,
      ];
}
