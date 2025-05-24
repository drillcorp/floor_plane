import 'dart:ui';

class Wall {
  Wall(this.points);

  List<Offset> points;

  @override
  int get hashCode => Object.hashAll([points]);

  @override
  bool operator ==(Object other) => other is Wall && points == other.points;

  Wall copyWith({List<Offset>? points}) => Wall(points ?? this.points);
}
