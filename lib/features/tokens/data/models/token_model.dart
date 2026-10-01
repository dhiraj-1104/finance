import 'package:equatable/equatable.dart';
import '../../domain/entities/token.dart';

/// Data Transfer Object for authentication token / session returned by the API.
class TokenModel extends Equatable {
  final String tokenId;
  final int tokenType;
  final String userAgent;
  final int lastSeen;
  final bool isCurrent;

  const TokenModel({
    required this.tokenId,
    required this.tokenType,
    required this.userAgent,
    required this.lastSeen,
    required this.isCurrent,
  });

  factory TokenModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TokenModel(
        tokenId: '',
        tokenType: 1,
        userAgent: '',
        lastSeen: 0,
        isCurrent: false,
      );
    }

    final rawLastSeen = json['lastSeen'];
    final int parsedLastSeen;
    if (rawLastSeen is num) {
      parsedLastSeen = rawLastSeen.toInt();
    } else {
      parsedLastSeen = int.tryParse(rawLastSeen?.toString() ?? '') ?? 0;
    }

    final rawTokenType = json['tokenType'];
    final int parsedTokenType;
    if (rawTokenType is num) {
      parsedTokenType = rawTokenType.toInt();
    } else {
      parsedTokenType = int.tryParse(rawTokenType?.toString() ?? '') ?? 1;
    }

    return TokenModel(
      tokenId: json['tokenId']?.toString() ?? '',
      tokenType: parsedTokenType,
      userAgent: json['userAgent']?.toString() ?? '',
      lastSeen: parsedLastSeen,
      isCurrent: json['isCurrent'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tokenId': tokenId,
      'tokenType': tokenType,
      'userAgent': userAgent,
      'lastSeen': lastSeen,
      'isCurrent': isCurrent,
    };
  }

  Token toEntity() {
    return Token(
      tokenId: tokenId,
      tokenType: tokenType,
      userAgent: userAgent,
      lastSeen: lastSeen,
      isCurrent: isCurrent,
    );
  }

  @override
  List<Object?> get props => [
        tokenId,
        tokenType,
        userAgent,
        lastSeen,
        isCurrent,
      ];
}

/// Model wrapper for `GET /api/v1/tokens/list.json` response.
class TokenListResponseModel extends Equatable {
  final bool success;
  final List<TokenModel> result;
  final String? errorMessage;
  final int? errorCode;

  const TokenListResponseModel({
    required this.success,
    required this.result,
    this.errorMessage,
    this.errorCode,
  });

  List<TokenModel> get tokens => result;

  factory TokenListResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TokenListResponseModel(
        success: false,
        result: [],
        errorMessage: 'Empty response',
      );
    }

    final success = json['success'] as bool? ?? false;
    final rawList = json['result'] as List<dynamic>?;
    final List<TokenModel> result = rawList != null
        ? rawList
            .whereType<Map<String, dynamic>>()
            .map(TokenModel.fromJson)
            .toList()
        : const [];

    return TokenListResponseModel(
      success: success,
      result: result,
      errorMessage: json['errorMessage']?.toString(),
      errorCode: json['errorCode'] as int?,
    );
  }

  @override
  List<Object?> get props => [success, result, errorMessage, errorCode];
}
