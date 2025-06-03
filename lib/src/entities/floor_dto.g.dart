// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'floor_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FloorDto _$FloorDtoFromJson(Map<String, dynamic> json) => FloorDto(
  id: json['id'] as String,
  rooms: (json['rooms'] as List<dynamic>).map(
    (e) => RoomDto.fromJson(e as Map<String, dynamic>),
  ),
  walls: (json['walls'] as List<dynamic>).map(
    (e) => WallDto.fromJson(e as Map<String, dynamic>),
  ),
  floorNumber: json['floor_number'] as String,
  building: json['building'] as String,
  height: (json['height'] as num).toDouble(),
  width: (json['width'] as num).toDouble(),
  nodes: (json['nodes'] as List<dynamic>).map(
    (e) => GraphNodeDto.fromJson(e as Map<String, dynamic>),
  ),
);

Map<String, dynamic> _$FloorDtoToJson(FloorDto instance) => <String, dynamic>{
  'id': instance.id,
  'floor_number': instance.floorNumber,
  'building': instance.building,
  'height': instance.height,
  'width': instance.width,
  'rooms': instance.rooms.map((e) => e.toJson()).toList(),
  'walls': instance.walls.map((e) => e.toJson()).toList(),
  'nodes': instance.nodes.map((e) => e.toJson()).toList(),
};
