import 'package:floor_builder/floor_builder.dart';

class Door extends GraphNode {
  Door({required super.id, required super.location, required this.isVerticalDirection});

  final bool isVerticalDirection;

  @override
  GraphNodeDto toEntity() => DoorDto(id: id, location: location, isVerticalDirection: isVerticalDirection);
}
