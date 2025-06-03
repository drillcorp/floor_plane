import 'package:floor_builder/floor_builder.dart';
import 'package:json_annotation/json_annotation.dart';

part 'floor_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
final class FloorDto {
  FloorDto({
    required this.id,
    required this.rooms,
    required this.walls,
    required this.floorNumber,
    required this.building,
    required this.height,
    required this.width,
    this.nodes = const {},
  });

  factory FloorDto.fromJson(Map<String, dynamic> json) => _$FloorDtoFromJson(json);

  final String id, floorNumber, building;
  final double height, width;
  final Iterable<RoomDto> rooms;
  final Iterable<WallDto> walls;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final Map<String, Map<String, dynamic>> nodes;

  Map<String, dynamic> toJson() => _$FloorDtoToJson(this);
}
