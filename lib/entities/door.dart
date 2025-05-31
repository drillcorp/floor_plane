import 'package:floor_builder/entities/route_node.dart';

class Door extends GraphNode {
  Door({required this.isVerticalDirection, required super.id, required super.location});

  final bool isVerticalDirection;
}
