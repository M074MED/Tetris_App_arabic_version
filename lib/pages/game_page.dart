import 'dart:async';
import 'dart:math';
import 'dart:ui';
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
import 'package:flutter/widgets.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import 'package:csv/csv.dart';
import 'dart:io';
// import 'package:ext_storage/ext_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:external_path/external_path.dart';

enum LastButtonPressed { left, right, rotateLeft, rotateRight, none }
enum MoveDir { left, right, down }

// Global Variables
const int boardWidth = 10;
const int boardHeight = 20;
const double pointSize = 25; // size in px
const double width = boardWidth * pointSize;
const double height = boardHeight * pointSize;

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
  List<Point> alivePointsXY = [];
  int score = 0;
  int level = 0;
  bool gameOver = false;
  Color? borderColor;
  double meanHeight = 0;
  int maxHeight = 0;
  double pattern_div = 0;
  double weighted_cells_avg = 0;
  int pits_num = 0;
  int wells_num = 0;
  int cd_9 = 0;
  int jaggedness = 0;
  double avg_lat = 0;
  double indValue = 0;
  List<Color> indColor = [Colors.green, Colors.green];
  int total_movements = 0;
  List<DateTime> d_timer = [];
  int gameSpeed = 1000; // speed in milliseconds

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
      Duration(milliseconds: gameSpeed),
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
    alivePoints.forEach((point) {
      setState(() {
        alivePointsXY.add(Point(point.x, point.y));
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
      level = (score / 7).floor();
      levelUp();
    });
  }

  void levelUp() {
    // TODO: maxHeight or score ......... (score % 7 == 0)
    if (score % 1 == 0 && level < 20) {
      setState(() {
        gameSpeed -= 900; // 1000/boardHeight = 50
      });
      timer.cancel();
      startGame();
      print("*" * 20);
      print("Level: $level");
      print("*" * 20);
      print("*" * 20);
      print("Game Speed: $gameSpeed");
      print("*" * 20);
    }
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

  void changeIndData() {
    d_timer.sort();
    List<int> times = [];
    for (var i = 0; i < d_timer.length; i++) {
      times.add(d_timer[i + 1 == d_timer.length ? d_timer.length - 1 : i + 1]
          .difference(d_timer[i])
          .inSeconds);
    }
    print("key presses time dif: $times");
    avg_lat = times.average;
    print("average_lat: ${times.average}");
    // indValue = pattern_div * 28.51 +
    //     meanHeight * 12.36 +
    //     (weighted_cells_avg / 100) * 11.9 +
    //     pits_num * 10.92 -
    //     cd_9 * 10.57 +
    //     wells_num * 6.38 +
    //     jaggedness * 5.33 +
    //     avg_lat * 2.372 +
    //     total_movements * 10.65;
    if (indValue < 15) {
      HapticFeedback.lightImpact();
    } else if (indValue > 30 && indValue < 50) {
      indColor.insert(0, Colors.yellow);
    } else if (indValue > 50 && indValue < 70) {
      indColor.insert(0, Colors.orange);
    } else if (indValue > 70) {
      indColor.insert(0, Colors.red);
    }
    print("indValue: $indValue");
  }

  // TODO
  void drawPattern() {
    // pattern row div
    int pattern_r_div = 0;
    List<List<int>> pattern = [];
    for (var y = boardHeight - 1; y >= 0; y--) {
      List<int> row = [];
      for (var x = 0; x < boardWidth; x++) {
        if (alivePointsXY.contains(Point(x, y))) {
          row.add(1);
        } else {
          row.add(0);
        }
      }
      pattern.add(row);
    }
    List<int> temp = [];
    for (var y = 0; y < pattern.length; y++) {
      for (int i = 0; i < pattern[y].length; i++) {
        temp.add(pattern[y][i] +
            pattern[y + 1 == pattern.length ? pattern.length - 1 : y + 1][i]);
      }
    }
    pattern_r_div = temp.where((item) => item == 1).length;

    // pattern column div
    int pattern_c_div = 0;
    List<List<int>> pattern2 = [];
    for (var x = 0; x < boardWidth; x++) {
      List<int> column = [];
      for (var y = boardHeight - 1; y >= 0; y--) {
        if (alivePointsXY.contains(Point(x, y))) {
          column.add(1);
        } else {
          column.add(0);
        }
      }
      pattern2.add(column);
    }
    List<int> temp2 = [];
    for (var y = 0; y < pattern2.length; y++) {
      for (int i = 0; i < pattern2[y].length; i++) {
        temp2.add(pattern2[y][i] +
            pattern2[y + 1 == pattern2.length ? pattern2.length - 1 : y + 1]
                [i]);
      }
    }
    pattern_c_div = temp2.where((item) => item == 1).length;

    // weighted_cell
    Map<String, double> weighted_cell = {};
    for (var x = 0; x < pattern2.length; x++) {
      // TODO: boardHeight or columnHeight
      weighted_cell["column ${x + 1}"] =
          (pattern2[x].where((item) => item == 1).length / boardHeight) * 100;
    }

    weighted_cells_avg = (weighted_cell.values.toList()).average;
    print("weighted_cell (%): ${weighted_cell}");
    pattern_div = (pattern_r_div + pattern_c_div) / 2;
    print("pattern_r_div: ${pattern_r_div}");
    print("pattern_c_div: ${pattern_c_div}");
  }

  void getPitsAndWells() {
    List<Point> pits = [];
    List<Point> wells = [];
    for (var currentRow = 0; currentRow < maxHeight; currentRow++) {
      int y = (boardHeight - 1) - currentRow;
      for (var x = 0; x < boardWidth; x++) {
        Point currentPoint = Point(x, y);
        if ((!alivePointsXY.contains(currentPoint)) &&
            alivePointsXY.contains(Point(x, y - 1))) {
          pits.add(currentPoint);
        } else if ((!alivePointsXY.contains(currentPoint)) &&
            (!alivePointsXY.contains(Point(x, y - 1))) &&
            (alivePointsXY.contains(Point(x - 1, y)) ||
                alivePointsXY.contains(Point(x + 1, y)) ||
                alivePointsXY.contains(Point(x, y + 1)))) {
          wells.add(currentPoint);
        }
      }
    }
    pits_num = pits.length;
    wells_num = wells.length;
    print("Pits num: ${pits.length}, Wells num: ${wells.length}");
  }

  bool playerLost() {
    bool value = false;
    alivePoints.forEach((point) {
      if (point.y <= 0) {
        value = true;
        // writeCsvFile();
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
        default:
      }
    });
    List<int> mainPoints = [];
    for (var i = 1; i <= boardWidth; i++) {
      mainPoints.add(boardHeight - pointsY["$i column"]!.reduce(min));
    }
    // TODO: abs or not
    Map<String, int> Cds = {};
    for (int i = 1; i <= boardWidth; i++) {
      Cds["columns ${i}-${i + 1 > boardWidth ? boardWidth : i + 1}"] =
          (mainPoints[i == boardWidth ? boardWidth - 1 : i] - mainPoints[i - 1])
              .abs();
    }
    cd_9 = Cds["columns 9-10"]!;
    print("Columns dif: $Cds");
    meanHeight = mainPoints.average;
    maxHeight = mainPoints.reduce(max);
    print("max height: ${maxHeight} mean height: ${meanHeight}");

    // jaggedness
    List<int> temp = [];
    for (var i = 0; i < boardWidth; i++) {
      temp.add(boardHeight - pointsY["${i + 1} column"]!.reduce(min));
    }
    jaggedness = 0;
    for (var i = 0; i < temp.length; i++) {
      jaggedness +=
          (temp[i + 1 == temp.length ? temp.length - 1 : i + 1] - temp[i])
              .abs();
    }
    print("jaggedness: ${jaggedness}");
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

  // void writeCsvFile() async {
  //   Map<Permission, PermissionStatus> statuses = await [
  //     Permission.storage,
  //   ].request();

  //   List<dynamic> associateList = [
  //     {
  //       "pits": pits_num,
  //       "wells": wells_num,
  //       "meanHeight": meanHeight,
  //       "pattern_div": pattern_div,
  //       "weighted_cells_avg": weighted_cells_avg,
  //       "cd_9": cd_9,
  //       "jaggedness": jaggedness,
  //       "avg_lat": avg_lat,
  //       "total_movements": total_movements,
  //     },
  //     // {"number": 2, "lat": "14.97534313396318", "lon": "101.22998536005622"},
  //     // {"number": 3, "lat": "14.97534313396318", "lon": "101.22998536005622"},
  //     // {"number": 4, "lat": "14.97534313396318", "lon": "101.22998536005622"}
  //   ];

  //   List<List<dynamic>> rows = [];

  //   List<dynamic> row = [];
  //   row.add("pits");
  //   row.add("wells");
  //   row.add("meanHeight");
  //   row.add("pattern_div");
  //   row.add("weighted_cells_avg");
  //   row.add("cd_9");
  //   row.add("jaggedness");
  //   row.add("avg_lat");
  //   row.add("total_movements");
  //   rows.add(row);
  //   for (int i = 0; i < associateList.length; i++) {
  //     List<dynamic> row = [];
  //     row.add(associateList[i]["pits"]);
  //     row.add(associateList[i]["wells"]);
  //     row.add(associateList[i]["meanHeight"]);
  //     row.add(associateList[i]["pattern_div"]);
  //     row.add(associateList[i]["weighted_cells_avg"]);
  //     row.add(associateList[i]["cd_9"]);
  //     row.add(associateList[i]["jaggedness"]);
  //     row.add(associateList[i]["avg_lat"]);
  //     row.add(associateList[i]["total_movements"]);
  //     rows.add(row);
  //   }

  //   String csv = const ListToCsvConverter().convert(rows);

  //   String dir = await ExternalPath.getExternalStoragePublicDirectory(
  //       ExternalPath.DIRECTORY_DOWNLOADS);
  //   print("dir $dir");
  //   String file = "$dir";

  //   File f = File(file + "/filename.csv");

  //   f.writeAsString(csv);
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
      // calculate data
      highestPoint();
      getPitsAndWells();
      drawPattern();
      total_movements += currentBlock!.movementNum;
      indValue += 15;
      if (indValue > 100) {
        indValue = 100;
      }
      changeIndData();
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Column(
                  children: [
                    SizedBox(
                      width: 100,
                      height: 200,
                      child: Center(
                        // child: RotatedBox(
                        //   quarterTurns: -1,
                        child: StepProgressIndicator(
                          direction: Axis.vertical,
                          totalSteps: 100,
                          currentStep: (100 - indValue).round(),
                          size: 30,
                          padding: 0,
                          // selectedColor: Colors.yellow,
                          // unselectedColor: Colors.cyan,
                          roundedEdges: const Radius.circular(10),
                          selectedGradientColor: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.grey, Colors.transparent],
                          ),
                          unselectedGradientColor: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: indColor,
                          ),
                        ),
                        // ),
                        // child: FAProgressBar(
                        //   size: 80,
                        //   direction: Axis.vertical,
                        //   verticalDirection: VerticalDirection.up,
                        //   currentValue: indValue,
                        //   displayText: '%',
                        //   progressColor: Colors.green,
                        // ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue, Colors.cyan],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Score: $score",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue, Colors.cyan],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Level: $level",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      width: 110,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
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
                  ],
                ),
                const SizedBox(
                  width: 20,
                ),
                Center(
                  child: Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: borderColor ?? Colors.black, width: 3),
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
              ],
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    performAction = LastButtonPressed.rotateLeft;
                  });
                  d_timer.add(DateTime.now());
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
                  d_timer.add(DateTime.now());
                },
                child: const Icon(
                  Icons.rotate_right,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    performAction = LastButtonPressed.left;
                  });
                  d_timer.add(DateTime.now());
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
                  d_timer.add(DateTime.now());
                },
                child: const Icon(
                  Icons.arrow_right,
                ),
              ),
            ),
          ],
        )
      ]),
    );
  }
}
