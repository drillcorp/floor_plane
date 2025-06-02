import 'dart:ui';

import 'package:floor_builder/src/utils/offset_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wall_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class WallDto {
  WallDto(this.points);

  @OffsetConverter()
  Iterable<Offset> points;

  factory WallDto.fromJson(Map<String, dynamic> json) => _$WallDtoFromJson(json);

  Map<String, dynamic> toJson() => _$WallDtoToJson(this);
}
