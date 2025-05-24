import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key, required this.controller});

  final ControlPanelController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        IconButton(onPressed: () {}, icon: Icon(Icons.mouse)), //TODO: это будет просто просмотр
        IconButton(
          //TODO: туту будут рисоваться стены
          onPressed: controller.wallCreateModeHandler,
          icon: Icon(CupertinoIcons.arrow_up_left),
        ),
        IconButton(
          //TODO: рисуем ноды для маршрутов
          onPressed: controller.routeNodeCreateModeHandler,
          icon: Icon(Icons.rectangle_outlined),
        ),
        IconButton(onPressed: controller.routeEdgeCreateModeHandler, icon: Icon(Icons.route)),
        IconButton(onPressed: () {}, icon: Icon(Icons.data_array_sharp)), //TODO: ставить двери4
        IconButton(onPressed: () {}, icon: Icon(Icons.layers)), //показ сетки
        IconButton(onPressed: () {}, icon: Icon(CupertinoIcons.arrow_counterclockwise)), //шаг назад
        IconButton(onPressed: controller.clearHandler, icon: Icon(Icons.clear)), //отчистить все
      ],
    );
  }
}

class ControlPanelController extends Listenable {
  ControlPanelController({
    required this.routeEdgeCreateModeHandler,
    required this.wallCreateModeHandler,
    required this.routeNodeCreateModeHandler,
    required this.clearHandler,
  });

  final VoidCallback wallCreateModeHandler;
  final VoidCallback routeNodeCreateModeHandler;
  final VoidCallback routeEdgeCreateModeHandler;
  final VoidCallback clearHandler;

  @override
  void addListener(VoidCallback listener) {
    //TODO:
  }

  @override
  void removeListener(VoidCallback listener) {
    //TODO:
  }
}
