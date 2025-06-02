import 'package:floor_builder/src/entities/graph_node_dto.dart';
import 'package:floor_builder/src/entities/room_dto.dart';
import 'package:floor_builder/src/entities/wall_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'floor_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
final class FloorDto {
  FloorDto({
    required this.id,
    required this.rooms,
    required this.walls,
    required this.nodes,
    required this.floorNumber,
    required this.building,
    required this.height,
    required this.width,
  });

  factory FloorDto.fromJson(Map<String, dynamic> json) => _$FloorDtoFromJson(json);

  final String id, floorNumber, building;
  final Iterable<RoomDto> rooms;
  final Iterable<WallDto> walls;
  final Iterable<GraphNodeDto> nodes;
  final double height, width;

  Map<String, dynamic> toJson() => _$FloorDtoToJson(this);
}
