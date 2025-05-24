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
        appBar: AppBar(
          actions: [
            ElevatedButton(
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
          ],
        ),
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
                      print(_startPosition!);
                      print(nearestEnd);
                      if (_startPosition?.dy == nearestEnd.dy) {
                        final minDx = min(_startPosition!.dx, nearestEnd.dx);
                        final maxDx = max(_startPosition!.dx, nearestEnd.dx);
                        _walls.add(
                          Wall([for (double dx = minDx; dx <= maxDx; dx += _gridSize) Offset(dx, nearestEnd.dy)]),
                        );
                      }
                      if (_startPosition?.dx == nearestEnd.dx) {
                        final minDy = min(_startPosition!.dy, nearestEnd.dy);
                        final maxDx = max(_startPosition!.dy, nearestEnd.dy);
                        _walls.add(
                          Wall([for (double dy = minDy; dy <= maxDx; dy += _gridSize) Offset(nearestEnd.dx, dy)]),
                        );
                      }
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
    final node = RouteNode(location: nearestPoint, id: Uuid().v4());
    final horizontals = _findHorizontalNeighbors(node.location);
    final verticals = _findVerticalVerticals(node.location);
    node.updateNeighbors(horizontals);
    node.updateNeighbors(verticals);
    setState(() => _routeNodes.add(node));
  }

  (RouteNode? left, RouteNode? right) _findHorizontalNeighbors(Offset startPoint) {
    return (_findLeftNeighbor(startPoint), _findRightNeighbor(startPoint));
  }

  RouteNode? _findRightNeighbor(Offset startPoint) {
    double rightDirectionCount = startPoint.dx;
    while (rightDirectionCount <= _sceneWidth) {
      final rightPoint = Offset(rightDirectionCount, startPoint.dy);
      final rightObstacle = _pointsContainsWall(rightPoint);
      if (rightObstacle) return null;
      final result = _findNodeInThisPoint(rightPoint);
      if (result case RouteNode neighbor) {
        return neighbor;
      }
      rightDirectionCount += _gridSize;
    }
    return null;
  }

  RouteNode? _findLeftNeighbor(Offset startPoint) {
    double leftDirectionCount = startPoint.dx;
    while (leftDirectionCount >= 0) {
      final leftPoint = Offset(leftDirectionCount, startPoint.dy);
      final leftObstacle = _pointsContainsWall(leftPoint);
      if (leftObstacle) return null;
      final result = _findNodeInThisPoint(leftPoint);
      if (result case RouteNode neighbor) {
        return neighbor;
      }
      leftDirectionCount -= _gridSize;
    }
    return null;
  }

  (RouteNode? top, RouteNode? bottom) _findVerticalVerticals(Offset startPoint) {
    return (_findTopNeighbor(startPoint), _findBottomNeighbor(startPoint));
  }

  RouteNode? _findTopNeighbor(Offset startPoint) {
    double topDirectionCount = startPoint.dy;
    while (topDirectionCount >= 0) {
      final topPoint = Offset(startPoint.dx, topDirectionCount);
      final topObstacle = _pointsContainsWall(topPoint);
      if (topObstacle) return null;
      final result = _findNodeInThisPoint(topPoint);
      if (result case RouteNode neighbor) {
        return neighbor;
      }
      topDirectionCount -= _gridSize;
    }
    return null;
  }

  RouteNode? _findBottomNeighbor(Offset startPoint) {
    double bottomDirectionCount = startPoint.dy;
    while (bottomDirectionCount <= _sceneHeight) {
      final bottomPoint = Offset(startPoint.dx, bottomDirectionCount);
      final topObstacle = _pointsContainsWall(bottomPoint);
      if (topObstacle) return null;
      final result = _findNodeInThisPoint(bottomPoint);
      if (result case RouteNode neighbor) {
        return neighbor;
      }
      bottomDirectionCount += _gridSize;
    }
    return null;
  }

  bool _pointsContainsWall(Offset currentPoint) {
    for (final wall in _walls) {
      for (final point in wall.points) {
        if (currentPoint == point) return true;
      }
    }
    return false;
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
