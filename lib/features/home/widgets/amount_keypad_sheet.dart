import 'package:flutter/material.dart';

/// Custom bottom-sheet numeric keypad & calculator matching the ezBookkeeping UI mockup.
class AmountKeypadSheet extends StatefulWidget {
  final double initialAmount;
  final ValueChanged<double>? onAmountChanged;
  final ValueChanged<double> onConfirm;

  const AmountKeypadSheet({
    super.key,
    required this.initialAmount,
    this.onAmountChanged,
    required this.onConfirm,
  });

  /// Helper static method to open the bottom sheet modal.
  static Future<double?> show(
    BuildContext context, {
    required double initialAmount,
    ValueChanged<double>? onAmountChanged,
    required ValueChanged<double> onConfirm,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1E1E22) : const Color(0xFFECEEF2);

    return showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return AmountKeypadSheet(
          initialAmount: initialAmount,
          onAmountChanged: onAmountChanged,
          onConfirm: onConfirm,
        );
      },
    );
  }

  @override
  State<AmountKeypadSheet> createState() => _AmountKeypadSheetState();
}

class _AmountKeypadSheetState extends State<AmountKeypadSheet> {
  late String _expression;

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount > 0) {
      // Format cleanly without trailing .00 if whole number or preserve 2 decimal places
      final str = widget.initialAmount.toStringAsFixed(2);
      _expression = str.endsWith('.00')
          ? widget.initialAmount.toInt().toString()
          : str.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    } else {
      _expression = '0';
    }
  }

  void _onDigit(String digit) {
    setState(() {
      if (_expression == '0') {
        _expression = digit;
      } else {
        _expression += digit;
      }
      _notifyChange();
    });
  }

  void _onDot() {
    setState(() {
      // Find the last number token in the expression
      final lastOpIndex = _expression.lastIndexOf(RegExp(r'[+\u2212\u00D7\-]'));
      final currentNumber = lastOpIndex >= 0
          ? _expression.substring(lastOpIndex + 1)
          : _expression;

      if (!currentNumber.contains('.')) {
        if (currentNumber.isEmpty) {
          _expression += '0.';
        } else {
          _expression += '.';
        }
        _notifyChange();
      }
    });
  }

  void _onOperator(String op) {
    setState(() {
      if (_expression.isEmpty) {
        _expression = '0$op';
        return;
      }

      final lastChar = _expression[_expression.length - 1];
      if (lastChar == '+' ||
          lastChar == '\u2212' ||
          lastChar == '\u00D7' ||
          lastChar == '-' ||
          lastChar == '*' ||
          lastChar == '.') {
        // Replace previous operator or trailing dot
        _expression = _expression.substring(0, _expression.length - 1) + op;
      } else {
        // Check if there is already an operation to evaluate first
        final intermediate = _evaluateExpression(_expression);
        if (_hasPendingOperation(_expression)) {
          final formatted = intermediate
              .toStringAsFixed(2)
              .replaceAll(RegExp(r'0+$'), '')
              .replaceAll(RegExp(r'\.$'), '');
          _expression = '$formatted$op';
        } else {
          _expression += op;
        }
      }
      _notifyChange();
    });
  }

  bool _hasPendingOperation(String expr) {
    final clean = expr.replaceAll('\u2212', '-').replaceAll('\u00D7', '*');
    final match = RegExp(r'\d+[+\-*]\d+').hasMatch(clean);
    return match;
  }

  void _onBackspace() {
    setState(() {
      if (_expression.length > 1) {
        _expression = _expression.substring(0, _expression.length - 1);
      } else {
        _expression = '0';
      }
      _notifyChange();
    });
  }

  void _onClear() {
    setState(() {
      _expression = '0';
      _notifyChange();
    });
  }

  double _evaluateExpression(String expr) {
    try {
      final sanitized = expr
          .replaceAll('\u2212', '-')
          .replaceAll('\u00D7', '*')
          .trim();

      if (sanitized.isEmpty) return 0.0;

      // Simple tokenizer for binary arithmetic (+, -, *)
      final reg = RegExp(r'(\d+\.?\d*|\+|\-|\*)');
      final matches = reg
          .allMatches(sanitized)
          .map((m) => m.group(0)!)
          .toList();

      if (matches.isEmpty) return 0.0;

      // Evaluate left to right
      double total = double.tryParse(matches[0]) ?? 0.0;
      int i = 1;
      while (i < matches.length) {
        final op = matches[i];
        if (i + 1 < matches.length) {
          final nextVal = double.tryParse(matches[i + 1]) ?? 0.0;
          if (op == '+') total += nextVal;
          if (op == '-') total -= nextVal;
          if (op == '*') total *= nextVal;
          i += 2;
        } else {
          break;
        }
      }
      return total < 0 ? 0.0 : total;
    } catch (_) {
      return 0.0;
    }
  }

  void _notifyChange() {
    final val = _evaluateExpression(_expression);
    widget.onAmountChanged?.call(val);
  }

  void _onConfirm() {
    final finalAmount = _evaluateExpression(_expression);
    widget.onConfirm(finalAmount);
    Navigator.of(context).pop(finalAmount);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gridLineColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFDCDFE5);
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    const orangeButtonColor = Color(0xFFD27C4B);

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 12),
            child: Container(
              width: 38,
              height: 4.5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white30 : const Color(0xFF6B7280),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // 4x4 Keypad Grid
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: gridLineColor, width: 1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Row 1: 7 | 8 | 9 | ×
                _buildRow(
                  children: [
                    _buildKey(
                      label: '7',
                      textColor: textColor,
                      gridLineColor: gridLineColor,
                      onTap: () => _onDigit('7'),
                    ),
                    _buildKey(
                      label: '8',
                      textColor: textColor,
                      gridLineColor: gridLineColor,
                      onTap: () => _onDigit('8'),
                    ),
                    _buildKey(
                      label: '9',
                      textColor: textColor,
                      gridLineColor: gridLineColor,
                      onTap: () => _onDigit('9'),
                    ),
                    _buildKey(
                      label: '\u00D7',
                      textColor: textColor,
                      gridLineColor: gridLineColor,
                      isLastInRow: true,
                      onTap: () => _onOperator('\u00D7'),
                    ),
                  ],
                ),

                // Row 2: 4 | 5 | 6 | −
                _buildRow(
                  children: [
                    _buildKey(
                      label: '4',
                      textColor: textColor,
                      gridLineColor: gridLineColor,
                      onTap: () => _onDigit('4'),
                    ),
                    _buildKey(
                      label: '5',
                      textColor: textColor,
                      gridLineColor: gridLineColor,
                      onTap: () => _onDigit('5'),
                    ),
                    _buildKey(
                      label: '6',
                      textColor: textColor,
                      gridLineColor: gridLineColor,
                      onTap: () => _onDigit('6'),
                    ),
                    _buildKey(
                      label: '\u2212',
                      textColor: textColor,
                      gridLineColor: gridLineColor,
                      isLastInRow: true,
                      onTap: () => _onOperator('\u2212'),
                    ),
                  ],
                ),

                // Row 3: 1 | 2 | 3 | +
                _buildRow(
                  children: [
                    _buildKey(
                      label: '1',
                      textColor: textColor,
                      gridLineColor: gridLineColor,
                      onTap: () => _onDigit('1'),
                    ),
                    _buildKey(
                      label: '2',
                      textColor: textColor,
                      gridLineColor: gridLineColor,
                      onTap: () => _onDigit('2'),
                    ),
                    _buildKey(
                      label: '3',
                      textColor: textColor,
                      gridLineColor: gridLineColor,
                      onTap: () => _onDigit('3'),
                    ),
                    _buildKey(
                      label: '+',
                      textColor: textColor,
                      gridLineColor: gridLineColor,
                      isLastInRow: true,
                      onTap: () => _onOperator('+'),
                    ),
                  ],
                ),

                // Row 4: . | 0 | ⌫ | OK
                _buildRow(
                  children: [
                    _buildKey(
                      label: '.',
                      textColor: textColor,
                      gridLineColor: gridLineColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      onTap: _onDot,
                    ),
                    _buildKey(
                      label: '0',
                      textColor: textColor,
                      gridLineColor: gridLineColor,
                      onTap: () => _onDigit('0'),
                    ),
                    _buildKey(
                      icon: Icons.backspace_outlined,
                      textColor: textColor,
                      gridLineColor: gridLineColor,
                      onTap: _onBackspace,
                      onLongPress: _onClear,
                    ),
                    _buildKey(
                      label: 'OK',
                      textColor: Colors.white,
                      backgroundColor: orangeButtonColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      gridLineColor: gridLineColor,
                      isLastInRow: true,
                      onTap: _onConfirm,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow({required List<Widget> children}) {
    return SizedBox(
      height: 62,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildKey({
    String? label,
    IconData? icon,
    required Color textColor,
    Color? backgroundColor,
    double fontSize = 26,
    FontWeight fontWeight = FontWeight.w400,
    required Color gridLineColor,
    bool isLastInRow = false,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            right: isLastInRow
                ? BorderSide.none
                : BorderSide(color: gridLineColor, width: 0.75),
            bottom: BorderSide(color: gridLineColor, width: 0.75),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            child: Center(
              child: icon != null
                  ? Icon(icon, size: 25, color: textColor)
                  : Text(
                      label ?? '',
                      style: TextStyle(
                        color: textColor,
                        fontSize: fontSize,
                        fontWeight: fontWeight,
                        letterSpacing: -0.2,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
