import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ezbookkeeping/features/statistics/domain/entities/statistic_category_item.dart';

/// Custom Painter for Donut Chart with center circular badge and category slices.
class DonutChartPainter extends CustomPainter {
  final List<StatisticCategoryItem> items;
  final int selectedIndex;
  final String centerTitle;
  final String centerAmount;
  final Color centerBadgeColor;
  final Color centerBorderColor;
  final double strokeWidthRatio;

  DonutChartPainter({
    required this.items,
    required this.selectedIndex,
    required this.centerTitle,
    required this.centerAmount,
    this.centerBadgeColor = const Color(0xFF6A1E1E),
    this.centerBorderColor = Colors.white,
    this.strokeWidthRatio = 0.38,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = radius * strokeWidthRatio;
    final outerRadius = radius - 4;
    final innerRadius = outerRadius - strokeWidth;

    if (items.isEmpty) {
      final emptyPaint = Paint()
        ..color = const Color(0xFFE5E5EA)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawCircle(center, outerRadius - strokeWidth / 2, emptyPaint);
      _drawCenterBadge(canvas, center, innerRadius);
      return;
    }

    final total = items.fold<double>(0, (sum, item) => sum + item.amount);
    if (total <= 0) {
      final emptyPaint = Paint()
        ..color = const Color(0xFFE5E5EA)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawCircle(center, outerRadius - strokeWidth / 2, emptyPaint);
      _drawCenterBadge(canvas, center, innerRadius);
      return;
    }

    // Draw slices starting at -pi / 2 (12 o'clock) or -pi * 0.7
    double startAngle = -math.pi / 2;
    const double gapAngle = 0.012; // Small gap between slices

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final sweepAngle = (item.amount / total) * 2 * math.pi;
      if (sweepAngle <= 0) continue;

      final isSelected = i == selectedIndex;
      final effectiveSweep = math.max(0.001, sweepAngle - gapAngle);

      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? strokeWidth + 4 : strokeWidth
        ..strokeCap = StrokeCap.butt
        ..isAntiAlias = true;

      final arcRadius = outerRadius - strokeWidth / 2 + (isSelected ? 2 : 0);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: arcRadius),
        startAngle + (gapAngle / 2),
        effectiveSweep,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Draw center circular badge
    _drawCenterBadge(canvas, center, innerRadius);
  }

  void _drawCenterBadge(Canvas canvas, Offset center, double innerRadius) {
    final badgeRadius = innerRadius - 2;

    // Badge Background
    final badgePaint = Paint()
      ..color = centerBadgeColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(center, badgeRadius, badgePaint);

    // Badge White Outline Ring
    final borderPaint = Paint()
      ..color = centerBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..isAntiAlias = true;
    canvas.drawCircle(center, badgeRadius, borderPaint);

    // Center Title Text
    final titleSpan = TextSpan(
      text: centerTitle,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.2,
      ),
    );
    final titlePainter = TextPainter(
      text: titleSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: badgeRadius * 1.8);

    // Center Amount Text
    final amountSpan = TextSpan(
      text: centerAmount,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15.5,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.3,
      ),
    );
    final amountPainter = TextPainter(
      text: amountSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: badgeRadius * 1.8);

    final totalHeight = titlePainter.height + amountPainter.height + 4;
    final startY = center.dy - (totalHeight / 2);

    titlePainter.paint(
      canvas,
      Offset(center.dx - (titlePainter.width / 2), startY),
    );
    amountPainter.paint(
      canvas,
      Offset(
        center.dx - (amountPainter.width / 2),
        startY + titlePainter.height + 4,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.items != items ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.centerTitle != centerTitle ||
        oldDelegate.centerAmount != centerAmount ||
        oldDelegate.centerBadgeColor != centerBadgeColor;
  }
}
