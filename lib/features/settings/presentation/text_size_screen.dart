import 'package:ezbookkeeping/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TextSizeScreen extends StatefulWidget {
  final String initialSize;

  const TextSizeScreen({super.key, this.initialSize = 'Default'});

  @override
  State<TextSizeScreen> createState() => _TextSizeScreenState();
}

class _TextSizeScreenState extends State<TextSizeScreen> {
  static const Color _copperAccent = Color(0xFFC86D3B);
  static const Color _incomeRed = Color(0xFFEF4444);
  static const Color _expenseTeal = Color(0xFF0D9488);

  late double _sliderValue;

  final List<String> _sizeLabels = [
    'Small',
    'Default',
    'Medium',
    'Large',
    'Extra Large',
  ];

  final List<double> _scaleFactors = [0.88, 1.0, 1.12, 1.25, 1.38];

  @override
  void initState() {
    super.initState();
    final idx = _sizeLabels.indexOf(widget.initialSize);
    _sliderValue = idx != -1 ? idx.toDouble() : 1.0;
  }

  String get _currentLabel => _sizeLabels[_sliderValue.round()];
  double get _currentScale => _scaleFactors[_sliderValue.round()];

  void _saveTextSize() {
    final result = _currentLabel;
    final themeController = ThemeScope.maybeOf(context);
    if (themeController != null) {
      themeController.setTextScaleFactor(_currentScale);
    }
    final router = GoRouter.maybeOf(context);
    if (router != null && router.canPop()) {
      router.pop(result);
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark
        ? const Color(0xFF0F0F11)
        : const Color(0xFFEFF1F5);
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subtextColor = isDark ? Colors.white54 : const Color(0xFF8E8E93);
    final chevronColor = isDark
        ? const Color(0xFF636366)
        : const Color(0xFFC7C7CC);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.05);

    final pillShadow = isDark
        ? null
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ];

    final cardShadow = [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
        blurRadius: 12,
        offset: const Offset(0, 2),
      ),
    ];

    final scale = _currentScale;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Scaffold(
        backgroundColor: scaffoldBg,
        body: SafeArea(
          child: Column(
            children: [
              // Top App Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Row(
                      children: [
                        // Back Button (<)
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: cardBg,
                            shape: BoxShape.circle,
                            boxShadow: pillShadow,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () {
                                final router = GoRouter.maybeOf(context);
                                if (router != null && router.canPop()) {
                                  router.pop();
                                } else if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                              },
                              child: Center(
                                child: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: textColor,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Title "Text Size"
                        Expanded(
                          child: Text(
                            'Text Size',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),

                        // Save Check Button (✓)
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: cardBg,
                            shape: BoxShape.circle,
                            boxShadow: pillShadow,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: _saveTextSize,
                              child: Center(
                                child: Icon(
                                  Icons.check_rounded,
                                  color: textColor,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Live Preview Section
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: cardShadow,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header Row of Preview Card
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'September, 2026',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: subtextColor,
                                        fontSize: 13 * scale,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    r'+$ 123.45',
                                    style: TextStyle(
                                      color: _incomeRed,
                                      fontSize: 13 * scale,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    r'-$ 678.90',
                                    style: TextStyle(
                                      color: _expenseTeal,
                                      fontSize: 13 * scale,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.keyboard_arrow_up_rounded,
                                    size: 20 * scale,
                                    color: subtextColor,
                                  ),
                                ],
                              ),
                            ),

                            Divider(
                              height: 1,
                              thickness: 0.6,
                              color: dividerColor,
                            ),

                            // Transaction Item Preview Row (matching media_1789111610609.png)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 16,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Date Block
                                  Column(
                                    children: [
                                      Text(
                                        '11',
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 18 * scale,
                                          fontWeight: FontWeight.w700,
                                          height: 1.1,
                                        ),
                                      ),
                                      Text(
                                        'Fri',
                                        style: TextStyle(
                                          color: subtextColor,
                                          fontSize: 11 * scale,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(width: 14),

                                  // Icon Box
                                  Container(
                                    width: 38 * scale,
                                    height: 38 * scale,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white10
                                          : const Color(0xFFF6F6F8),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.white10
                                            : const Color(0xFFE2E4EB),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.rate_review_outlined,
                                      color: textColor,
                                      size: 20 * scale,
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  // Info Column
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Title & Amount
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Category Name',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: textColor,
                                                  fontSize: 16 * scale,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              r'$ 123.45',
                                              style: TextStyle(
                                                color: subtextColor,
                                                fontSize: 15 * scale,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 3),

                                        // Description
                                        Text(
                                          'Description',
                                          style: TextStyle(
                                            color: subtextColor,
                                            fontSize: 13 * scale,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),

                                        const SizedBox(height: 4),

                                        // Tag Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? Colors.white12
                                                : const Color(0xFFF2F2F6),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: isDark
                                                  ? Colors.white10
                                                  : const Color(0xFFE5E7EB),
                                              width: 0.6,
                                            ),
                                          ),
                                          child: Text(
                                            '# Tag Title',
                                            style: TextStyle(
                                              color: subtextColor,
                                              fontSize: 11 * scale,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 4),

                                        // Timestamp and Account
                                        Text(
                                          '12:56 PM · Account Name',
                                          style: TextStyle(
                                            color: subtextColor,
                                            fontSize: 12 * scale,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // Trailing Chevron
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 18 * scale,
                                    color: chevronColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Card: Text Size Slider (matching media_1789111610609.png)
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 20,
                  top: 8,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: cardShadow,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Labels: A ... Default ... A
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'A',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _currentLabel,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'A',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Custom Stepped Slider
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: _copperAccent,
                              inactiveTrackColor: isDark
                                  ? Colors.white24
                                  : const Color(0xFFE2E4EB),
                              trackHeight: 3,
                              thumbColor: Colors.white,
                              thumbShape: const _CustomPillThumbShape(
                                thumbWidth: 32,
                                thumbHeight: 22,
                                thumbRadius: 11,
                              ),
                              overlayColor: _copperAccent.withValues(
                                alpha: 0.12,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 20,
                              ),
                              tickMarkShape: const RoundSliderTickMarkShape(
                                tickMarkRadius: 2.5,
                              ),
                              activeTickMarkColor: _copperAccent,
                              inactiveTickMarkColor: isDark
                                  ? Colors.white24
                                  : const Color(0xFFD1D5DB),
                            ),
                            child: Slider(
                              value: _sliderValue,
                              min: 0.0,
                              max: 4.0,
                              divisions: 4,
                              onChanged: (val) {
                                setState(() {
                                  _sliderValue = val;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomPillThumbShape extends SliderComponentShape {
  final double thumbWidth;
  final double thumbHeight;
  final double thumbRadius;

  const _CustomPillThumbShape({
    this.thumbWidth = 32,
    this.thumbHeight = 22,
    this.thumbRadius = 11,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(thumbWidth, thumbHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final rect = Rect.fromCenter(
      center: center,
      width: thumbWidth,
      height: thumbHeight,
    );

    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(thumbRadius));

    // Subtle shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawRRect(rrect.shift(const Offset(0, 2)), shadowPaint);

    // Pill body
    final fillPaint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawRRect(rrect, fillPaint);

    // Subtle border
    final borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.drawRRect(rrect, borderPaint);
  }
}
