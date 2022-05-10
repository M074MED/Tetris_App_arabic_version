import 'package:flutter/material.dart';
import 'package:tetris_app/blocks/point.dart';

class AlivePoint extends Point {
  Color color;
  AlivePoint(int x, int y, this.color) : super(x, y);

  bool checkIfPointsCollide(List<Point> pointList, {int Ydistance = 1}) {
    bool value = false;
    pointList.forEach((pointToCheck) {
      if ((pointToCheck.x == x && pointToCheck.y == y - Ydistance)) {
        value = true;
      }
    });
    return value;
  }
}
