import 'dart:ui';

import 'package:floor_builder/src/utils/rect_convertor.dart';
import 'package:json_annotation/json_annotation.dart';

part 'room_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class RoomDto {
  RoomDto({required this.id, required this.name, required this.rect, this.doorId});

  final String id;
  final String name;
  @RectConvertor()
  final Rect rect;
  final String? doorId;

  factory RoomDto.fromJson(Map<String, dynamic> json) => _$RoomDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RoomDtoToJson(this);
}
