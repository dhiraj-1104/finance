import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Contract for persisting and retrieving the user's selected application locale code.
abstract class LocaleStorage {
  Future<void> saveLocaleCode(String languageCode);
  Future<String?> getLocaleCode();
  Future<void> clearLocale();
}

/// Secure implementation using [FlutterSecureStorage].
class SecureLocaleStorage implements LocaleStorage {
  SecureLocaleStorage({FlutterSecureStorage? secureStorage})
    : _storage =
          secureStorage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  final FlutterSecureStorage _storage;
  static const String _localeKey = 'ezb_app_selected_locale';

  @override
  Future<void> saveLocaleCode(String languageCode) async {
    await _storage.write(key: _localeKey, value: languageCode);
  }

  @override
  Future<String?> getLocaleCode() async {
    return _storage.read(key: _localeKey);
  }

  @override
  Future<void> clearLocale() async {
    await _storage.delete(key: _localeKey);
  }
}
