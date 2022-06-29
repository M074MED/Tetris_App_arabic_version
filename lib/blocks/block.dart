import 'package:flutter/material.dart';
import '../blocks/point.dart';
import '../pages/game_page.dart';

class Block {
  late String name;
  List<Point> points = [Point(0, 0), Point(0, 0), Point(0, 0), Point(0, 0)];
  late Point rotationCenter;
  late Color color;
  int movementNum = 0;
  int rotateNum = 0;
  int translationNum = 0;
  int onDropDownY1 = 0;
  int onDropDownY2 = 0;
  double dropDowns = 0;
  int dropDownCounter = 0;
  int initial_latency = 0;
  int atBottomLat = 0;
  int firstDropDownLat = 0;
  List<String> rotatePattern = [];

  void move(MoveDir dir) {
    switch (dir) {
      case MoveDir.left:
        if (canMoveToSide(-1)) {
          points.forEach((p) {
            p.x--;
          });
          movementNum++;
        }
        break;
      case MoveDir.right:
        if (canMoveToSide(1)) {
          points.forEach((p) {
            p.x++;
          });
          movementNum++;
        }
        break;
      case MoveDir.down:
        points.forEach((p) {
          p.y++;
        });
        break;
    }
  }

  bool canMoveToSide(int moveAmount) {
    bool value = true;
    points.forEach((point) {
      if (point.x + moveAmount < 0 || point.x + moveAmount >= boardWidth) {
        value = false;
      }
    });
    return value;
  }

  void rotateRight() {
    points.forEach((point) {
      int x = point.x;
      point.x = rotationCenter.x - point.y + rotationCenter.y;
      point.y = rotationCenter.y + x - rotationCenter.x;
    });
    movementNum++;
    rotateNum++;
    rotatePattern.add("R");
    if (!canMoveToSide(0)) {
      rotateLeft();
      movementNum--;
      rotateNum--;
      rotatePattern.removeLast();
    }
  }

  void rotateLeft() {
    points.forEach((point) {
      int x = point.x;
      point.x = rotationCenter.x + point.y - rotationCenter.y;
      point.y = rotationCenter.y - x + rotationCenter.x;
    });
    movementNum++;
    rotateNum++;
    rotatePattern.add("L");
    if (!canMoveToSide(0)) {
      rotateRight();
      movementNum--;
      rotateNum--;
      rotatePattern.removeLast();
    }
  }

  bool isAtBottom() {
    int lowestPoint = 0;
    points.forEach((point) {
      if (point.y > lowestPoint) {
        lowestPoint = point.y;
      }
    });

    return lowestPoint >= boardHeight - 1;
  }
}
