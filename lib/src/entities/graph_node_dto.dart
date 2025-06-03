import 'dart:ui';

import 'package:floor_builder/src/utils/offset_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'graph_node_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class GraphNodeDto {
  GraphNodeDto({required this.id, required this.location, this.isVerticalDoor, Iterable<String>? neighborIds})
    : neighborIds = neighborIds ?? [];

  final String id;
  @OffsetConverter()
  final Offset location;
  final Iterable<String> neighborIds;
  final bool? isVerticalDoor;
  @JsonKey(includeToJson: false, includeFromJson: false)
  List<GraphNodeDto> neighbors = [];

  factory GraphNodeDto.fromJson(Map<String, dynamic> json) => _$GraphNodeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GraphNodeDtoToJson(this);
}
