import 'package:flutter/cupertino.dart';

class RouteEdge {
  RouteEdge({required this.startPoint, required this.endPoint});

  final Offset startPoint;
  final Offset endPoint;

  @override
  int get hashCode => Object.hashAll([startPoint, endPoint]);

  @override
  bool operator ==(Object other) => other is RouteEdge && startPoint == other.startPoint && endPoint == other.endPoint;

  RouteEdge copyWith({Offset? startPoint, Offset? endPoint}) =>
      RouteEdge(startPoint: startPoint ?? this.startPoint, endPoint: endPoint ?? this.endPoint);
}
