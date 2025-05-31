import 'dart:ui';

import 'package:floor_builder/entities/door.dart';
import 'package:floor_builder/utils/rect_convertor.dart';
import 'package:json_annotation/json_annotation.dart';

part 'room.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Room {
  Room({required this.id, required this.name, required this.rect, this.door});

  final String id;
  final String name;
  @RectConvertor()
  final Rect rect;
  final Door? door;

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

  @override
  int get hashCode => Object.hashAll([id, name, door]);

  @override
  operator ==(Object other) =>
      other is Room && other.id == id && other.name == name && other.door == door && other.rect == rect;

  Room copyWith({String? id, String? name, Rect? rect, Door? door}) =>
      Room(id: id ?? this.id, name: name ?? this.name, rect: rect ?? this.rect, door: door ?? this.door);

  Map<String, dynamic> toJson() => _$RoomToJson(this);
}
