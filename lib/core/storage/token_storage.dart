import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Contract for securely storing, retrieving, and removing authentication tokens.
abstract class TokenStorage {
  /// Persists the authentication [token].
  Future<void> saveToken(String token);

  /// Retrieves the persisted authentication token, or `null` if none exists.
  Future<String?> getToken();

  /// Removes the persisted authentication token.
  Future<void> clearToken();
}

/// Production implementation of [TokenStorage] using [FlutterSecureStorage].
class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage({FlutterSecureStorage? secureStorage})
    : _storage =
          secureStorage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  final FlutterSecureStorage _storage;

  static const String _tokenKey = 'ezb_auth_jwt_token';

  @override
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  @override
  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  @override
  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
