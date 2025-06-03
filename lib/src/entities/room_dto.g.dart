// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomDto _$RoomDtoFromJson(Map<String, dynamic> json) => RoomDto(
  id: json['id'] as String,
  name: json['name'] as String,
  rect: const RectConvertor().fromJson(json['rect'] as Map<String, dynamic>),
  doorId: json['door_id'] as String?,
);

Map<String, dynamic> _$RoomDtoToJson(RoomDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'rect': const RectConvertor().toJson(instance.rect),
  'door_id': instance.doorId,
};
