import 'package:floor_builder/src/entities/graph_node.dart';
import 'package:floor_builder/src/utils/offset_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'door.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Door extends GraphNode {
  Door({required super.id, required super.location, required this.isVerticalDirection});

  final bool isVerticalDirection;

  factory Door.fromJson(Map<String, dynamic> json) => _$DoorFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DoorToJson(this);
}
