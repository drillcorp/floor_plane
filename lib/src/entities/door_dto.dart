import 'dart:ui';

import 'package:floor_builder/src/utils/offset_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'door_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class DoorDto {
  DoorDto({required this.id, required this.location, required this.isVerticalDirection});

  final String id;
  @OffsetConverter()
  final Offset location;
  final bool isVerticalDirection;

  factory DoorDto.fromJson(Map<String, dynamic> json) => _$DoorDtoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DoorDtoToJson(this);
}
