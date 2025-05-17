import 'dart:math';

import 'package:floor_builder/entities/route_node.dart';
import 'package:floor_builder/entities/wall.dart';
import 'package:floor_builder/widgets/control_buttons.dart';
import 'package:floor_builder/widgets/floor_plan_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'entities/route_edge.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final double _gridSize = 20;
  late final ControlPanelController _controlPanelController;
  final List<Wall> _walls = [];
  final List<RouteEdge> _routeEdges = [];
  final List<RouteNode> _routeNodes = [];
  bool createRouteNodes = false;
  bool createRouteEdges = false;
  Offset? _startPosition;
  Offset? _updatePosition;

  @override
  void initState() {
    super.initState();
    _controlPanelController = ControlPanelController(
      wallCreateModeHandler: () {
        setState(() {
          createRouteNodes = false;
          createRouteEdges = false;
        });
      },
      routeNodeCreateModeHandler: () {
        setState(() {
          createRouteNodes = true;
          createRouteEdges = false;
        });
      },
      routeEdgeCreateModeHandler: () {
        setState(() {
          createRouteEdges = true;
          createRouteNodes = false;
        });
      },
    );
  }

  @override
  void dispose() {
    //TODO: dispose controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: ControlPanel(controller: _controlPanelController),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        body: InteractiveViewer(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                supportedDevices: {PointerDeviceKind.mouse},
                onTapDown:
                    createRouteNodes
                        ? (detail) {
                          setState(() {
                            final nearestPoint = _findNearestPoint(detail.localPosition);
                            final rect = Rect.fromCenter(center: nearestPoint, width: 40, height: 40);
                            _routeNodes.add(RouteNode(rect: rect));
                          });
                        }
                        : null,
                onPanStart: (startDetail) {
                  final nearest = _findNearestPoint(startDetail.localPosition);
                  setState(() => _startPosition = nearest);
                },

                onPanUpdate: (updateDetail) {
                  setState(() {
                    _updatePosition = updateDetail.localPosition;
                  });
                },

                onPanEnd: (endDetail) {
                  setState(() {
                    final nearestEnd = _findNearestPoint(endDetail.localPosition);
                    if (createRouteEdges) {
                      _routeEdges.add(RouteEdge(startPoint: _startPosition!, endPoint: nearestEnd));
                    } else {
                      _walls.add(Wall(startPoint: _startPosition!, endPoint: nearestEnd));
                    }

                    _startPosition = null;
                    _updatePosition = null;
                  });
                },
                child: SizedBox(
                  height: constraints.maxHeight,
                  width: constraints.maxWidth,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _BackgroundGrid(gridSize: _gridSize),
                      if (_startPosition != null && _updatePosition != null)
                        if (createRouteEdges)
                          CustomPaint(
                            painter: RouteEdgePainter(startPoint: _startPosition!, endPoint: _updatePosition!),
                          )
                        else
                          CustomPaint(painter: LinePainter(startPoint: _startPosition!, endPoint: _updatePosition!)),
                      FloorPlan(walls: _walls, routeNodes: _routeNodes, routeEdges: _routeEdges),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Offset _findNearestPoint(Offset currentPoint) {
    final dx = (currentPoint.dx / _gridSize).round() * _gridSize;
    final dy = (currentPoint.dy / _gridSize).round() * _gridSize;
    return Offset(dx, dy);
  }
}

final class RouteEdgePainter extends CustomPainter {
  RouteEdgePainter({required this.startPoint, required this.endPoint});

  final Offset startPoint;
  final Offset endPoint;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 20
          ..color = Colors.red.withAlpha(100)
          ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(startPoint.dx, startPoint.dy);
    path.lineTo(endPoint.dx, endPoint.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(RouteEdgePainter oldDelegate) =>
      startPoint != oldDelegate.startPoint || endPoint != oldDelegate.endPoint;
}

final class LinePainter extends CustomPainter {
  LinePainter({required this.startPoint, required this.endPoint});

  final Offset startPoint;
  final Offset endPoint;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 2
          ..color = Colors.black
          ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(startPoint.dx, startPoint.dy);
    path.lineTo(endPoint.dx, endPoint.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) =>
      startPoint != oldDelegate.startPoint || endPoint != oldDelegate.endPoint;
}

class _BackgroundGrid extends StatelessWidget {
  const _BackgroundGrid({required this.gridSize});

  final double gridSize;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _BackgroundGridPainter(gridSize));
  }
}

final class _BackgroundGridPainter extends CustomPainter {
  _BackgroundGridPainter(this.gridSize);

  final double gridSize;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPain =
        Paint()
          ..strokeWidth = 1
          ..color = Colors.black12;

    final maxDimension = max(size.height, size.width);

    for (double i = 0; i < maxDimension; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPain);
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPain);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
