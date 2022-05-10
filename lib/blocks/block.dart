import 'package:flutter/material.dart';
import '../blocks/point.dart';
import '../pages/game_page.dart';

class Block {
  late String name;
  List<Point> points = [Point(0, 0), Point(0, 0), Point(0, 0), Point(0, 0)];
  late Point rotationCenter;
  late Color color;

  void move(MoveDir dir) {
    switch (dir) {
      case MoveDir.left:
        if (canMoveToSide(-1)) {
          points.forEach((p) {
            p.x--;
          });
        }
        break;
      case MoveDir.right:
        if (canMoveToSide(1)) {
          points.forEach((p) {
            p.x++;
          });
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
    if (!canMoveToSide(0)) {
      rotateLeft();
    }
  }

  void rotateLeft() {
    points.forEach((point) {
      int x = point.x;
      point.x = rotationCenter.x + point.y - rotationCenter.y;
      point.y = rotationCenter.y - x + rotationCenter.x;
    });
    if (!canMoveToSide(0)) {
      rotateRight();
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
