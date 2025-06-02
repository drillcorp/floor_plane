import 'package:floor_builder/src/entities/graph_node_dto.dart';
import 'package:floor_builder/src/utils/offset_converter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'door_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class DoorDto extends GraphNodeDto {
  DoorDto({required super.id, required super.location, required this.isVerticalDirection});

  final bool isVerticalDirection;

  factory DoorDto.fromJson(Map<String, dynamic> json) => _$DoorDtoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DoorDtoToJson(this);
}
