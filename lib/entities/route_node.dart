import 'package:floor_builder/entities/route_edge.dart';
import 'package:flutter/cupertino.dart';

class RouteNode {
  RouteNode({required this.rect, this.edges = const []});

  final Rect rect;
  final List<RouteEdge> edges;

  @override
  int get hashCode => Object.hashAll([rect, ...edges]);

  @override
  bool operator ==(Object other) => other is RouteNode && rect == other.rect && edges == other.edges;

  RouteNode copyWith({Rect? rect, List<RouteEdge>? edges}) =>
      RouteNode(rect: rect ?? this.rect, edges: edges ?? this.edges);
}
