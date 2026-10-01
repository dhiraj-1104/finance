import 'dart:math';

/// Utility class for generating standard RFC 4122 Version 4 UUIDs.
class UuidHelper {
  UuidHelper._();

  static final Random _secureRandom = Random.secure();

  /// Generates a random standard RFC 4122 v4 UUID string.
  /// Example format: "9be85957-b77c-802d-a2c7-de14e1bf7513"
  static String generate() {
    final values = List<int>.generate(16, (i) => _secureRandom.nextInt(256));

    // Set version to 4 (0100 in bits 4-7 of byte 6)
    values[6] = (values[6] & 0x0f) | 0x40;
    // Set variant to RFC 4122 (10 in bits 6-7 of byte 8)
    values[8] = (values[8] & 0x3f) | 0x80;

    final hex = values.map((b) => b.toRadixString(16).padLeft(2, '0')).toList();

    return '${hex[0]}${hex[1]}${hex[2]}${hex[3]}-'
        '${hex[4]}${hex[5]}-'
        '${hex[6]}${hex[7]}-'
        '${hex[8]}${hex[9]}-'
        '${hex[10]}${hex[11]}${hex[12]}${hex[13]}${hex[14]}${hex[15]}';
  }
}
