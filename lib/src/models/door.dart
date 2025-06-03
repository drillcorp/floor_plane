import 'package:floor_builder/floor_builder.dart';

class Door extends GraphNode {
  Door({required super.id, required super.location, required this.isVerticalDirection});

  final bool isVerticalDirection;

  factory Door.fromEntity(DoorDto entity) =>
      Door(id: entity.id, location: entity.location, isVerticalDirection: entity.isVerticalDirection);

  @override
  GraphNodeDto toEntity() => DoorDto(id: id, location: location, isVerticalDirection: isVerticalDirection);
}
