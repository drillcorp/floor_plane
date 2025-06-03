// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'door_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DoorDto _$DoorDtoFromJson(Map<String, dynamic> json) => DoorDto(
  id: json['id'] as String,
  location: const OffsetConverter().fromJson(
    json['location'] as Map<String, dynamic>,
  ),
  isVerticalDirection: json['is_vertical_direction'] as bool,
);

Map<String, dynamic> _$DoorDtoToJson(DoorDto instance) => <String, dynamic>{
  'id': instance.id,
  'location': const OffsetConverter().toJson(instance.location),
  'is_vertical_direction': instance.isVerticalDirection,
};
