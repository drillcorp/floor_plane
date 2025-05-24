import 'dart:math';

import 'package:floor_builder/a_star.dart';
import 'package:floor_builder/entities/route_node.dart';
import 'package:floor_builder/entities/wall.dart';
import 'package:floor_builder/widgets/control_buttons.dart';
import 'package:floor_builder/widgets/floor_plan_widget.dart';
import 'package:floor_builder/widgets/path_painter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double _sceneHeight = 0;
  double _sceneWidth = 0;

  final double _gridSize = 20;
  late final ControlPanelController _controlPanelController;
  final List<Wall> _walls = [];
  final Set<RouteNode> _routeNodes = {};
  bool createRouteNodes = false;
  bool createRouteEdges = false;
  Offset? _startPosition;
  Offset? _updatePosition;

  //TODO:
  List<Offset> _routePath = [];

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
      clearHandler: () {
        setState(() {
          _walls.clear();
          _routeNodes.clear();
          _routePath.clear();
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
              _sceneHeight = constraints.maxHeight;
              _sceneWidth = constraints.maxWidth;

              return GestureDetector(
                supportedDevices: {PointerDeviceKind.mouse},
                onTapDown: createRouteNodes ? _createRouteNode : null,
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
                      final node = _findNodeInThisPoint(_startPosition!) ?? _findNodeInThisPoint(nearestEnd);
                    } else {
                      _walls.add(Wall(startPoint: _startPosition!, endPoint: nearestEnd));
                    }

                    _startPosition = null;
                    _updatePosition = null;
                  });
                },
                child: SizedBox(
                  height: _sceneHeight,
                  width: _sceneWidth,
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
                          CustomPaint(
                            painter: LinePainter(startPoint: _startPosition!, endPoint: _updatePosition!),
                          ),
                      FloorPlan(walls: _walls, routeNodes: _routeNodes.toList()),
                      if (_routePath.isNotEmpty) PathPainter(path: _routePath),
                      Positioned(
                        top: 50,
                        right: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            print('create');
                            final start = _routeNodes.first;
                            final end = _routeNodes.last;
                            final aStar = AStar(start: start, end: end);
                            final routePath = aStar.calculateRoute();
                            print(routePath);
                            setState(() => _routePath = routePath);
                          },
                          child: Center(child: Text('Create path')),
                        ),
                      ),
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

  void _createRouteNode(TapDownDetails details) {
    final nearestPoint = _findNearestPoint(details.localPosition);
    //TODO:
    print(nearestPoint);
    final node = RouteNode(location: nearestPoint, id: Uuid().v4());
    final horizontals = _findConnectedOnHorizontal(node.location);
    final verticals = _findConnectedOnVertical(node.location);
    node.updateNeighbors(horizontals);
    node.updateNeighbors(verticals);
    setState(() => _routeNodes.add(node));
  }

  (RouteNode? left, RouteNode? right) _findConnectedOnHorizontal(Offset startPoint) {
    RouteNode? left, right;

    double leftDirectionCount = startPoint.dx;
    double rightDirectionCount = startPoint.dx;
    while (rightDirectionCount <= _sceneWidth && leftDirectionCount >= 0) {
      final rightPoint = Offset(rightDirectionCount, startPoint.dy);
      final leftPoint = Offset(leftDirectionCount, startPoint.dy);

      right ??= _findNodeInThisPoint(rightPoint);
      left ??= _findNodeInThisPoint(leftPoint);

      if (right != null && left != null) break;

      rightDirectionCount += _gridSize;
      leftDirectionCount -= _gridSize;
    }

    return (left, right);
  }

  (RouteNode? top, RouteNode? bottom) _findConnectedOnVertical(Offset startPoint) {
    RouteNode? top, bottom;

    double topDirectionCount = startPoint.dy;
    double bottomDirectionCount = startPoint.dy;
    while (bottomDirectionCount <= _sceneHeight && topDirectionCount >= 0) {
      final topPoint = Offset(startPoint.dx, topDirectionCount);
      final bottomPoint = Offset(startPoint.dx, bottomDirectionCount);

      top ??= _findNodeInThisPoint(topPoint);
      bottom ??= _findNodeInThisPoint(bottomPoint);

      if (top != null && bottom != null) break;

      bottomDirectionCount += _gridSize;
      topDirectionCount -= _gridSize;
    }

    return (top, bottom);
  }

  Offset _findNearestPoint(Offset currentPoint) {
    final dx = (currentPoint.dx / _gridSize).round() * _gridSize;
    final dy = (currentPoint.dy / _gridSize).round() * _gridSize;
    return Offset(dx, dy);
  }

  RouteNode? _findNodeInThisPoint(Offset point) {
    //Оптимизировать
    for (final node in _routeNodes) {
      if (node.location == point) {
        return node;
      }
    }

    return null;
  }
}

final class RouteEdgePainter extends CustomPainter {
  RouteEdgePainter({required this.startPoint, required this.endPoint});

  final Offset startPoint;
  final Offset endPoint;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10
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
    final paint = Paint()
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
    final Paint gridPain = Paint()
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
