import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum FloorBuilderMode { showing, createRooms, createWalls, createDoor, addNode }

class ControlPanel extends StatefulWidget {
  const ControlPanel({super.key, required this.controller});

  final ControlPanelController controller;

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  FloorBuilderMode _currentMode = FloorBuilderMode.showing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        IconButton(
          color: _currentMode == FloorBuilderMode.showing ? Colors.blueAccent : null,
          onPressed: () {
            setState(() => _currentMode = FloorBuilderMode.showing);
            widget.controller.value = FloorBuilderMode.showing;
          },
          icon: Icon(Icons.mouse),
        ),
        IconButton(
          color: _currentMode == FloorBuilderMode.addNode ? Colors.blueAccent : null,
          onPressed: () {
            setState(() => _currentMode = FloorBuilderMode.addNode);
            widget.controller.value = FloorBuilderMode.addNode;
          },
          icon: Icon(Icons.add_box),
        ),
        IconButton(
          color: _currentMode == FloorBuilderMode.createWalls ? Colors.blueAccent : null,
          onPressed: () {
            setState(() => _currentMode = FloorBuilderMode.createWalls);
            widget.controller.value = FloorBuilderMode.createWalls;
          },
          icon: Icon(CupertinoIcons.arrow_up_left),
        ),
        IconButton(
          color: _currentMode == FloorBuilderMode.createRooms ? Colors.blueAccent : null,
          onPressed: () {
            setState(() => _currentMode = FloorBuilderMode.createRooms);
            widget.controller.value = FloorBuilderMode.createRooms;
          },
          icon: Icon(Icons.rectangle_outlined),
        ),
        IconButton(
          color: _currentMode == FloorBuilderMode.createDoor ? Colors.blueAccent : null,
          onPressed: () {
            setState(() => _currentMode = FloorBuilderMode.createDoor);
            widget.controller.value = FloorBuilderMode.createDoor;
          },
          icon: Icon(Icons.data_array_sharp),
        ),
        IconButton(onPressed: widget.controller.onSwitchShowingGrid, icon: Icon(Icons.layers)),
        IconButton(onPressed: () {}, icon: Icon(CupertinoIcons.arrow_counterclockwise)),
        IconButton(onPressed: widget.controller.onClear, icon: Icon(Icons.clear)),
      ],
    );
  }
}

class ControlPanelController extends ValueNotifier<FloorBuilderMode> {
  ControlPanelController({this.onClear, this.onSwitchShowingGrid}) : super(FloorBuilderMode.showing);

  final VoidCallback? onClear, onSwitchShowingGrid;
}
