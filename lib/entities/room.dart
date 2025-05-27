import 'dart:ui';

import 'package:floor_builder/entities/door.dart';

class Room {
  Room({required this.id, required this.name, required this.rect, this.door});

  final String id;
  final String name;
  final Rect rect;
  final Door? door;

  @override
  int get hashCode => Object.hashAll([id, name, door]);

  @override
  operator ==(Object other) =>
      other is Room && other.id == id && other.name == name && other.door == door && other.rect == rect;

  Room copyWith({String? id, String? name, Rect? rect, Door? door}) =>
      Room(id: id ?? this.id, name: name ?? this.name, rect: rect ?? this.rect, door: door ?? this.door);
}
