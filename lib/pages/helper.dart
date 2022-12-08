import 'package:flutter/material.dart';
import 'package:tetris_app/pages/home_page.dart';
import 'game_page.dart';
import '../blocks/block.dart';
import '../blocks/Iblock.dart';
import '../blocks/Jblock.dart';
import '../blocks/Lblock.dart';
import '../blocks/Sblock.dart';
import '../blocks/SQblock.dart';
import '../blocks/Tblock.dart';
import '../blocks/Zblock.dart';
import 'dart:math';

Block? getRandomBlock() {
  int randomNum = Random().nextInt(7);
  switch (randomNum) {
    case 0:
      return IBlock(boardWidth);
    case 1:
      return JBlock(boardWidth);
    case 2:
      return LBlock(boardWidth);
    case 3:
      return SBlock(boardWidth);
    case 4:
      return SQBlock(boardWidth);
    case 5:
      return TBlock(boardWidth);
    case 6:
      return ZBlock(boardWidth);
    default:
      return null;
  }
}

Widget getTetrisPoint(Color color) {
  return Container(
    width: pointSize,
    height: pointSize,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.rectangle,
    ),
  );
}

Widget getGameOverText(int score) {
  return Center(
    child: Directionality(
      textDirection: TextDirection.rtl,
      child: Text(
        "انتهت اللعبة${showScore ? "\nالنتيجة النهائية:\n" + score.toString() : ""}",
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.blue,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 3,
                offset: Offset(2, 2),
              )
            ]),
      ),
    ),
  );
}

void showSnackBar(BuildContext context, String message) {
  final snackBar = SnackBar(
    duration: const Duration(milliseconds: 2500),
    elevation: 10,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
      topLeft: Radius.circular(5),
      topRight: Radius.circular(5),
    )),
    backgroundColor: Colors.red,
    content: Directionality(
      textDirection: TextDirection.rtl,
      child: Text(message),
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
