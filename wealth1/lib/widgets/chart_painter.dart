import 'package:flutter/material.dart';

class ChartPainter extends CustomPainter {
  final List<Color> gradientColors; // Colors for the gradient fill
  final Color borderColor; // Color for the chart data line border
  final bool isDown;

  ChartPainter({
    required this.gradientColors,
    required this.borderColor,
    this.isDown = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Paint for the gradient fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: gradientColors,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Paint for the chart data line border
    final linePaint = Paint()
      ..color = borderColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final height = size.height;
    final width = size.width;

    // Define points for the chart line
    final points = isDown
        ? [
      Offset(0, height * 0.2),
      Offset(width * 0.2, height * 0.4),
      Offset(width * 0.4, height * 0.2),
      Offset(width * 0.6, height * 0.6),
      Offset(width * 0.8, height * 0.4),
      Offset(width, height * 0.8),
    ]
        : [
      Offset(0, height * 0.8),
      Offset(width * 0.2, height * 0.6),
      Offset(width * 0.4, height * 0.8),
      Offset(width * 0.6, height * 0.4),
      Offset(width * 0.8, height * 0.6),
      Offset(width, height * 0.2),
    ];

    // Path for the chart line and filled area
    final chartPath = Path();
    chartPath.moveTo(points[0].dx, points[0].dy);

    // Create a smooth curve with more pronounced control points
    for (int i = 1; i < points.length; i++) {
      final startPoint = points[i - 1];
      final endPoint = points[i];
      final controlOffset = (endPoint.dy - startPoint.dy).abs() * 0.5;
      final controlPoint = Offset(
        (startPoint.dx + endPoint.dx) / 2,
        isDown
            ? startPoint.dy + controlOffset
            : startPoint.dy - controlOffset,
      );
      chartPath.quadraticBezierTo(
        controlPoint.dx,
        controlPoint.dy,
        endPoint.dx,
        endPoint.dy,
      );
    }
    // Close the path for filling
    chartPath.lineTo(width, height); // Bottom-right
    chartPath.lineTo(0, height); // Bottom-left
    chartPath.close();

    // Path for the chart data line border (curved)
    final linePath = Path();
    linePath.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      final startPoint = points[i - 1];
      final endPoint = points[i];
      final controlOffset = (endPoint.dy - startPoint.dy).abs() * 0.5;
      final controlPoint = Offset(
        (startPoint.dx + endPoint.dx) / 2,
        isDown
            ? startPoint.dy + controlOffset
            : startPoint.dy - controlOffset,
      );
      linePath.quadraticBezierTo(
        controlPoint.dx,
        controlPoint.dy,
        endPoint.dx,
        endPoint.dy,
      );
    }

    // Draw the filled area with gradient
    canvas.drawPath(chartPath, fillPaint);

    // Draw the curved chart data line border
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant ChartPainter oldDelegate) {
    return oldDelegate.gradientColors != gradientColors ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.isDown != isDown;
  }
}