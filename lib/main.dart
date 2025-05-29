import 'dart:math';

import 'package:floor_builder/a_star.dart';
import 'package:floor_builder/entities/room.dart';
import 'package:floor_builder/entities/route_node.dart';
import 'package:floor_builder/entities/wall.dart';
import 'package:floor_builder/widgets/control_buttons.dart';
import 'package:floor_builder/widgets/door_widget.dart';
import 'package:floor_builder/widgets/floor_plan_widget.dart';
import 'package:floor_builder/widgets/path_painter.dart';
import 'package:floor_builder/widgets/room_layout_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import 'entities/door.dart';

void main() {
  runApp(MaterialApp(home: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  FocusNode _focusNode = FocusNode();

  late final ControlPanelController _controlPanelController;
  late FloorBuilderMode _builderMode;
  bool _isShowGrid = true;
  bool _isVerticalDoor = true;

  double _sceneHeight = 0;
  double _sceneWidth = 0;

  final double _gridSize = 20;

  final List<Room> _rooms = [];
  final List<Wall> _walls = [];
  final Set<RouteNode> _routeNodes = {};
  Offset? _startPosition;
  Offset? _updatePosition;

  //TODO:
  List<Offset> _routePath = [];

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();

    _controlPanelController = ControlPanelController(
      modeListener: (mode) => _builderMode = mode,
      onSwitchShowingGrid: () => setState(() => _isShowGrid = !_isShowGrid),
      onClear: () {
        setState(() {
          _rooms.clear();
          _walls.clear();
          _routeNodes.clear();
          _routePath.clear();
        });
      },
    );
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void onPanStartForCreateRoom(DragStartDetails detail) {
    final startPosition = _findNearestPoint(detail.localPosition);
    setState(() => _startPosition = startPosition);
  }

  void onPanUpdateForCreateRoom(DragUpdateDetails detail) => setState(() => _updatePosition = detail.localPosition);

  Future<void> onPanEndForCreateRoom(DragEndDetails detail) async {
    final endPosition = _findNearestPoint(detail.localPosition);
    //TODO: логика создания комнаты
    final rect = Rect.fromPoints(_startPosition!, endPosition);
    final name = await EnterRoomNameDialog.show<String>(context);
    if (name == null) return;
    final room = Room(id: Uuid().v4(), name: name ?? '', rect: rect);
    setState(() {
      _rooms.add(room);
      _startPosition = null;
      _updatePosition = null;
    });
  }

  void onPanUpdateForCreateDoor(DragUpdateDetails detail) {
    setState(() => _updatePosition = detail.localPosition);
  }

  void onPanEndForCreateDoor(DragEndDetails detail) {
    final nearestPoint = _findNearestPoint(detail.localPosition);
    final result = _findRoomInPoint(nearestPoint);
    if (result.i != null && result.room != null) {
      _rooms[result.i!] = result.room!.copyWith(
        door: Door(isVerticalDirection: _isVerticalDoor, id: Uuid().v4(), location: nearestPoint),
      );
    }

    setState(() {
      _startPosition = null;
      _updatePosition = null;
    });
  }

  ({int? i, Room? room}) _findRoomInPoint(Offset point) {
    for (final (i, room) in _rooms.indexed) {
      if (room.door != null) continue;
      final topRight = room.rect.topRight;
      final topLeft = room.rect.topLeft;
      final bottomLeft = room.rect.bottomLeft;
      final bottomRight = room.rect.bottomRight;

      if (point.dx > topRight.dx && point.dx < topLeft.dx) {
        return (i: i, room: room);
      }
      if (point.dx < bottomRight.dx && point.dx > bottomLeft.dx) {
        return (i: i, room: room);
      }
      if (point.dy > topLeft.dy && point.dy < bottomLeft.dy) {
        return (i: i, room: room);
      }
      if (point.dy > topRight.dy && point.dy < bottomRight.dy) {
        return (i: i, room: room);
      }
    }

    return (i: null, room: null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.arrowLeft): const DirectionIntent(DirectionType.arrowLeft),
          LogicalKeySet(LogicalKeyboardKey.arrowRight): const DirectionIntent(DirectionType.arrowRight),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            DirectionIntent: CallbackAction<DirectionIntent>(
              onInvoke: (intent) {
                if (intent.direction == DirectionType.arrowLeft) {
                  setState(() => _isVerticalDoor = !_isVerticalDoor);
                }
                if (intent.direction == DirectionType.arrowRight) {
                  setState(() => _isVerticalDoor = !_isVerticalDoor);
                }
                return null;
              },
            ),
          },
          child: Focus(
            focusNode: _focusNode,
            autofocus: true,
            skipTraversal: true,
            canRequestFocus: true,
            child: Scaffold(
              drawer: Drawer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 30,
                  children: [
                    TextField(
                      controller: _fromController,
                      decoration: InputDecoration(hint: Text('from')),
                    ),
                    TextField(
                      controller: _toController,
                      decoration: InputDecoration(hint: Text('to')),
                    ),
                  ],
                ),
              ),
              appBar: AppBar(
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      final start = _findRoomByName(_fromController.text);
                      final end = _findRoomByName(_toController.text);
                      if (start != null && end != null) {
                        final aStar = RoutePathFinder(start: start.door!, end: end.door!);
                        final routePath = aStar.calculateRoute();
                        setState(() => _routePath = routePath.toList());
                        _toController.clear();
                        _fromController.clear();
                      }
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
                      behavior: HitTestBehavior.translucent,
                      supportedDevices: {PointerDeviceKind.mouse},
                      onTapDown: switch (_builderMode) {
                        FloorBuilderMode.addNode => _createRouteNode,
                        _ => null,
                      },
                      onPanStart: switch (_builderMode) {
                        FloorBuilderMode.createRooms => onPanStartForCreateRoom,
                        FloorBuilderMode.createWalls => (startDetail) {
                          final nearest = _findNearestPoint(startDetail.localPosition);
                          setState(() => _startPosition = nearest);
                        },
                        _ => null,
                      },

                      onPanUpdate: switch (_builderMode) {
                        FloorBuilderMode.createDoor => onPanUpdateForCreateDoor,
                        FloorBuilderMode.createRooms => onPanUpdateForCreateRoom,
                        FloorBuilderMode.createWalls => (updateDetail) {
                          setState(() {
                            _updatePosition = updateDetail.localPosition;
                          });
                        },
                        _ => null,
                      },

                      onPanEnd: switch (_builderMode) {
                        FloorBuilderMode.createDoor => onPanEndForCreateDoor,
                        FloorBuilderMode.createRooms => onPanEndForCreateRoom,
                        FloorBuilderMode.createWalls => (endDetail) {
                          setState(() {
                            final nearestEnd = _findNearestPoint(endDetail.localPosition);
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

                            _startPosition = null;
                            _updatePosition = null;
                          });
                        },
                        _ => null,
                      },

                      child: SizedBox(
                        height: _sceneHeight,
                        width: _sceneWidth,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (_isShowGrid) _BackgroundGrid(gridSize: _gridSize),
                            if (_builderMode == FloorBuilderMode.createRooms &&
                                _startPosition != null &&
                                _updatePosition != null)
                              RoomLayout(rect: Rect.fromPoints(_startPosition!, _updatePosition!)),

                            if (_builderMode == FloorBuilderMode.createWalls &&
                                _startPosition != null &&
                                _updatePosition != null)
                              CustomPaint(
                                painter: LinePainter(startPoint: _startPosition!, endPoint: _updatePosition!),
                              ),
                            FloorPlan(walls: _walls, routeNodes: _routeNodes.toList(), rooms: _rooms),
                            if (_builderMode == FloorBuilderMode.createDoor && _updatePosition != null)
                              DoorWidget(location: _updatePosition!, isVertical: _isVerticalDoor),
                            if (_routePath.isNotEmpty) PathPainter(path: _routePath),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Room? _findRoomByName(String name) {
    for (final room in _rooms) {
      if (room.name == name) return room;
    }

    return null;
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
      final result = _findNodeInThisPoint(rightPoint);
      if (result != null) return result;
      final rightObstacle = _pointsContainsWall(rightPoint);
      if (rightObstacle) return null;
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
      final result = _findNodeInThisPoint(leftPoint);
      if (result != null) return result;
      final leftObstacle = _pointsContainsWall(leftPoint);
      if (leftObstacle) return null;
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
      final result = _findNodeInThisPoint(topPoint);
      if (result != null) return result;
      final topObstacle = _pointsContainsWall(topPoint);
      if (topObstacle) return null;
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
      final result = _findNodeInThisPoint(bottomPoint);
      if (result != null) return result;
      final topObstacle = _pointsContainsWall(bottomPoint);
      if (topObstacle) return null;
      if (result case RouteNode neighbor) {
        return neighbor;
      }
      bottomDirectionCount += _gridSize;
    }
    return null;
  }

  bool _pointsContainsWall(Offset currentPoint) {
    for (final room in _rooms) {
      final topRight = room.rect.topRight;
      final bottomRight = room.rect.bottomRight;

      if ((currentPoint.dx <= bottomRight.dx && currentPoint.dy <= bottomRight.dy) &&
          (currentPoint.dx >= topRight.dx && currentPoint.dy >= topRight.dy))
        return true;
    }

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
    final nodes = [..._rooms.map((element) => element.door), ..._routeNodes];
    //Оптимизировать
    for (final node in nodes) {
      if (node?.location == point) {
        return node;
      }
    }

    return null;
  }
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

class EnterRoomNameDialog extends StatefulWidget {
  const EnterRoomNameDialog({super.key});

  static Future<T?> show<T>(BuildContext context) =>
      showDialog<T>(context: context, builder: (context) => EnterRoomNameDialog());

  @override
  State<EnterRoomNameDialog> createState() => _EnterRoomNameDialogState();
}

class _EnterRoomNameDialogState extends State<EnterRoomNameDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: 400,
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 100,
            children: [
              TextField(controller: _controller),
              ElevatedButton(onPressed: () => Navigator.pop(context, _controller.text), child: Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}

enum DirectionType { arrowLeft, arrowRight }

class DirectionIntent extends Intent {
  final DirectionType direction;
  const DirectionIntent(this.direction);
}
