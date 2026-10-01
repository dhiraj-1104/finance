/// Utility for safe, non-floating-point financial amount formatting.
abstract final class MoneyFormatter {
  /// Maps common ISO currency codes to visual symbols.
  static String getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return r'$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'CNY':
      case 'JPY':
        return '¥';
      case 'INR':
        return '₹';
      case 'CAD':
      case 'AUD':
        return r'$';
      default:
        return '$currency ';
    }
  }

  /// Formats a monetary amount string without floating point arithmetic.
  /// Handles both integer cent amounts (e.g. `"22900"` -> `"$ 229.00"`)
  /// and formatted decimal strings (e.g. `"229.00"` -> `"$ 229.00"`).
  static String format(String rawAmount, {String currency = 'USD'}) {
    final symbol = getCurrencySymbol(currency);
    final trimmed = rawAmount.trim();

    if (trimmed.isEmpty || trimmed == '0') {
      return '$symbol 0.00';
    }

    final isNegative = trimmed.startsWith('-');
    final clean = isNegative ? trimmed.substring(1) : trimmed;

    if (clean.contains('.')) {
      final parts = clean.split('.');
      final intPart = _formatThousands(parts[0]);
      final decPart = (parts.length > 1 ? parts[1] : '')
          .padRight(2, '0')
          .substring(0, 2);
      final formatted = '$symbol $intPart.$decPart';
      return isNegative ? '-$formatted' : formatted;
    }

    // Treat as cents (integer sub-units)
    if (clean.length <= 2) {
      final cents = clean.padLeft(2, '0');
      final formatted = '$symbol 0.$cents';
      return isNegative ? '-$formatted' : formatted;
    }

    final intStr = clean.substring(0, clean.length - 2);
    final centsStr = clean.substring(clean.length - 2);
    final formattedInt = _formatThousands(intStr);
    final formatted = '$symbol $formattedInt.$centsStr';

    return isNegative ? '-$formatted' : formatted;
  }

  static String _formatThousands(String str) {
    final chars = str.split('');
    final buffer = StringBuffer();
    for (int i = 0; i < chars.length; i++) {
      if (i > 0 && (chars.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(chars[i]);
    }
    return buffer.toString();
  }
}
