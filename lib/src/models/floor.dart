import 'package:floor_builder/src/entities/floor_dto.dart';
import 'package:floor_builder/src/models/graph_node.dart';
import 'package:floor_builder/src/models/room.dart';
import 'package:floor_builder/src/models/wall.dart';

final class Floor {
  Floor({
    required this.id,
    required this.rooms,
    required this.walls,
    required this.nodes,
    required this.floorNumber,
    required this.building,
    required this.height,
    required this.width,
  });

  final String id, floorNumber, building;
  final double height, width;
  final List<Room> rooms;
  final List<Wall> walls;
  final List<GraphNode> nodes;

  Floor copyWith({
    List<Room>? rooms,
    List<Wall>? walls,
    List<GraphNode>? nodes,
    String? floorNumber,
    String? building,
    double? height,
    double? width,
  }) => Floor(
    id: id,
    height: height ?? this.height,
    width: width ?? this.width,
    rooms: rooms ?? this.rooms,
    walls: walls ?? this.walls,
    nodes: nodes ?? this.nodes,
    floorNumber: floorNumber ?? this.floorNumber,
    building: building ?? this.building,
  );

  FloorDto toEntity() => FloorDto(
    id: id,
    rooms: rooms.map((room) => room.toEntity()),
    walls: walls.map((wall) => wall.toEntity()),
    nodes: {for (final item in nodes) item.id: item.toEntity().toJson()},
    floorNumber: floorNumber,
    building: building,
    height: height,
    width: width,
  );
}
