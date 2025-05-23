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

  void verticalAxisNeighbors((RouteNode? top, RouteNode? bottom) neighbors) {}

  void horizontalAxisNeighbors((RouteNode? left, RouteNode? right) neighbors) {}
}
