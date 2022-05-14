import 'dart:async';
import 'dart:math';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tetris_app/blocks/Iblock.dart';
import 'package:tetris_app/blocks/Lblock.dart';
import 'package:tetris_app/blocks/alivePoints.dart';
import 'package:tetris_app/blocks/block.dart';
import 'package:tetris_app/pages/helper.dart';

import '../blocks/Jblock.dart';
import '../blocks/SQblock.dart';
import '../blocks/Sblock.dart';
import '../blocks/Tblock.dart';
import '../blocks/Zblock.dart';

enum LastButtonPressed { left, right, rotateLeft, rotateRight, none }
enum MoveDir { left, right, down }

// Global Variables
const int boardWidth = 15;
const int boardHeight = 20;
const double pointSize = 20; // size in px
const double width = boardWidth * pointSize;
const double height = boardHeight * pointSize;
const int gameSpeed = 400; // speed in milliseconds
late Timer timer;

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  LastButtonPressed performAction = LastButtonPressed.none;
  Block? currentBlock;
  Block? nextBlock;
  List<AlivePoint> alivePoints = [];
  int score = 0;
  bool gameOver = false;
  Color? borderColor;
  double meanHeight = 0;
  int maxHeight = 0;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    setState(() {
      currentBlock = getRandomBlock();
      nextBlock = getRandomBlock();
    });
    timer = Timer.periodic(
      const Duration(milliseconds: gameSpeed),
      onTimeTick,
    );
  }

  void checkForUserInput() {
    if (performAction != LastButtonPressed.none) {
      setState(() {
        switch (performAction) {
          case LastButtonPressed.left:
            currentBlock!.move(MoveDir.left);
            if (isAboveOldBlock(Ydistance: 0)) {
              currentBlock!.move(MoveDir.right);
              currentBlock!.movementNum--;
            }
            break;
          case LastButtonPressed.right:
            currentBlock!.move(MoveDir.right);
            if (isAboveOldBlock(Ydistance: 0)) {
              currentBlock!.move(MoveDir.left);
              currentBlock!.movementNum--;
            }
            break;
          case LastButtonPressed.rotateLeft:
            currentBlock!.rotateLeft();
            if (isAboveOldBlock(Ydistance: 0) ||
                currentBlock!.isAtBottom() ||
                currentBlock!.name == "SQBlock") {
              currentBlock!.rotateRight();
              currentBlock!.movementNum--;
            }
            break;
          case LastButtonPressed.rotateRight:
            currentBlock!.rotateRight();
            if (isAboveOldBlock(Ydistance: 0) ||
                currentBlock!.isAtBottom() ||
                currentBlock!.name == "SQBlock") {
              currentBlock!.rotateLeft();
              currentBlock!.movementNum--;
            }
            break;
          default:
            break;
        }
        performAction = LastButtonPressed.none;
      });
    }
  }

  void saveOldBlock() {
    currentBlock!.points.forEach((point) {
      AlivePoint newPoint = AlivePoint(point.x, point.y, currentBlock!.color);
      setState(() {
        alivePoints.add(newPoint);
      });
    });
  }

  bool isAboveOldBlock({int Ydistance = 1}) {
    bool value = false;
    alivePoints.forEach((oldPoint) {
      if (oldPoint.checkIfPointsCollide(currentBlock!.points,
          Ydistance: Ydistance)) {
        value = true;
      }
    });
    return value;
  }

  void removeRow(int row) {
    setState(() {
      alivePoints.removeWhere((point) => point.y == row);
      alivePoints.forEach((point) {
        if (point.y < row) {
          point.y += 1;
        }
      });
      score++;
    });
  }

  void removeFullRows() {
    for (var currentRow = 0; currentRow < boardHeight; currentRow++) {
      int counter = 0;
      alivePoints.forEach((point) {
        if (point.y == currentRow) {
          counter++;
        }
      });
      if (counter >= boardWidth) {
        removeRow(currentRow);
      }
    }
  }

  void getPitsAndWells() {
    List<Point> allPoints = [];
    List<Point> pits = [];
    List<Point> wells = [];
    alivePoints.forEach((point) {
      allPoints.add(Point(point.x, point.y));
    });
    for (var currentRow = 0; currentRow < maxHeight; currentRow++) {
      int y = (boardHeight - 1) - currentRow;
      for (var i = 0; i < boardWidth; i++) {
        Point currentPoint = Point(i, y);
        if ((!allPoints.contains(currentPoint)) &&
            allPoints.contains(Point(i, y - 1))) {
          pits.add(currentPoint);
        } else if ((!allPoints.contains(currentPoint)) &&
            (!allPoints.contains(Point(i, y - 1)))) {
          wells.add(currentPoint);
        }
      }
    }
    print("Pits num: ${pits.length}, Wells num: ${wells.length}");
  }

  bool playerLost() {
    bool value = false;
    alivePoints.forEach((point) {
      if (point.y <= 0) {
        value = true;
      }
    });
    return value;
  }

  void highestPoint() {
    Map<String, List<int>?> pointsY = {
      "1 column": [boardHeight],
      "2 column": [boardHeight],
      "3 column": [boardHeight],
      "4 column": [boardHeight],
      "5 column": [boardHeight],
      "6 column": [boardHeight],
      "7 column": [boardHeight],
      "8 column": [boardHeight],
      "9 column": [boardHeight],
      "10 column": [boardHeight],
      "11 column": [boardHeight],
      "12 column": [boardHeight],
      "13 column": [boardHeight],
      "14 column": [boardHeight],
      "15 column": [boardHeight],
    };
    alivePoints.forEach((point) {
      switch (point.x) {
        case 0:
          pointsY["1 column"]!.add(point.y);
          break;
        case 1:
          pointsY["2 column"]!.add(point.y);
          break;
        case 2:
          pointsY["3 column"]!.add(point.y);
          break;
        case 3:
          pointsY["4 column"]!.add(point.y);
          break;
        case 4:
          pointsY["5 column"]!.add(point.y);
          break;
        case 5:
          pointsY["6 column"]!.add(point.y);
          break;
        case 6:
          pointsY["7 column"]!.add(point.y);
          break;
        case 7:
          pointsY["8 column"]!.add(point.y);
          break;
        case 8:
          pointsY["9 column"]!.add(point.y);
          break;
        case 9:
          pointsY["10 column"]!.add(point.y);
          break;
        case 10:
          pointsY["11 column"]!.add(point.y);
          break;
        case 11:
          pointsY["12 column"]!.add(point.y);
          break;
        case 12:
          pointsY["13 column"]!.add(point.y);
          break;
        case 13:
          pointsY["14 column"]!.add(point.y);
          break;
        case 14:
          pointsY["15 column"]!.add(point.y);
          break;
        default:
      }
    });
    List<int> mainPoints = [];
    for (var i = 1; i <= boardWidth; i++) {
      mainPoints.add(boardHeight - pointsY["$i column"]!.reduce(min));
    }
    Map<String, int> Cds = {
      "1-2": 0,
      "2-3": 0,
      "3-4": 0,
      "4-5": 0,
      "5-6": 0,
      "6-7": 0,
      "7-8": 0,
      "8-9": 0,
      "9-10": 0,
      "10-11": 0,
      "11-12": 0,
      "12-13": 0,
      "13-14": 0,
      "14-15": 0,
      "15-15": 0,
    };
    for (int i = 1; i <= boardWidth; i++) {
      Cds["${i}-${i + 1 > boardWidth ? boardWidth : i + 1}"] =
          mainPoints[i == boardWidth ? boardWidth - 1 : i] - mainPoints[i - 1];
    }
    print(Cds);
    meanHeight = mainPoints.average;
    maxHeight = mainPoints.reduce(max);
    print("Points max: ${maxHeight} Points average:  ${meanHeight}");
    // print('high Point 1 : ${pointsY["1 column"]!.reduce(min)}');
    // print('high Point 2 : ${pointsY["2 column"]!.reduce(min)}');
    // print('high Point 3 : ${pointsY["3 column"]!.reduce(min)}');
    // print('high Point 4 : ${pointsY["4 column"]!.reduce(min)}');
    // print('high Point 5 : ${pointsY["5 column"]!.reduce(min)}');
    // print('high Point 6 : ${pointsY["6 column"]!.reduce(min)}');
    // print('high Point 7 : ${pointsY["7 column"]!.reduce(min)}');
    // print('high Point 8 : ${pointsY["8 column"]!.reduce(min)}');
    // print('high Point 9 : ${pointsY["9 column"]!.reduce(min)}');
    // print('high Point 10 : ${pointsY["10 column"]!.reduce(min)}');
    // print('high Point 11 : ${pointsY["11 column"]!.reduce(min)}');
    // print('high Point 12 : ${pointsY["12 column"]!.reduce(min)}');
    // print('high Point 13 : ${pointsY["13 column"]!.reduce(min)}');
    // print('high Point 14 : ${pointsY["14 column"]!.reduce(min)}');
    // print('high Point 15 : ${pointsY["15 column"]!.reduce(min)}');
  }

  void changeBorderColor() {
    if (currentBlock!.movementNum < 5) {
      setState(() {
        borderColor = Colors.green;
      });
      HapticFeedback.lightImpact();
      print("vibrate1");
      Future.delayed(const Duration(milliseconds: 200), () {
        HapticFeedback.lightImpact();
        print("vibrate2");
      });
    } else if (currentBlock!.movementNum < 7) {
      setState(() {
        borderColor = Colors.green;
      });
    } else if (currentBlock!.movementNum < 13) {
      setState(() {
        borderColor = Colors.yellowAccent;
      });
    } else {
      setState(() {
        borderColor = Colors.red.shade900;
      });
    }
  }

  // void vibrate() {
  //   switch (currentBlock!.movementNum) {
  //     case 3:
  //       HapticFeedback.lightImpact();
  //       print("vibrate");
  //       break;
  //     case 4:
  //       HapticFeedback.lightImpact();
  //       print("vibrate");
  //       break;
  //     default:
  //   }
  //   // if (currentBlock!.movementNum < 5) {
  //   //   HapticFeedback.lightImpact();
  //   //   print("vibrate");
  //   //   HapticFeedback.lightImpact();
  //   //   print("vibrate");
  //   // }
  // }

  void onTimeTick(Timer time) {
    if (currentBlock == null || gameOver) return;

    if (playerLost()) {
      gameOver = true;
    }
    // Check if the current block is at the bottom or above an old block
    if (currentBlock!.isAtBottom() || isAboveOldBlock()) {
      changeBorderColor();
      // Save the block
      saveOldBlock();
      // Draw new block
      setState(() {
        currentBlock!.movementNum = 0;
        currentBlock = nextBlock;
        nextBlock = getRandomBlock();
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          borderColor = Colors.black;
        });
      });
    } else {
      setState(() {
        currentBlock!.move(MoveDir.down);
      });
      checkForUserInput();
    }

    // Remove full rows
    removeFullRows();
  }

  Widget? drawTetrisBlocks() {
    if (currentBlock == null) return null;

    List<Positioned> visiblePoints = [];

    // Current Block
    currentBlock!.points.forEach((point) {
      Positioned newPoint = Positioned(
        child: getTetrisPoint(currentBlock!.color),
        left: point.x * pointSize,
        top: point.y * pointSize,
      );
      visiblePoints.add(newPoint);
    });

    // Old Blocks
    alivePoints.forEach((point) {
      Positioned newPoint = Positioned(
        child: getTetrisPoint(point.color),
        left: point.x * pointSize,
        top: point.y * pointSize,
      );
      visiblePoints.add(newPoint);
    });
    return Stack(
      children: visiblePoints,
    );
  }

  Widget? drawNextBlocks() {
    if (nextBlock == null) return null;

    List<Positioned> visiblePoints = [];

    Block? nextBlockDisplay;
    const int nextBlockDisplayWidth = 5;

    switch (nextBlock!.name) {
      case "IBlock":
        nextBlockDisplay = IBlock(nextBlockDisplayWidth);
        break;
      case "JBlock":
        nextBlockDisplay = JBlock(nextBlockDisplayWidth);
        break;
      case "LBlock":
        nextBlockDisplay = LBlock(nextBlockDisplayWidth);
        break;
      case "SBlock":
        nextBlockDisplay = SBlock(nextBlockDisplayWidth);
        break;
      case "SQBlock":
        nextBlockDisplay = SQBlock(nextBlockDisplayWidth);
        break;
      case "TBlock":
        nextBlockDisplay = TBlock(nextBlockDisplayWidth);
        break;
      case "ZBlock":
        nextBlockDisplay = ZBlock(nextBlockDisplayWidth);
        break;
      default:
    }

    nextBlockDisplay!.points.forEach((point) {
      Positioned newPoint = Positioned(
        child: getTetrisPoint(nextBlock!.color),
        left: (point.x < 0 || point.y > 0)
            ? (point.x + 1) * pointSize
            : point.x * pointSize,
        top: (point.y < 0 || point.x > 0)
            ? (point.y + 1) * pointSize
            : point.y * pointSize,
      );
      visiblePoints.add(newPoint);
    });
    return Stack(
      children: visiblePoints,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
          ),
          onPressed: () async {
            timer.cancel();
            Navigator.pop(context);
          },
        ),
        title: Row(children: const [
          Image(
            image: AssetImage("assets/images/icon.jpg"),
            width: 100,
            height: 50,
          ),
          Text("TETRIS"),
        ]),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.cyan],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Score: $score",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor ?? Colors.black, width: 3),
            ),
            child: gameOver
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      getGameOverText(score),
                      const SizedBox(
                        height: 30,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          gameOver = false;
                          score = 0;
                          setState(() {
                            alivePoints.removeWhere((element) => true);
                          });
                          timer.cancel();
                          startGame();
                        },
                        child: const Text(
                          "Try Again",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  )
                : drawTetrisBlocks(),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: 110,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: Colors.black),
              ),
              child: Column(children: [
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                    ),
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.cyan],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Next",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Center(
                  child: SizedBox(
                    width: 100,
                    height: 55,
                    child: gameOver ? Container() : drawNextBlocks(),
                  ),
                ),
              ]),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            performAction = LastButtonPressed.rotateLeft;
                          });
                          highestPoint();
                          getPitsAndWells();
                        },
                        child: const Icon(
                          Icons.rotate_left,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            performAction = LastButtonPressed.rotateRight;
                          });
                        },
                        child: const Icon(
                          Icons.rotate_right,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            performAction = LastButtonPressed.left;
                          });
                        },
                        child: const Icon(
                          Icons.arrow_left,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            performAction = LastButtonPressed.right;
                          });
                        },
                        child: const Icon(
                          Icons.arrow_right,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        )
      ]),
    );
  }
}
