// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wall_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WallDto _$WallDtoFromJson(Map<String, dynamic> json) => WallDto(
  (json['points'] as List<dynamic>).map(
    (e) => const OffsetConverter().fromJson(e as Map<String, dynamic>),
  ),
);

Map<String, dynamic> _$WallDtoToJson(WallDto instance) => <String, dynamic>{
  'points': instance.points.map(const OffsetConverter().toJson).toList(),
};
