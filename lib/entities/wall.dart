import 'dart:ui';

class Wall {
  Wall({required this.startPoint, required this.endPoint});

  final Offset startPoint;
  final Offset endPoint;

  @override
  int get hashCode => Object.hashAll([startPoint, endPoint]);

  @override
  bool operator ==(Object other) => other is Wall && startPoint == other.startPoint && endPoint == other.endPoint;

  Wall copyWith({Offset? startPoint, Offset? endPoint}) =>
      Wall(startPoint: startPoint ?? this.startPoint, endPoint: endPoint ?? this.endPoint);
}
