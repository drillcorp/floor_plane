import 'package:flutter/material.dart';

class PathPainter extends StatefulWidget {
  const PathPainter({required this.path, super.key});

  final List<Offset> path;

  @override
  State<PathPainter> createState() => _PathPainterState();
}

class _PathPainterState extends State<PathPainter> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void didUpdateWidget(PathPainter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _PathPainter(widget.path, animation: _animation));
  }
}

final class _PathPainter extends CustomPainter {
  _PathPainter(this.pathPoints, {required Animation<double> animation})
    : _animation = animation,
      super(repaint: animation);

  final List<Offset> pathPoints;
  final Animation<double> _animation;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 5
      ..color = Colors.green
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final startPoint = pathPoints.first;
    final path = Path()..moveTo(startPoint.dx, startPoint.dy);
    for (final point in pathPoints.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }

    final metrics = path.computeMetrics().first;
    final extract = metrics.extractPath(0, metrics.length * _animation.value);

    canvas.drawPath(extract, paint);
  }

  @override
  bool shouldRepaint(_PathPainter oldDelegate) => oldDelegate.pathPoints != pathPoints;
}
