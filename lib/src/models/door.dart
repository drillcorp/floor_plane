import 'package:floor_builder/floor_builder.dart';

class Door extends RouteNode {
  Door({required super.id, required super.location, required this.isVerticalDirection});

  final bool isVerticalDirection;

  factory Door.fromEntity(DoorDto entity) =>
      Door(id: entity.id, location: entity.location, isVerticalDirection: entity.isVerticalDirection);

  @override
  T toEntity<T>() {
    return DoorDto(id: id, location: location, isVerticalDirection: isVerticalDirection) as T;
  }
}
