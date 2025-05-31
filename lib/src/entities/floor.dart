import 'package:floor_builder/src/entities/graph_node.dart';
import 'package:floor_builder/src/entities/room.dart';
import 'package:floor_builder/src/entities/wall.dart';
import 'package:json_annotation/json_annotation.dart';

part 'floor.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class Floor {
  Floor({
    required this.rooms,
    required this.walls,
    required this.nodes,
    required this.floorNumber,
    required this.building,
  });

  factory Floor.fromJson(Map<String, dynamic> json) => _$FloorFromJson(json);

  final List<Room> rooms;
  final List<Wall> walls;
  final List<GraphNode> nodes;
  final String floorNumber;
  final String building;

  Map<String, dynamic> toJson() => _$FloorToJson(this);

  Floor copyWith({
    List<Room>? rooms,
    List<Wall>? walls,
    List<GraphNode>? nodes,
    String? floorNumber,
    String? building,
  }) => Floor(
    rooms: rooms ?? this.rooms,
    walls: walls ?? this.walls,
    nodes: nodes ?? this.nodes,
    floorNumber: floorNumber ?? this.floorNumber,
    building: building ?? this.building,
  );
}
