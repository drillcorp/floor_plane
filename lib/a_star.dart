import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:floor_builder/entities/graph_node.dart';

final class RoutePathFinder {
  RoutePathFinder({required this.start, required this.end});

  final GraphNode start, end;

  //Manhetten heuristic
  double _heuristic(Offset a, Offset b) => (a.dx - b.dx).abs() + (a.dy - b.dy).abs();

  Iterable<Offset> calculateRoute() {
    final Set<GraphNode> visitedNodes = {};
    final fScore = <GraphNode, double>{}; //карта оценочной стоимости
    //Приоритетная очередь будет выстраивать приоритет по оценочной стоимости
    final openSet = PriorityQueue<GraphNode>((a, b) => fScore[a]!.compareTo(fScore[b]!));
    final ancestors = <GraphNode, GraphNode>{};
    final gScore = <Offset, double>{}; //фактическое расстояние от старта

    gScore[start.location] = 0;
    fScore[start] = _heuristic(start.location, end.location);

    openSet.add(start);

    while (openSet.isNotEmpty) {
      final current = openSet.removeFirst();
      if (visitedNodes.contains(current)) continue;

      if (current == end) {
        return _preparePath(ancestors, current).toList().reversed;
      }

      for (final neighbor in current.neighbors) {
        final tentativeG = gScore[current.location]! + 20;

        if (tentativeG < (gScore[neighbor.location] ?? double.infinity)) {
          ancestors[neighbor] = current;
          gScore[neighbor.location] = tentativeG;
          fScore[neighbor] = tentativeG + _heuristic(neighbor.location, end.location);
        }

        if (!openSet.contains(neighbor) && neighbor.neighbors.isNotEmpty) {
          openSet.add(neighbor);
        }
      }
      visitedNodes.add(current);
    }

    return [];
  }

  Iterable<Offset> _preparePath(Map<GraphNode, GraphNode> ancestors, GraphNode current) sync* {
    yield current.location;
    while (ancestors.containsKey(current)) {
      current = ancestors[current]!;
      yield current.location;
    }
  }
}
