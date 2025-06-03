// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'graph_node_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GraphNodeDto _$GraphNodeDtoFromJson(Map<String, dynamic> json) => GraphNodeDto(
  id: json['id'] as String,
  location: const OffsetConverter().fromJson(
    json['location'] as Map<String, dynamic>,
  ),
  neighbors: (json['neighbors'] as List<dynamic>?)?.map((e) => e as String),
);

Map<String, dynamic> _$GraphNodeDtoToJson(GraphNodeDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'location': const OffsetConverter().toJson(instance.location),
      'neighbors': instance.neighbors.toList(),
    };
