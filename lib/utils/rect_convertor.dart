import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';

final class RectConvertor extends JsonConverter<Rect, Map<String, dynamic>> {
  const RectConvertor();

  @override
  Rect fromJson(Map<String, dynamic> json) {
    final center = json['center'];
    final height = json['height'];
    final width = json['width'];
    return Rect.fromCenter(center: center, width: width, height: height);
  }

  @override
  Map<String, dynamic> toJson(Rect rect) => {
    'width': rect.width,
    'height': rect.height,
    'center': rect.center,
    'size': rect.size,
    'top_left': rect.topLeft,
    'bottom_right': rect.bottomRight,
  };
}
