import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';

final class OffsetConverter extends JsonConverter<Offset, Map<String, dynamic>> {
  const OffsetConverter();

  @override
  Offset fromJson(Map<String, dynamic> json) {
    final dx = json['dx'];
    final dy = json['dy'];
    return Offset(dx, dy);
  }

  @override
  Map<String, dynamic> toJson(Offset point) => {'dx': point.dy, 'dy': point.dy};
}
