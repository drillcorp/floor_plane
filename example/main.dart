import 'package:floor_builder/a_star.dart';
import 'package:floor_builder/entities/room.dart';
import 'package:floor_builder/widgets/bakcground_grid.dart';
import 'package:floor_builder/widgets/door_widget.dart';
import 'package:floor_builder/widgets/floor_plan_widget.dart';
import 'package:floor_builder/widgets/line_frame.dart';
import 'package:floor_builder/widgets/path_painter.dart';
import 'package:floor_builder/widgets/room_frame.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'control_buttons.dart';
import 'floor_builder.dart';

void main() {
  runApp(MaterialApp(home: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

enum DirectionType { arrowLeft, arrowRight }

class DirectionIntent extends Intent {
  final DirectionType direction;
  const DirectionIntent(this.direction);
}

class _MyAppState extends State<MyApp> {
  final FloorBuilder _floorBuilder = FloorBuilder(cellGridSize: 20);

  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  final FocusNode _focusNode = FocusNode();

  late final ControlPanelController _controlPanelController;
  late FloorBuilderMode _builderMode;
  bool _isShowGrid = true;
  bool _isVerticalDoor = true;

  Offset? _startPosition;
  Offset? _updatePosition;

  List<Offset> _routePath = [];

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();

    _controlPanelController = ControlPanelController(
      modeListener: (mode) => _builderMode = mode,
      onSwitchShowingGrid: () => setState(() => _isShowGrid = !_isShowGrid),
      onClear: _floorBuilder.clearState,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.arrowLeft): const DirectionIntent(DirectionType.arrowLeft),
          LogicalKeySet(LogicalKeyboardKey.arrowRight): const DirectionIntent(DirectionType.arrowRight),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            DirectionIntent: CallbackAction<DirectionIntent>(
              onInvoke: (intent) {
                if (intent.direction == DirectionType.arrowLeft) {
                  setState(() => _isVerticalDoor = !_isVerticalDoor);
                }
                if (intent.direction == DirectionType.arrowRight) {
                  setState(() => _isVerticalDoor = !_isVerticalDoor);
                }
                return null;
              },
            ),
          },
          child: Focus(
            focusNode: _focusNode,
            autofocus: true,
            skipTraversal: true,
            canRequestFocus: true,
            child: Scaffold(
              drawer: Drawer(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 30,
                    children: [
                      TextField(
                        controller: _fromController,
                        decoration: InputDecoration(hint: Text('from')),
                      ),
                      TextField(
                        controller: _toController,
                        decoration: InputDecoration(hint: Text('to')),
                      ),
                    ],
                  ),
                ),
              ),
              appBar: AppBar(
                actions: [
                  ElevatedButton(
                    onPressed: _buildRoutePath,
                    child: Center(child: Text('Create path')),
                  ),
                ],
              ),
              floatingActionButton: ControlPanel(controller: _controlPanelController),
              floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
              body: InteractiveViewer(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    _floorBuilder.sceneHeight = constraints.maxHeight;
                    _floorBuilder.sceneWidth = constraints.maxWidth;

                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      supportedDevices: {PointerDeviceKind.mouse},
                      onTapDown: switch (_builderMode) {
                        FloorBuilderMode.addNode => _createGraphNode,
                        _ => null,
                      },
                      onPanStart: switch (_builderMode) {
                        FloorBuilderMode.createRooms => onPanStartForCreateRoom,
                        FloorBuilderMode.createWalls => (startDetail) {
                          final nearest = _floorBuilder.findNearestPoint(startDetail.localPosition);
                          setState(() => _startPosition = nearest);
                        },
                        _ => null,
                      },

                      onPanUpdate: switch (_builderMode) {
                        FloorBuilderMode.createDoor => onPanUpdateForCreateDoor,
                        FloorBuilderMode.createRooms => onPanUpdateForCreateRoom,
                        FloorBuilderMode.createWalls => (updateDetail) {
                          setState(() {
                            _updatePosition = updateDetail.localPosition;
                          });
                        },
                        _ => null,
                      },

                      onPanEnd: switch (_builderMode) {
                        FloorBuilderMode.createDoor => onPanEndForCreateDoor,
                        FloorBuilderMode.createRooms => onPanEndForCreateRoom,
                        FloorBuilderMode.createWalls => _onPanUpdateForCreateWall,
                        _ => null,
                      },

                      child: ListenableBuilder(
                        listenable: _floorBuilder,
                        builder: (context, _) {
                          return SizedBox(
                            height: _floorBuilder.sceneHeight,
                            width: _floorBuilder.sceneWidth,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (_isShowGrid) BackgroundGrid(cellSize: _floorBuilder.cellGridSize),
                                if (_builderMode == FloorBuilderMode.createRooms &&
                                    _startPosition != null &&
                                    _updatePosition != null)
                                  RoomFrame(rect: Rect.fromPoints(_startPosition!, _updatePosition!)),

                                if (_builderMode == FloorBuilderMode.createWalls &&
                                    _startPosition != null &&
                                    _updatePosition != null)
                                  LineFrame(start: _startPosition!, end: _updatePosition!),

                                FloorPlan(
                                  walls: _floorBuilder.state.walls,
                                  routeNodes: _floorBuilder.state.graphNodes,
                                  rooms: _floorBuilder.state.rooms,
                                ),

                                if (_builderMode == FloorBuilderMode.createDoor && _updatePosition != null)
                                  DoorWidget(location: _updatePosition!, isVertical: _isVerticalDoor),
                                if (_routePath.isNotEmpty) PathPainter(path: _routePath),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onPanStartForCreateRoom(DragStartDetails detail) {
    final startPosition = _floorBuilder.findNearestPoint(detail.localPosition);
    setState(() => _startPosition = startPosition);
  }

  void onPanUpdateForCreateRoom(DragUpdateDetails detail) => setState(() => _updatePosition = detail.localPosition);

  Future<void> onPanEndForCreateRoom(DragEndDetails detail) async {
    final name = await EnterRoomNameDialog.show<String>(context);
    if (name == null) return;
    _floorBuilder.createRoomFromPoints(start: _startPosition!, end: detail.localPosition, name: '');
    _startPosition = null;
    _updatePosition = null;
  }

  void onPanUpdateForCreateDoor(DragUpdateDetails detail) {
    setState(() => _updatePosition = detail.localPosition);
  }

  void onPanEndForCreateDoor(DragEndDetails detail) =>
      _floorBuilder.createDoor(detail.localPosition, isVertical: _isVerticalDoor);

  void _buildRoutePath() {
    final start = _findRoomByName(_fromController.text);
    final end = _findRoomByName(_toController.text);
    if (start != null && end != null) {
      final aStar = RoutePathFinder(start: start.door!, end: end.door!);
      final routePath = aStar.calculateRoute();
      setState(() => _routePath = routePath.toList());
      _toController.clear();
      _fromController.clear();
    }
  }

  void _onPanUpdateForCreateWall(DragEndDetails detail) {
    _floorBuilder.createWall(start: _startPosition!, end: detail.localPosition);
    _startPosition = null;
    _updatePosition = null;
  }

  Room? _findRoomByName(String name) {
    for (final room in _floorBuilder.state.rooms) {
      if (room.name == name) return room;
    }

    return null;
  }

  void _createGraphNode(TapDownDetails details) => _floorBuilder.createGraphNode(details.localPosition);

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }
}

class EnterRoomNameDialog extends StatefulWidget {
  const EnterRoomNameDialog({super.key});

  static Future<T?> show<T>(BuildContext context) =>
      showDialog<T>(context: context, builder: (context) => EnterRoomNameDialog());

  @override
  State<EnterRoomNameDialog> createState() => _EnterRoomNameDialogState();
}

class _EnterRoomNameDialogState extends State<EnterRoomNameDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: 400,
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 100,
            children: [
              TextField(controller: _controller),
              ElevatedButton(onPressed: () => Navigator.pop(context, _controller.text), child: Text('Save')),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
