import 'package:blendertest/view/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RoadPainter extends CustomPainter {
  final double offset;
  RoadPainter(this.offset);

  @override
  void paint(Canvas canvas, Size size) {
    // 🌿 Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF4CAF50),
    );

    // 🛣 Road
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.05, 0, size.width * 0.9, size.height),
      Paint()..color = const Color(0xFF2E2E2E),
    );

    // 🟤 ROAD SHOULDERS
    final shoulderPaint = Paint()..color = const Color(0xFF795548);

    final leftShoulder = Path()
      ..moveTo(size.width * 0.02, 0)
      ..lineTo(size.width * 0.05, 0)
      ..lineTo(size.width * 0.05, size.height)
      ..lineTo(size.width * 0.02, size.height)
      ..close();

    final rightShoulder = Path()
      ..moveTo(size.width * 0.95, 0)
      ..lineTo(size.width * 0.98, 0)
      ..lineTo(size.width * 0.98, size.height)
      ..lineTo(size.width * 0.95, size.height)
      ..close();

    canvas.drawPath(leftShoulder, shoulderPaint);
    canvas.drawPath(rightShoulder, shoulderPaint);

    // ➖ Center Line
    const dashHeight = 30.0;
    const gap = 30.0;
    final step = dashHeight + gap;

    double y = -step + (offset % step);

    final dashPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    while (y < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, y + dashHeight),
        dashPaint,
      );
      y += step;
    }

    // 🌳 Trees
    const treeStep = 70.0;
    double treeY = -treeStep + (offset % treeStep);

    final treePaint = Paint()..color = const Color(0xFF2E7D32);
    final trunkPaint = Paint()..color = const Color(0xFF5D4037);

    while (treeY < size.height) {
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(size.width * -0.05, treeY + 15),
          width: 6,
          height: 20,
        ),
        trunkPaint,
      );
      canvas.drawCircle(Offset(size.width * -0.05, treeY), 18, treePaint);

      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(size.width * 1.05, treeY + 15),
          width: 6,
          height: 20,
        ),
        trunkPaint,
      );
      canvas.drawCircle(Offset(size.width * 1.05, treeY), 18, treePaint);

      treeY += treeStep;
    }
  }

  @override
  bool shouldRepaint(covariant RoadPainter oldDelegate) {
    return oldDelegate.offset != offset;
  }
}