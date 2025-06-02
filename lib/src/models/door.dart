import 'package:floor_builder/src/entities/door_dto.dart';

import 'graph_node.dart';

class Door extends GraphNode {
  Door({required super.id, required super.location, required this.isVerticalDirection});

  final bool isVerticalDirection;

  @override
  DoorDto toEntity() => DoorDto(id: super.id, location: super.location, isVerticalDirection: isVerticalDirection);
}
