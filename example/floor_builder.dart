import 'dart:math';

import 'package:floor_builder/entities/door.dart';
import 'package:floor_builder/entities/room.dart';
import 'package:floor_builder/entities/route_node.dart';
import 'package:floor_builder/entities/wall.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

///State contains detailed information about plan
///[FloorBuilderState.walls]
///[FloorBuilderState.rooms]
///[FloorBuilderState.graphNodes]
///In fact it's a graph presentation
final class FloorBuilderState {
  FloorBuilderState({this.walls = const [], this.rooms = const [], this.graphNodes = const []});

  final List<Wall> walls;
  final List<Room> rooms;
  final List<GraphNode> graphNodes;

  FloorBuilderState copyWith({List<Wall>? walls, List<Room>? rooms, List<GraphNode>? graphNodes}) => FloorBuilderState(
    walls: walls ?? this.walls,
    rooms: rooms ?? this.rooms,
    graphNodes: graphNodes ?? this.graphNodes,
  );
}

///This class create your floor plan,
///it contains state witch contains [FloorBuilderState.state] information about floor plan.
///It also contains all information about the grid and it's limitations.
///[FloorBuilder.cellGridSize]
///[FloorBuilder.sceneWidth]
///[FloorBuilder.sceneHeight]
final class FloorBuilder extends ChangeNotifier {
  FloorBuilder({required this.cellGridSize});

  ///Size of one cell
  final double cellGridSize;

  double _sceneWidth = 0;
  double get sceneWidth => _sceneWidth;
  set sceneWidth(double newValue) {
    if (newValue == _sceneWidth) return;
    _sceneWidth = newValue;
  }

  double _sceneHeight = 0;
  double get sceneHeight => _sceneHeight;
  set sceneHeight(double newValue) {
    if (newValue == _sceneWidth) return;
    _sceneHeight = newValue;
  }

  FloorBuilderState _state = FloorBuilderState();
  FloorBuilderState get state => _state;

  void clearState() => _emit(FloorBuilderState());

  ///adds an intersection point for the vertices of the graphs,
  ///is the vertex of the graph
  void createGraphNode(Offset point) {
    final graphNodes = [...state.graphNodes];
    final nearestPoint = findNearestPoint(point);
    final node = GraphNode(location: nearestPoint, id: Uuid().v4());
    final horizontals = _findHorizontalNeighbors(node.location);
    final verticals = _findVerticalVerticals(node.location);
    node.updateNeighbors(horizontals);
    node.updateNeighbors(verticals);
    graphNodes.add(node);
    _emit(state.copyWith(graphNodes: graphNodes));
  }

  ///final horizontal neighbors in left and right direction, start from current point
  (GraphNode? left, GraphNode? right) _findHorizontalNeighbors(Offset startPoint) {
    return (_findLeftNeighbor(startPoint), _findRightNeighbor(startPoint));
  }

  GraphNode? _findRightNeighbor(Offset startPoint) {
    double rightDirectionCount = startPoint.dx;
    while (rightDirectionCount <= _sceneWidth) {
      final rightPoint = Offset(rightDirectionCount, startPoint.dy);
      final result = _findNodeInThisPoint(rightPoint);
      if (result != null) return result;
      final rightObstacle = _pointsContainsWall(rightPoint);
      if (rightObstacle) return null;
      if (result case GraphNode neighbor) {
        return neighbor;
      }
      rightDirectionCount += cellGridSize;
    }
    return null;
  }

  GraphNode? _findLeftNeighbor(Offset startPoint) {
    double leftDirectionCount = startPoint.dx;
    while (leftDirectionCount >= 0) {
      final leftPoint = Offset(leftDirectionCount, startPoint.dy);
      final result = _findNodeInThisPoint(leftPoint);
      if (result != null) return result;
      final leftObstacle = _pointsContainsWall(leftPoint);
      if (leftObstacle) return null;
      if (result case GraphNode neighbor) {
        return neighbor;
      }
      leftDirectionCount -= cellGridSize;
    }
    return null;
  }

  ///final vertical neighbors in left and right direction, start from current point
  (GraphNode? top, GraphNode? bottom) _findVerticalVerticals(Offset startPoint) {
    return (_findTopNeighbor(startPoint), _findBottomNeighbor(startPoint));
  }

  GraphNode? _findTopNeighbor(Offset startPoint) {
    double topDirectionCount = startPoint.dy;
    while (topDirectionCount >= 0) {
      final topPoint = Offset(startPoint.dx, topDirectionCount);
      final result = _findNodeInThisPoint(topPoint);
      if (result != null) return result;
      final topObstacle = _pointsContainsWall(topPoint);
      if (topObstacle) return null;
      if (result case GraphNode neighbor) {
        return neighbor;
      }
      topDirectionCount -= cellGridSize;
    }
    return null;
  }

  GraphNode? _findBottomNeighbor(Offset startPoint) {
    double bottomDirectionCount = startPoint.dy;
    while (bottomDirectionCount <= _sceneHeight) {
      final bottomPoint = Offset(startPoint.dx, bottomDirectionCount);
      final result = _findNodeInThisPoint(bottomPoint);
      if (result != null) return result;
      final topObstacle = _pointsContainsWall(bottomPoint);
      if (topObstacle) return null;
      if (result case GraphNode neighbor) {
        return neighbor;
      }
      bottomDirectionCount += cellGridSize;
    }
    return null;
  }

  GraphNode? _findNodeInThisPoint(Offset point) {
    final nodes = [...state.rooms.map((element) => element.door), ...state.graphNodes];
    for (final node in nodes) {
      if (node?.location == point) {
        return node;
      }
    }

    return null;
  }

  bool _pointsContainsWall(Offset currentPoint) {
    for (final room in state.rooms) {
      final topRight = room.rect.topRight;
      final bottomRight = room.rect.bottomRight;

      if ((currentPoint.dx <= bottomRight.dx && currentPoint.dy <= bottomRight.dy) &&
          (currentPoint.dx >= topRight.dx && currentPoint.dy >= topRight.dy)) {
        return true;
      }
    }

    for (final wall in state.walls) {
      for (final point in wall.points) {
        if (currentPoint == point) return true;
      }
    }
    return false;
  }

  void createWall({required Offset start, required Offset end}) {
    final walls = [...state.walls];
    final nearestEnd = findNearestPoint(end);
    if (start.dy == nearestEnd.dy) {
      final minDx = min(start.dx, nearestEnd.dx);
      final maxDx = max(start.dx, nearestEnd.dx);
      walls.add(Wall([for (double dx = minDx; dx <= maxDx; dx += cellGridSize) Offset(dx, nearestEnd.dy)]));
    }
    if (start.dx == nearestEnd.dx) {
      final minDy = min(start.dy, nearestEnd.dy);
      final maxDx = max(start.dy, nearestEnd.dy);
      walls.add(Wall([for (double dy = minDy; dy <= maxDx; dy += cellGridSize) Offset(nearestEnd.dx, dy)]));
    }
    _emit(state.copyWith(walls: walls));
  }

  void createRoomFromPoints({required Offset start, required Offset end, required String name}) {
    final endPosition = findNearestPoint(end);
    final rect = Rect.fromPoints(start, endPosition);
    final room = Room(id: Uuid().v4(), name: name, rect: rect);
    final rooms = [...state.rooms, room];
    _emit(state.copyWith(rooms: rooms));
  }

  void createDoor(Offset point, {bool isVertical = true}) {
    final nearestPoint = findNearestPoint(point);
    final roomResult = _findRoomInPoint(nearestPoint);
    final rooms = [...state.rooms];
    if (roomResult.index != null && roomResult.room != null) {
      rooms[roomResult.index!] = roomResult.room!.copyWith(
        door: Door(isVerticalDirection: isVertical, id: Uuid().v4(), location: nearestPoint),
      );
    }
    _emit(state.copyWith(rooms: rooms));
  }

  ({int? index, Room? room}) _findRoomInPoint(Offset point) {
    for (final (i, room) in _state.rooms.indexed) {
      if (room.door != null) continue;
      final topRight = room.rect.topRight;
      final topLeft = room.rect.topLeft;
      final bottomLeft = room.rect.bottomLeft;
      final bottomRight = room.rect.bottomRight;

      if (point.dx > topRight.dx && point.dx < topLeft.dx) {
        return (index: i, room: room);
      }
      if (point.dx < bottomRight.dx && point.dx > bottomLeft.dx) {
        return (index: i, room: room);
      }
      if (point.dy > topLeft.dy && point.dy < bottomLeft.dy) {
        return (index: i, room: room);
      }
      if (point.dy > topRight.dy && point.dy < bottomRight.dy) {
        return (index: i, room: room);
      }
    }

    return (index: null, room: null);
  }

  Offset findNearestPoint(Offset currentPoint) {
    final dx = (currentPoint.dx / cellGridSize).round() * cellGridSize;
    final dy = (currentPoint.dy / cellGridSize).round() * cellGridSize;
    return Offset(dx, dy);
  }

  void _emit(FloorBuilderState newState) {
    _state = newState;
    notifyListeners();
  }
}
