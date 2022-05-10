import 'dart:async';

import 'package:flutter/material.dart';
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
            }
            break;
          case LastButtonPressed.right:
            currentBlock!.move(MoveDir.right);
            if (isAboveOldBlock(Ydistance: 0)) {
              currentBlock!.move(MoveDir.left);
            }
            break;
          case LastButtonPressed.rotateLeft:
            currentBlock!.rotateLeft();
            if (isAboveOldBlock(Ydistance: 0) || currentBlock!.isAtBottom() || currentBlock!.name == "SQBlock") {
              currentBlock!.rotateRight();
            }
            break;
          case LastButtonPressed.rotateRight:
            currentBlock!.rotateRight();
            if (isAboveOldBlock(Ydistance: 0) || currentBlock!.isAtBottom() || currentBlock!.name == "SQBlock") {
              currentBlock!.rotateLeft();
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

  bool playerLost() {
    bool value = false;
    alivePoints.forEach((point) {
      if (point.y <= 0) {
        value = true;
      }
    });
    return value;
  }

  void onTimeTick(Timer time) {
    if (currentBlock == null || gameOver) return;

    if (playerLost()) {
      gameOver = true;
    }

    // Check if the current block is at the bottom or above an old block
    if (currentBlock!.isAtBottom() || isAboveOldBlock()) {
      // Save the block
      saveOldBlock();
      // Draw new block
      setState(() {
        currentBlock = nextBlock;
        nextBlock = getRandomBlock();
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
              border: Border.all(color: Colors.black),
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
