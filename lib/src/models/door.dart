import 'graph_node.dart';

class Door extends GraphNode {
  Door({required super.id, required super.location, required this.isVerticalDirection});

  final bool isVerticalDirection;
}
