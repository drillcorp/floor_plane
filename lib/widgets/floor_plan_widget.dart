import 'package:floor_builder/entities/route_node.dart';
import 'package:floor_builder/entities/wall.dart';
import 'package:flutter/material.dart';

class FloorPlan extends StatefulWidget {
  const FloorPlan({
    this.routeNodes = const [],
    required this.walls,
    this.color = Colors.black,
    this.strokeWidth = 2,
    super.key,
  });

  final double strokeWidth;
  final Color color;
  final List<Wall> walls;
  final List<RouteNode> routeNodes;

  @override
  State<FloorPlan> createState() => _FloorPlanState();
}

class _FloorPlanState extends State<FloorPlan> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..forward();
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return CustomPaint(
          painter: _FloorPlanPainter(
            strokeWidth: widget.strokeWidth,
            color: widget.color,
            walls: widget.walls,
            nodes: widget.routeNodes,
          ),
        );
      },
    );
  }
}

final class _FloorPlanPainter extends CustomPainter {
  const _FloorPlanPainter({required this.nodes, required this.walls, required this.color, required this.strokeWidth});

  final double strokeWidth;
  final Color color;
  final List<Wall> walls;
  final List<RouteNode> nodes;

  @override
  void paint(Canvas canvas, Size size) {
    final paintRouteEdge = Paint()
      ..color = Colors.red.withAlpha(150)
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10;

    final paintRouteNode = Paint()
      ..color = Colors.blue.withAlpha(100)
      ..style = PaintingStyle.fill;

    final paintWall = Paint()
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..color = color;

    for (final routeNode in nodes) {
      final rect = Rect.fromCenter(center: routeNode.location, width: 20, height: 20);
      canvas.drawRect(rect, paintRouteNode);
    }

    for (final wall in walls) {
      final path = Path();
      path.moveTo(wall.startPoint.dx, wall.startPoint.dy);
      path.lineTo(wall.endPoint.dx, wall.endPoint.dy);
      canvas.drawPath(path, paintWall);
    }
  }

  @override
  bool shouldRepaint(_FloorPlanPainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}
