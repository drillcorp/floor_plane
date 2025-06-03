import 'dart:ui';

import 'package:floor_builder/src/utils/offset_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'graph_node_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class RouteIntersectionDto {
  RouteIntersectionDto({required this.id, required this.location, Iterable<String>? neighbors})
    : neighbors = neighbors ?? [];

  final String id;
  @OffsetConverter()
  final Offset location;
  final Iterable<String> neighbors;

  factory RouteIntersectionDto.fromJson(Map<String, dynamic> json) => _$RouteIntersectionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RouteIntersectionDtoToJson(this);
}
