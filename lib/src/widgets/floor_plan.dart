import 'package:floor_builder/floor_builder.dart';
import 'package:flutter/material.dart';

///A widget that builds a complete room plan.
class FloorPlan extends StatelessWidget {
  const FloorPlan({
    required this.walls,
    required this.rooms,
    this.wallStrokeWidth = 2,
    this.roomStrokeWidth = 2,
    this.wallsColor,
    this.roomColor,
    this.doorColor,
    this.roomTextStyle,
    super.key,
  });

  final List<Wall> walls;
  final List<Room> rooms;
  final TextStyle? roomTextStyle;
  final double wallStrokeWidth, roomStrokeWidth;
  final Color? wallsColor, roomColor, doorColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FloorPlanPainter(
        walls: walls,
        rooms: rooms,
        roomStrokeWidth: roomStrokeWidth,
        wallStrokeWidth: wallStrokeWidth,
        roomColor: roomColor,
        wallColor: wallsColor,
        doorColor: doorColor,
        roomTextStyle: roomTextStyle,
      ),
    );
  }
}

final class _FloorPlanPainter extends CustomPainter {
  const _FloorPlanPainter({
    required this.walls,
    required this.wallStrokeWidth,
    required this.roomStrokeWidth,
    required this.rooms,
    this.roomColor,
    this.wallColor,
    this.doorColor,
    this.roomTextStyle,
  });

  final List<Wall> walls;
  final List<Room> rooms;
  final double wallStrokeWidth, roomStrokeWidth;
  final Color? roomColor, wallColor, doorColor;
  final TextStyle? roomTextStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final paintWall = Paint()
      ..strokeWidth = wallStrokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..color = wallColor ?? Colors.black;

    for (final room in rooms) {
      final roomPainter = _RoomPainter(
        name: room.name,
        walls: room.rect,
        door: room.door,
        roomColor: roomColor,
        doorColor: doorColor,
        roomTitleStyle: roomTextStyle,
      );
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
      wallColor != oldDelegate.wallColor ||
      wallStrokeWidth != oldDelegate.wallStrokeWidth ||
      roomStrokeWidth != oldDelegate.roomStrokeWidth ||
      roomColor != oldDelegate.roomColor ||
      doorColor != oldDelegate.doorColor ||
      walls != oldDelegate.walls ||
      rooms != oldDelegate.rooms ||
      roomTextStyle != oldDelegate.roomTextStyle;
}

final class _RoomPainter extends CustomPainter {
  _RoomPainter({
    required this.name,
    required this.walls,
    this.door,
    this.doorColor,
    this.roomColor,
    this.roomTitleStyle,
  });

  final String name;
  final Rect walls;
  final GraphNode? door;
  final Color? roomColor, doorColor;
  final TextStyle? roomTitleStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawRect(walls, paint);

    final textStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.black);
    final text = TextSpan(text: name, style: textStyle);
    final textPainter = TextPainter(textDirection: TextDirection.ltr, text: text);
    textPainter.layout(maxWidth: size.width);
    final metrics = textPainter.computeLineMetrics().first;
    final textWidth = metrics.width;
    final textHeight = metrics.height;
    final testOffset = Offset(size.width / 2 - textWidth / 2, size.height / 2 - textHeight / 2);
    textPainter.paint(canvas, walls.topLeft + testOffset);
    if (door != null && door!.isVerticalDoor != null) {
      paintDoor(canvas, size, door!);
    }
  }

  void paintDoor(Canvas canvas, Size size, GraphNode door) {
    final doorPaint = Paint()
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke
      ..color = Colors.orange;

    final path = Path();
    final location = door.location;
    if (door.isVerticalDoor!) {
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
