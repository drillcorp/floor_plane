import 'dart:ui';

import 'package:floor_builder/utils/offset_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wall.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Wall {
  Wall(this.points);

  @OffsetConverter()
  List<Offset> points;

  factory Wall.fromJson(Map<String, dynamic> json) => _$WallFromJson(json);

  @override
  int get hashCode => Object.hashAll([points]);

  @override
  bool operator ==(Object other) => other is Wall && points == other.points;

  Wall copyWith({List<Offset>? points}) => Wall(points ?? this.points);

  Map<String, dynamic> toJson() => _$WallToJson(this);
}
