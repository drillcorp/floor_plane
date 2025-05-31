import 'package:floor_builder/src/utils/offset_converter.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'graph_node.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class GraphNode {
  GraphNode({required this.id, required this.location, Set<GraphNode>? neighbors}) : neighbors = neighbors ?? {};

  final String id;
  @OffsetConverter()
  final Offset location;
  final Set<GraphNode> neighbors;

  factory GraphNode.fromJson(Map<String, dynamic> json) => _$GraphNodeFromJson(json);

  @override
  int get hashCode => Object.hashAll([id, location]);

  @override
  bool operator ==(Object other) =>
      other is GraphNode && location == other.location && id == other.id && neighbors == other.neighbors;

  GraphNode copyWith({Offset? location, Set<GraphNode>? neighbors}) =>
      GraphNode(id: id, location: location ?? this.location, neighbors: neighbors ?? this.neighbors);

  void updateNeighbors((GraphNode? first, GraphNode? second) neighbors) {
    if (neighbors case (final GraphNode first, final GraphNode second)) {
      first.neighbors.remove(second);
      first.neighbors.add(this);
      second.neighbors.remove(first);
      second.neighbors.add(this);
      this.neighbors.addAll([first, second]);
      return;
    }

    if (neighbors.$1 != null) {
      this.neighbors.add(neighbors.$1!);
      neighbors.$1?.neighbors.add(this);
      return;
    }

    if (neighbors.$2 != null) {
      this.neighbors.add(neighbors.$2!);
      neighbors.$2?.neighbors.add(this);
      return;
    }
  }

  Map<String, dynamic> toJson() => _$GraphNodeToJson(this);
}
