import 'package:floor_builder/floor_builder.dart';

final class Floor {
  Floor({
    required this.id,
    required this.rooms,
    required this.walls,
    required this.intersections,
    required this.floorNumber,
    required this.building,
    required this.height,
    required this.width,
  });

  final String id, floorNumber, building;
  final double height, width;
  final List<Room> rooms;
  final List<Wall> walls;
  final List<RoutIntersection> intersections;

  Floor copyWith({
    List<Room>? rooms,
    List<Wall>? walls,
    List<RoutIntersection>? nodes,
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
    intersections: nodes ?? this.intersections,
    floorNumber: floorNumber ?? this.floorNumber,
    building: building ?? this.building,
  );

  FloorDto toEntity() => FloorDto(
    id: id,
    rooms: rooms.map((room) => room.toEntity()),
    walls: walls.map((wall) => wall.toEntity()),
    intersections: intersections.map((element) => element.toEntity()),
    doors: rooms.map((element) => element.door?.toEntity<DoorDto>()),
    floorNumber: floorNumber,
    building: building,
    height: height,
    width: width,
  );
}
