import 'package:flutter/material.dart';

class DoorWidget extends StatelessWidget {
  const DoorWidget({required this.location, this.isVertical = true, this.length = 12, super.key});

  final Offset location;
  final bool isVertical;
  final double length;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DoorPainter(location: location, isVertical: isVertical, length: length),
    );
  }
}

final class _DoorPainter extends CustomPainter {
  _DoorPainter({required this.location, required this.isVertical, required this.length});

  final Offset location;
  final bool isVertical;
  final double length;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke
      ..color = Colors.orange;

    final path = Path();

    if (isVertical) {
      path.moveTo(location.dx, location.dy - length);
      path.lineTo(location.dx, location.dy + length);
    } else {
      path.moveTo(location.dx - length, location.dy);
      path.lineTo(location.dx + length, location.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_DoorPainter oldDelegate) => oldDelegate.location != location;
}
