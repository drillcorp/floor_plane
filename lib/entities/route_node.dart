import 'package:flutter/cupertino.dart';

class RouteNode {
  RouteNode({required this.id, required this.location, Set<RouteNode>? neighbors}) : neighbors = neighbors ?? {};

  final String id;
  final Offset location;
  final Set<RouteNode> neighbors;

  @override
  int get hashCode => Object.hashAll([id, location]);

  @override
  bool operator ==(Object other) =>
      other is RouteNode && location == other.location && id == other.id && neighbors == other.neighbors;

  RouteNode copyWith({Offset? location, Set<RouteNode>? neighbors}) =>
      RouteNode(id: id, location: location ?? this.location, neighbors: neighbors ?? this.neighbors);

  void updateNeighbors((RouteNode? first, RouteNode? second) neighbors) {
    if (neighbors case (final RouteNode first, final RouteNode second)) {
      first.neighbors.remove(second);
      first.neighbors.add(this);
      second.neighbors.remove(first);
      second.neighbors.add(this);
      this.neighbors.addAll([first, second]);
      return;
    }

    if (neighbors.$1 != null) {
      this.neighbors.add(neighbors.$1!);
      neighbors.$1?.neighbors.add(this);
      return;
    }

    if (neighbors.$2 != null) {
      this.neighbors.add(neighbors.$2!);
      neighbors.$2?.neighbors.add(this);
      return;
    }
  }
}
