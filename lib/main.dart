import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

final class Room {
  Room({required this.rect, this.name = 'Room Name', this.doorCoordinates});

  final String name;
  final Rect rect;
  final (Offset start, Offset end)? doorCoordinates;
}

class _MyAppState extends State<MyApp> {
  int? _currentSelectRect;
  double _gridSize = 20;
  bool _isShowGrid = true;
  bool _isCheckMode = true;
  bool _isCreateDoor = false;
  Offset? _startPosition;
  Offset? _updatePosition;
  final List<Room> _rects = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: _ControlButtons(
          isShowGrid: _isShowGrid,
          onCheckMode: () => setState(() => _isCheckMode = true),
          isCheckMode: _isCheckMode,
          onChangeShowingGrid: () => setState(() => _isShowGrid = !_isShowGrid),
          onClear: () => setState(() => _rects.clear()),
          removeLastAction: () => setState(() => _rects.removeLast()),
          onCreateDoor:
              () => setState(() {
                _isCreateDoor = true;
              }),
          onCreateMode: () => setState(() => _isCheckMode = false),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        body: InteractiveViewer(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                supportedDevices: {PointerDeviceKind.mouse},
                onPanStart:
                    !_isCheckMode
                        ? (startDetail) {
                          final nearest = _findNearestPoint(startDetail.globalPosition, _gridSize);
                          setState(() => _startPosition = nearest);
                        }
                        : null,
                onPanUpdate:
                    !_isCheckMode
                        ? (updateDetail) {
                          setState(() {
                            _updatePosition = updateDetail.globalPosition;
                          });
                        }
                        : null,
                onPanEnd:
                    !_isCheckMode
                        ? (endDetail) {
                          setState(() {
                            final nearestEnd = _findNearestPoint(endDetail.globalPosition, _gridSize);
                            _rects.add(Room(rect: Rect.fromPoints(_startPosition ?? Offset.zero, nearestEnd)));
                            _startPosition = null;
                            _updatePosition = null;
                          });
                        }
                        : null,
                child: SizedBox(
                  height: constraints.maxHeight,
                  width: constraints.maxWidth,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_isShowGrid) _BackgroundGrid(gridSize: _gridSize),
                      CustomPaint(painter: RectPaint(startPointer: _startPosition, endPointer: _updatePosition)),
                      ..._rects.mapIndexed((i, item) => RectWidget(title: item.name, rect: item.rect)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Offset _findNearestPoint(Offset currentPoint, double gridSize) {
    final dx = (currentPoint.dx / gridSize).round() * gridSize;
    final dy = (currentPoint.dy / gridSize).round() * gridSize;
    return Offset(dx, dy);
  }
}

class DoorWidget extends StatelessWidget {
  const DoorWidget(this.start, this.end);

  final Offset start, end;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DoorWidgetPainter(start, end));
  }
}

final class _DoorWidgetPainter extends CustomPainter {
  _DoorWidgetPainter(this.start, this.end);

  final Offset start, end;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2;

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RectWidget extends StatelessWidget {
  const RectWidget({
    required this.title,
    required this.rect,
    this.isSelect = false,
    this.onTap,
    this.doorPoints,
    super.key,
  });

  final String title;
  final Rect rect;
  final bool isSelect;
  final VoidCallback? onTap;
  final (Offset start, Offset end)? doorPoints;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: rect.size.width,
      height: rect.size.height,
      child: CustomPaint(
        painter: RectPaint(
          title: title,
          startPointer: rect.topLeft,
          endPointer: rect.bottomRight,
          doorPoints: doorPoints,
        ),
      ),
    );
  }
}

final class RectPaint extends CustomPainter {
  RectPaint({this.startPointer, this.endPointer, this.doorPoints, this.title = ''});

  final Offset? startPointer;
  final Offset? endPointer;
  final String title;
  final (Offset start, Offset end)? doorPoints;

  @override
  void paint(Canvas canvas, Size size) {
    if (startPointer != null && endPointer != null) {
      final paint =
          Paint()
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 2
            ..color = Colors.black
            ..style = PaintingStyle.stroke;
      final rect = Rect.fromPoints(startPointer!, endPointer!);
      canvas.drawRect(rect, paint);
    }
    if (doorPoints case (Offset start, Offset end)) {
      final paint =
          Paint()
            ..strokeWidth = 2
            ..color = Colors.white;
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(RectPaint oldDelegate) =>
      startPointer != oldDelegate.startPointer || endPointer != oldDelegate.endPointer; //TODO:
}

class _BackgroundGrid extends StatelessWidget {
  const _BackgroundGrid({required this.gridSize});

  final double gridSize;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _BackgroundGridPainter(gridSize));
  }
}

final class _BackgroundGridPainter extends CustomPainter {
  _BackgroundGridPainter(this.gridSize);

  final double gridSize;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPain =
        Paint()
          ..strokeWidth = 1
          ..color = Colors.black12;

    final maxDimension = max(size.height, size.width);

    for (double i = 0; i < maxDimension; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPain);
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPain);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ControlButtons extends StatelessWidget {
  const _ControlButtons({
    required this.onCreateDoor,
    required this.onCheckMode,
    required this.onClear,
    required this.removeLastAction,
    required this.onChangeShowingGrid,
    required this.onCreateMode,
    this.isShowGrid = false,
    this.isCheckMode = true,
    this.isDoorCreate = false,
  });

  final VoidCallback onCreateDoor;
  final VoidCallback onCreateMode;
  final VoidCallback onCheckMode;
  final VoidCallback onClear;
  final VoidCallback onChangeShowingGrid;
  final VoidCallback removeLastAction;
  final bool isShowGrid, isCheckMode, isDoorCreate;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        IconButton(
          color: isCheckMode ? Colors.blueAccent : Colors.black,
          onPressed: onCheckMode,
          icon: Icon(CupertinoIcons.arrow_up_left),
        ),
        IconButton(
          color: !isCheckMode ? Colors.blueAccent : Colors.black,
          onPressed: onCreateMode,
          icon: Icon(Icons.rectangle_outlined),
        ),
        IconButton(onPressed: onCreateDoor, icon: Icon(Icons.data_array_sharp)),
        IconButton(onPressed: onChangeShowingGrid, icon: Icon(isShowGrid ? Icons.layers : Icons.layers_outlined)),
        IconButton(onPressed: removeLastAction, icon: Icon(CupertinoIcons.arrow_counterclockwise)),
        IconButton(onPressed: onClear, icon: Icon(Icons.clear)),
      ],
    );
  }
}
