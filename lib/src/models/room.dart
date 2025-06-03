import 'dart:ui';

import 'package:floor_builder/floor_builder.dart';

class Room {
  Room({required this.id, required this.name, required this.rect, this.door});

  final String id;
  final String name;
  final Rect rect;
  final GraphNode? door;

  @override
  int get hashCode => Object.hashAll([id, name, door]);

  @override
  operator ==(Object other) =>
      other is Room && other.id == id && other.name == name && other.door == door && other.rect == rect;

  Room copyWith({String? id, String? name, Rect? rect, GraphNode? door}) =>
      Room(id: id ?? this.id, name: name ?? this.name, rect: rect ?? this.rect, door: door ?? this.door);

  RoomDto toEntity() => RoomDto(id: id, name: name, rect: rect, doorId: door?.id);
}
