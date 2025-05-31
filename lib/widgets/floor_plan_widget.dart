import 'package:floor_builder/entities/door.dart';
import 'package:floor_builder/entities/room.dart';
import 'package:floor_builder/entities/wall.dart';
import 'package:flutter/material.dart';

class FloorPlan extends StatelessWidget {
  const FloorPlan({
    required this.walls,
    required this.rooms,
    this.color = Colors.black,
    this.strokeWidth = 2,
    super.key,
  });

  final double strokeWidth;
  final Color color;
  final List<Wall> walls;
  final List<Room> rooms;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FloorPlanPainter(strokeWidth: strokeWidth, color: color, walls: walls, rooms: rooms),
    );
  }
}

final class _FloorPlanPainter extends CustomPainter {
  const _FloorPlanPainter({required this.walls, required this.color, required this.strokeWidth, required this.rooms});

  final double strokeWidth;
  final Color color;
  final List<Wall> walls;
  final List<Room> rooms;

  @override
  void paint(Canvas canvas, Size size) {
    final paintWall = Paint()
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..color = color;

    for (final room in rooms) {
      final roomPainter = _RoomPainter(name: room.name, walls: room.rect, door: room.door);
      roomPainter.paint(canvas, room.rect.size);
    }

    for (final wall in walls) {
      if (wall.points.isEmpty) continue;
      final path = Path();
      path.moveTo(wall.points.first.dx, wall.points.first.dy);
      path.lineTo(wall.points.last.dx, wall.points.last.dy);
      canvas.drawPath(path, paintWall);
    }
  }

  @override
  bool shouldRepaint(_FloorPlanPainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}

final class _RoomPainter extends CustomPainter {
  _RoomPainter({required this.name, required this.walls, required this.door});

  final String name;
  final Rect walls;
  final Door? door;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawRect(walls, paint);

    final textStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 35, color: Colors.black);
    final text = TextSpan(text: name, style: textStyle);
    final textPainter = TextPainter(textDirection: TextDirection.ltr, text: text);
    textPainter.layout(maxWidth: size.width);
    final metrics = textPainter.computeLineMetrics().first;
    final textWidth = metrics.width;
    final textHeight = metrics.height;
    final testOffset = Offset(size.width / 2 - textWidth / 2, size.height / 2 - textHeight / 2);
    textPainter.paint(canvas, walls.topLeft + testOffset);
    if (door case Door door) {
      paintDoor(canvas, size, door);
    }
  }

  void paintDoor(Canvas canvas, Size size, Door door) {
    final doorPaint = Paint()
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke
      ..color = Colors.orange;

    final path = Path();
    final location = door.location;
    if (door.isVerticalDirection) {
      path.moveTo(location.dx, location.dy - 10);
      path.lineTo(location.dx, location.dy + 10);
    } else {
      path.moveTo(location.dx - 10, location.dy);
      path.lineTo(location.dx + 10, location.dy);
    }

    canvas.drawPath(path, doorPaint);
  }

  @override
  bool shouldRepaint(_RoomPainter oldDelegate) =>
      walls != oldDelegate.walls || name != oldDelegate.name || door != oldDelegate.door;
}
