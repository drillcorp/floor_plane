import 'package:flutter/material.dart';

///A widget for displaying a room before it is attached to the plan.
class RoomFrame extends StatelessWidget {
  const RoomFrame({super.key, required this.rect});

  final Rect rect;

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _RoomWallsPainter(rect: rect));
}

final class _RoomWallsPainter extends CustomPainter {
  _RoomWallsPainter({required this.rect});

  final Rect rect;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(_RoomWallsPainter oldDelegate) => rect != oldDelegate.rect;
}
