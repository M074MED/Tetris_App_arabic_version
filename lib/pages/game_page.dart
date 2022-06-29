import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:backendless_sdk/backendless_sdk.dart' as bkl;
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tetris_app/blocks/Iblock.dart';
import 'package:tetris_app/blocks/Lblock.dart';
import 'package:tetris_app/blocks/alivePoints.dart';
import 'package:tetris_app/blocks/block.dart';
import 'package:tetris_app/models/sessions.dart';
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

import 'home_page.dart';

enum LastButtonPressed { left, right, rotateLeft, rotateRight, none }
enum MoveDir { left, right, down }

// Global Variables
const int boardWidth = 10;
const int boardHeight = 20;
double pointSize = 20; // size in px
double width = boardWidth * pointSize;
double height = boardHeight * pointSize;

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
  int tetrises = 0;
  int lines = 0;
  int game = 1;
  int level = 0;
  bool gameOver = false;
  Color? borderColor;
  double meanHeight = 0;
  int maxHeight = 0;
  int delta_max_height = 0;
  int minHeight = 0;
  int maximum_differences = 0;
  int landing_height = 1;
  double pattern_div = 0;
  int column_transitions = 0;
  int row_transitions = 0;
  double weighted_cells_avg = 0;
  int pits_num = 0;
  int delta_pits = 0;
  double pit_depth = 0;
  double lumped_pits = 0;
  int wells_num = 0;
  int max_well = 0;
  int deep_wells = 0;
  double cumulative_wells = 0;
  int cd_9 = 0;
  int cd_1 = 0;
  int cd_7 = 0;
  int cd_8 = 0;
  int cd_2 = 0;
  int jaggedness = 0;
  double avg_lat = 0;
  double indValue = 0;
  List<Color> indColor = [Colors.green, Colors.green];
  int total_movements = 0;
  int total_rotations = 0;
  int total_translations = 0;
  bool dropDownHolding = false;
  int rotationCenterX = 0;
  int minimumTranslationsDif = 0;
  int minimumRotationsDif = 0;
  List<DateTime> d_timer = [];
  List<int> mainPoints = []; // mainPoints => columns heights
  DateTime drawBlockDate = DateTime.utc(0);
  int gameSpeed = 1000; // speed in milliseconds
  int tempGameSpeed = 1000; // speed in milliseconds
  String startButton = "Start";

  // @override
  // void initState() {
  //   super.initState();
  //   startGame();
  // }

  void startGame() {
    setState(() {
      currentBlock = getRandomBlock();
      rotationCenterX = currentBlock!.rotationCenter.x;
      nextBlock = getRandomBlock();
    });
    drawBlockDate = DateTime.now();
    timer = Timer.periodic(
      Duration(milliseconds: gameSpeed),
      onTimeTick,
    );
  }

  void cont() {
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
      lines++;
      level = (lines / 7).floor();
      levelUp();
    });
  }

  void levelUp() {
    if (lines % 7 == 0 && level < 20) {
      setState(() {
        gameSpeed -= 50; // 1000/boardHeight = 50
        tempGameSpeed -= 50; // 1000/boardHeight = 50
      });
      timer.cancel();
      cont();
      print("*" * 20);
      print("Level: $level");
      print("*" * 20);
      print("*" * 20);
      print("Game Speed: $gameSpeed");
      print("*" * 20);
    } else if (lines % 7 == 0 && level > 20) {
      setState(() {
        gameSpeed = (gameSpeed * 0.5).round();
        tempGameSpeed = (tempGameSpeed * 0.5).round();
      });
      timer.cancel();
      cont();
      print("*" * 20);
      print("Level: $level");
      print("*" * 20);
      print("*" * 20);
      print("Game Speed: $gameSpeed");
      print("*" * 20);
    }
  }

  void countTetrisesAndScore() {
    int fullLines = 0;
    for (var currentRow = 0; currentRow < boardHeight; currentRow++) {
      int counter = 0;
      alivePoints.forEach((point) {
        if (point.y == currentRow) {
          counter++;
        }
      });
      if (counter >= boardWidth) {
        fullLines++;
      }
      switch (fullLines) {
        case 1:
          setState(() {
            score += 40 * (level + 1);
          });
          break;
        case 2:
          setState(() {
            score += 100 * (level + 1);
          });
          break;
        case 3:
          setState(() {
            score += 300 * (level + 1);
          });
          break;
        case 4:
          setState(() {
            tetrises++;
            score += 1200 * (level + 1);
          });
          break;
        default:
      }
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
    try {
      d_timer.sort();
      List<int> times = [];
      for (var i = 0; i < d_timer.length; i++) {
        times.add(d_timer[i + 1 == d_timer.length ? d_timer.length - 1 : i + 1]
            .difference(d_timer[i])
            .inSeconds);
      }
      print("key presses time dif: $times");
      avg_lat = times.average;
    } catch (e) {
      avg_lat = 0;
    }
    print("average_lat: ${avg_lat}");
    indValue = 5 *
        ((pattern_div * 0.1251132) +
            (meanHeight * 0.05239681) +
            (maxHeight * 0.051240783) +
            (weighted_cells_avg * 0.050453956) +
            (minHeight * 0.050302274) +
            (row_transitions * 0.050216027) +
            (pits_num * 0.046309109) +  // + (pit_rows_mean * 0.046244674) TODO
            (landing_height * 0.045510476) +
            (column_transitions * 0.045442039) +
            (pit_depth * 0.04540702) +
            (lumped_pits * 0.045332779) -
            (cd_9 * 0.044794087) +
            (wells_num * 0.027048065) +
            (deep_wells * 0.026704079) +
            (max_well * 0.026626037) +
            (cumulative_wells * 0.026196003) -
            (currentBlock!.proportion_of_user_drops * 0.024190116) +
            (jaggedness * 0.022607458) +
            (maximum_differences * 0.019303867) +
            (cd_1 * 0.017928321) +
            (currentBlock!.response_latency * 0.015281085) +
            (currentBlock!.rotateNum * 0.012734505) +
            (minimumRotationsDif * 0.012548804) +
            (currentBlock!.drop_latency * 0.012471762) +
            (minimumTranslationsDif * 0.010394636) +
            (avg_lat * 0.010057253) -
            (currentBlock!.matches * 0.00962802) +
            (currentBlock!.translationNum * 0.009460329) +
            (delta_max_height * 0.00673225) -
            (currentBlock!.initial_latency * 0.006052482) +
            (delta_pits * 0.004095821) +
            (cd_7 * 0.000487464) +
            (cd_8 * 0.000467453) +
            (cd_2 * 0.00022092));
    if (indValue < 15) {
      HapticFeedback.lightImpact();
    } else if (indValue > 30 && indValue < 50) {
      indColor.insert(0, Colors.yellow);
    } else if (indValue > 50 && indValue < 70) {
      indColor.insert(0, Colors.orange);
    } else if (indValue > 70 && indValue < 100) {
      indColor.insert(0, Colors.red);
    }
    print("indValue: $indValue");
  }

  void drawPattern() {
    // pattern row div
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
    row_transitions = temp.where((item) => item == 1).length;

    // pattern column div
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
    column_transitions = temp2.where((item) => item == 1).length;

    // weighted_cell
    Map<String, double> weighted_cell = {};
    for (var x = 0; x < pattern2.length; x++) {
      weighted_cell["column ${x + 1}"] = mainPoints[x] == 0
          ? 0
          : (pattern2[x].where((item) => item == 1).length /
              mainPoints[x]); // mainPoints => columns heights
    }

    weighted_cells_avg = (weighted_cell.values.toList()).average;
    print("weighted_cell (%): ${weighted_cell}");
    pattern_div = (row_transitions + column_transitions) / 2;
    print("row_transitions: ${row_transitions}");
    print("column_transitions: ${column_transitions}");
  }

  bool isColumnEmpty(List<Point> list, int x, int y) {
    for (var i = 1; i < y; i++) {
      if (list.contains(Point(x, y - i))) {
        return false;
      }
    }
    return true;
  }

  void getPitsAndWells() {
    List<Point> pits = [];
    List<Point> wells = [];
    for (var x = 0; x < boardWidth; x++) {
      for (var y = boardHeight - 1; y >= 0; y--) {
        Point currentPoint = Point(x, y);
        if ((!alivePointsXY.contains(currentPoint)) &&
            (isColumnEmpty(alivePointsXY, x, y)) &&
            (alivePointsXY.contains(Point(x + 1, y)) ||
                alivePointsXY.contains(Point(x - 1, y))) &&
            ((y == boardHeight - 1) ||
                alivePointsXY.contains(Point(x, y + 1)) ||
                wells.contains(Point(x, y + 1)))) {
          wells.add(currentPoint);
        }
      }
    }

    List<double> pit_depth_list = [];
    for (var x = 0; x < boardWidth; x++) {
      int pitCounter = 0;
      int pointCounter = 0;
      for (var y = 0; y < boardHeight; y++) {
        Point currentPoint = Point(x, y);
        if ((!alivePointsXY.contains(currentPoint)) &&
            (alivePointsXY.contains(Point(x, y - 1)) ||
                pits.contains(Point(x, y - 1))) &&
            (alivePointsXY.contains(Point(x + 1, y)) ||
                pits.contains(Point(x + 1, y)) ||
                (x == boardWidth - 1) ||
                (!wells.contains(Point(x + 1, y)))) &&
            (alivePointsXY.contains(Point(x - 1, y)) ||
                pits.contains(Point(x - 1, y)) ||
                (x == 0) ||
                (!wells.contains(Point(x - 1, y))))) {
          pits.add(currentPoint);
          pitCounter++;
        }
        if (alivePointsXY.contains(currentPoint)) {
          pointCounter++;
        }
      }
      if (pointCounter == 0) {
        pit_depth_list.add(0);
      } else {
        pit_depth_list.add((pitCounter / pointCounter) * 1.25);
      }
    }

    // TODO: Not work
    int pitsGroupCounter = 0;
    for (var i = 0; i < pits.length; i++) {
      num x = pits[i].x;
      num y = pits[i].y;
      if (pits.contains(Point(x + 1, y))) {
        pitsGroupCounter++;
      }
      if (pits.contains(Point(x - 1, y))) {
        pitsGroupCounter++;
      }
      if (pits.contains(Point(x, y + 1))) {
        pitsGroupCounter++;
      }
      if (pits.contains(Point(x, y - 1))) {
        pitsGroupCounter++;
      }
    }
    lumped_pits = 0;
    for (var i = 1; i <= pitsGroupCounter; i++) {
      lumped_pits += (1 / i);
    }

    pit_depth = pit_depth_list.average;
    print("PD" * 22);
    print("$pit_depth || $pit_depth_list || $pitsGroupCounter || $lumped_pits");
    print("PD" * 22);

    List<String> wellXTemp = [];
    wells.forEach((well) {
      wellXTemp.add("${well.x}");
    });
    List<String> pitsXTemp = [];
    pits.forEach((pit) {
      pitsXTemp.add("${pit.x}");
    });
    print("T" * 22);
    print(pitsXTemp);
    print("T" * 22);
    print("E" * 22);
    print(wellXTemp);
    print("E" * 22);
    Map<dynamic, int> wellsMap = {};
    wellXTemp.forEach((x) =>
        wellsMap[x] = !wellsMap.containsKey(x) ? (1) : (wellsMap[x]! + 1));
    print("W" * 50);
    print((wellsMap.values).toList());
    deep_wells = (wellsMap.values).toList().where((item) => item >= 3).length;
    max_well = (wellsMap.values).toList().reduce(max);
    List<num> cumulative_wells_temp = [];
    (wellsMap.values).toList().forEach((element) {
      cumulative_wells_temp.add((pow(element, 2) + element) / 2);
    });
    cumulative_wells = cumulative_wells_temp.average;
    print(
        "$max_well || $deep_wells || $cumulative_wells || $cumulative_wells_temp");
    print("W" * 50);
    // Map<String, int> tempWells = {};
    // wells.forEach((well) {
    //   tempWells["${well.x}"] = 0;
    // });
    // wells.forEach((well) {
    //   tempWells["${well.x}"] += 1;
    // });
    pits_num = pits.length;
    wells_num = wells.length;
    print("Pits num: $pits_num, Wells num: $wells_num");
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
    mainPoints = [];
    for (var i = 1; i <= boardWidth; i++) {
      mainPoints.add(boardHeight - pointsY["$i column"]!.reduce(min));
    }
    Map<String, int> Cds = {};
    for (int i = 1; i <= boardWidth; i++) {
      Cds["columns ${i}-${i + 1 > boardWidth ? boardWidth : i + 1}"] =
          (mainPoints[i == boardWidth ? boardWidth - 1 : i] - mainPoints[i - 1])
              .abs();
    }
    cd_9 = Cds["columns 9-10"]!;
    cd_1 = Cds["columns 1-2"]!;
    cd_7 = Cds["columns 7-8"]!;
    cd_8 = Cds["columns 8-9"]!;
    cd_2 = Cds["columns 2-3"]!;
    print("Columns dif: $Cds");
    meanHeight = mainPoints.average;
    maxHeight = mainPoints.reduce(max);
    minHeight = mainPoints.reduce(min);
    maximum_differences = maxHeight - minHeight;
    // Calculate landing height and matches
    alivePoints.forEach((oldPoint) {
      if (oldPoint.checkIfPointsCollide(currentBlock!.points)) {
        landing_height = 20 - oldPoint.y;
      }
    });
    print(
        "max height: ${maxHeight} min height: ${minHeight} mean height: ${meanHeight} maximum_differences: ${maximum_differences} landing height: ${landing_height} matches: ${currentBlock!.matches}");

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

  void sendSessionData() async {
    await bkl.Backendless.data
        .of("Sessions")
        .save(Sessions(
          pits: pits_num,
          tetrises: tetrises,
          score: score,
          level: level,
          lines: lines,
          game: game,
          rotations: currentBlock!.rotateNum,
          proportion_of_user_drops: currentBlock!.proportion_of_user_drops,
          minimum_rotation_difference: minimumRotationsDif,
          minimum_translation_difference: minimumTranslationsDif,
          maximum_differences: maximum_differences,
          initial_latency: currentBlock!.initial_latency,
          drop_latency: currentBlock!.drop_latency,
          response_latency: currentBlock!.response_latency,
          max_well: max_well,
          deep_wells: deep_wells,
          cumulative_wells: cumulative_wells,
          column_transitions: column_transitions,
          row_transitions: row_transitions,
          landing_height: landing_height,
          matches: currentBlock!.matches,
          delta_max_height: delta_max_height,
          delta_pits: delta_pits,
          pit_depth: pit_depth,
          lumped_pits: lumped_pits,
          max_height: maxHeight,
          min_height: minHeight,
          wells: wells_num,
          avg_lat: avg_lat,
          cd_9: cd_9,
          mean_height: meanHeight,
          pattern_div: pattern_div,
          total_movements: total_movements,
          weighted_cells: weighted_cells_avg,
          jaggedness: jaggedness,
          username: usernameInput.text,
        ).toJson())
        .catchError((error, stackTrace) {
      print(error.toString());
      showSnackBar(context, error.toString());
    });
    showSnackBar(context, "Session created!");
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

  void calcTransitions() {
    total_rotations += currentBlock!.rotateNum;
    total_movements += currentBlock!.movementNum;
    total_translations += total_movements - total_rotations;
    currentBlock!.translationNum =
        currentBlock!.movementNum - currentBlock!.rotateNum;
    if (dropDownHolding) {
      currentBlock!.onDropDownY2 = currentBlock!.rotationCenter.y;
      currentBlock!.proportion_of_user_drops =
          ((currentBlock!.onDropDownY1 - currentBlock!.onDropDownY2) /
                  boardHeight)
              .abs();
      print("*" * 20);
      print(
          "${currentBlock!.onDropDownY1} || ${currentBlock!.onDropDownY2} || ${currentBlock!.rotateNum} || ${currentBlock!.translationNum} || ${currentBlock!.proportion_of_user_drops}");
      print("*" * 20);
    } else {
      currentBlock!.proportion_of_user_drops =
          ((currentBlock!.onDropDownY1 - currentBlock!.onDropDownY2) /
                  boardHeight)
              .abs();
      print("*" * 20);
      print(
          "${currentBlock!.onDropDownY1} || ${currentBlock!.onDropDownY2} || ${currentBlock!.rotateNum} || ${currentBlock!.translationNum} || ${currentBlock!.proportion_of_user_drops}");
      print("*" * 20);
    }
  }

  void calcMinTransDif() {
    int optimalTranslations =
        (rotationCenterX - currentBlock!.rotationCenter.x).abs();
    minimumTranslationsDif =
        (currentBlock!.translationNum - optimalTranslations).abs();
    print("=" * 20);
    print(
        "$minimumTranslationsDif || $rotationCenterX || ${currentBlock!.rotationCenter.x} || $optimalTranslations");
    print("=" * 20);
  }

  void calcMinRotationsDif() {
    if (currentBlock!.name == "IBlock" ||
        currentBlock!.name == "SBlock" ||
        currentBlock!.name == "ZBlock") {
      if (currentBlock!.rotateNum % 2 == 0) {
        minimumRotationsDif = currentBlock!.rotateNum;
      } else {
        minimumRotationsDif = currentBlock!.rotateNum - 1;
      }
    } else if (currentBlock!.name != "SQBlock") {
      int RNum = 0;
      int LNum = 0;
      for (var i = 0; i < currentBlock!.rotatePattern.length; i++) {
        if (currentBlock!.rotatePattern[i] == "R") {
          RNum++;
        } else {
          LNum++;
        }
      }
      minimumRotationsDif =
          currentBlock!.rotateNum - (((RNum - LNum).abs()) % 4);
    }
    print("/" * 20);
    print("$minimumRotationsDif");
    print("/" * 20);
  }

  void calcInitialLat() {
    if (currentBlock!.movementNum == 0 && currentBlock!.dropDownCounter == 0) {
      currentBlock!.initial_latency =
          DateTime.now().difference(drawBlockDate).inSeconds;
    }
  }

  // Calculate matches
  void calcMatches() {
    currentBlock!.points.forEach((point) {
      if (alivePointsXY.contains(Point(point.x - 1, point.y))) {
        currentBlock!.matches++;
      }
      if (alivePointsXY.contains(Point(point.x + 1, point.y))) {
        currentBlock!.matches++;
      }
      if (alivePointsXY.contains(Point(point.x, point.y + 1))) {
        currentBlock!.matches++;
      }
    });
  }

  void onTimeTick(Timer time) {
    if (currentBlock == null || gameOver) return;

    if (playerLost()) {
      gameOver = true;
      // try {
      //   sendSessionData();
      // } catch (e) {
      //   print("$e");
      // }
    }
    // Check if the current block is at the bottom or above an old block
    if (currentBlock!.isAtBottom() || isAboveOldBlock()) {
      changeBorderColor();
      // Calculate matches
      calcMatches();
      // Save the block
      saveOldBlock();
      // Remove full rows
      int maxHeightTemp = maxHeight;
      int pitsNumTemp = pits_num;
      countTetrisesAndScore();
      removeFullRows();
      // calculate data
      highestPoint();
      delta_max_height = (maxHeightTemp - maxHeight).abs();
      print("Q" * 30);
      print("$delta_max_height");
      print("Q" * 30);
      getPitsAndWells();
      delta_pits = (pitsNumTemp - pits_num).abs();
      print("DP" * 30);
      print("$delta_pits");
      print("DP" * 30);
      drawPattern();
      calcTransitions();
      calcMinTransDif();
      calcMinRotationsDif();
      if (currentBlock!.movementNum == 0 &&
          currentBlock!.rotateNum == 0 &&
          currentBlock!.proportion_of_user_drops == 0) {
        currentBlock!.response_latency =
            DateTime.now().difference(drawBlockDate).inSeconds;
      }
      print("|" * 20);
      print(
          "${currentBlock!.response_latency} | ${currentBlock!.drop_latency} | ${currentBlock!.initial_latency}");
      print("|" * 20);

      // indValue += 15;

      changeIndData();

      if (indValue > 100) {
        indValue = 100;
      }
      // Draw new block
      setState(() {
        // currentBlock!.movementNum = 0;
        currentBlock = nextBlock;
        rotationCenterX = currentBlock!.rotationCenter.x;
        nextBlock = getRandomBlock();
      });
      drawBlockDate = DateTime.now();
      // sendSessionData();
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          borderColor = Colors.white;
        });
      });
      // send data
      try {
        sendSessionData();
      } catch (e) {
        print("$e");
      }
    } else {
      setState(() {
        currentBlock!.move(MoveDir.down);
      });
      checkForUserInput();
    }
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double userInputFieldPadding = 190.0;

    width = (screenWidth / 6) * 3;
    height = width * 2.0;
    // height = screenHeight - userInputFieldPadding;
    // width = height / 2.0;
    pointSize = height / boardHeight;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(35),
        child: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
            ),
            onPressed: () async {
              try {
                timer.cancel();
              } catch (e) {
                print("$e");
              }
              Navigator.pop(context);
            },
          ),
          title: Row(children: const [
            Image(
              image: AssetImage("assets/images/icon.jpg"),
              width: 75,
              height: 35,
            ),
            Text(
              "TETRIS",
              // style: TextStyle(
              //   fontSize: 12,
              // ),
            ),
          ]),
        ),
      ),
      body: Container(
        color: Colors.black,
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Container(
            // decoration: const BoxDecoration(
            //   gradient: LinearGradient(
            //     colors: [Colors.blue, Colors.cyan],
            //   ),
            // ),
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text(
                "Score: $score",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Column(
                    children: [
                      // SizedBox(
                      //   width: 100,
                      //   height: 200,
                      //   child: Center(
                      //     // child: RotatedBox(
                      //     //   quarterTurns: -1,
                      //     child: StepProgressIndicator(
                      //       direction: Axis.vertical,
                      //       totalSteps: 100,
                      //       currentStep: (100 - indValue).round(),
                      //       size: 30,
                      //       padding: 0,
                      //       // selectedColor: Colors.yellow,
                      //       // unselectedColor: Colors.cyan,
                      //       roundedEdges: const Radius.circular(10),
                      //       selectedGradientColor: const LinearGradient(
                      //         begin: Alignment.topLeft,
                      //         end: Alignment.bottomRight,
                      //         colors: [Colors.grey, Colors.transparent],
                      //       ),
                      //       unselectedGradientColor: LinearGradient(
                      //         begin: Alignment.topLeft,
                      //         end: Alignment.bottomRight,
                      //         colors: indColor,
                      //       ),
                      //     ),
                      //     // ),
                      //     // child: FAProgressBar(
                      //     //   size: 80,
                      //     //   direction: Axis.vertical,
                      //     //   verticalDirection: VerticalDirection.up,
                      //     //   currentValue: indValue,
                      //     //   displayText: '%',
                      //     //   progressColor: Colors.green,
                      //     // ),
                      //   ),
                      // ),
                      const SizedBox(height: 20),
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            "Tetrises\n$tetrises",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            "Lines\n$lines",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            "Level\n$level",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            "Game\n$game",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      // const SizedBox(
                      //   height: 30,
                      // ),
                      // Container(
                      //   width: 100,
                      //   height: 100,
                      //   decoration: BoxDecoration(
                      //     borderRadius:
                      //         const BorderRadius.all(Radius.circular(10)),
                      //     border: Border.all(color: Colors.transparent),
                      //   ),
                      //   child: Column(children: [
                      //     Container(
                      //       decoration: const BoxDecoration(
                      //         borderRadius: BorderRadius.only(
                      //           topRight: Radius.circular(10),
                      //           topLeft: Radius.circular(10),
                      //         ),
                      //         gradient: LinearGradient(
                      //           colors: [Colors.blue, Colors.cyan],
                      //         ),
                      //       ),
                      //       child: Row(
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         children: const [
                      //           Padding(
                      //             padding: EdgeInsets.all(8.0),
                      //             child: Text(
                      //               "Next",
                      //               style: TextStyle(
                      //                color: Colors.white,
                      //                 fontSize: 16,
                      //                 fontWeight: FontWeight.bold,
                      //               ),
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //     const SizedBox(
                      //       height: 5,
                      //     ),
                      //     Center(
                      //       child: SizedBox(
                      //         width: 100,
                      //         height: 55,
                      //         child: gameOver ? Container() : drawNextBlocks(),
                      //       ),
                      //     ),
                      //   ]),
                      // ),
                    ],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Center(
                    child: Container(
                      width: width,
                      height: height,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: borderColor ?? Colors.white, width: 3),
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
                                    lines = 0;
                                    tetrises = 0;
                                    level = 0;
                                    setState(() {
                                      game++;
                                      alivePoints
                                          .removeWhere((element) => true);
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
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    children: [
                      Container(
                        width: screenWidth / 5,
                        // height: 150,
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          border: Border.all(color: Colors.transparent),
                        ),
                        child: Column(children: [
                          Container(
                            // decoration: const BoxDecoration(
                            //   borderRadius: BorderRadius.only(
                            //     topRight: Radius.circular(10),
                            //     topLeft: Radius.circular(10),
                            //   ),
                            //   gradient: LinearGradient(
                            //     colors: [Colors.blue, Colors.cyan],
                            //   ),
                            // ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Padding(
                                  padding: EdgeInsets.all(3.0),
                                  child: Text(
                                    "Next",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: SizedBox(
                              width: screenWidth / 5,
                              height: pointSize * 3,
                              child: gameOver ? Container() : drawNextBlocks(),
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(
                        height: 60,
                      ),
                      showIndicator
                          ? SizedBox(
                              width: screenWidth / 5,
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
                            )
                          : Container(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: ElevatedButton(
                          onPressed: () {
                            if (startButton == "Stop") {
                              setState(() {
                                performAction = LastButtonPressed.left;
                              });
                              d_timer.add(DateTime.now());
                              calcInitialLat();
                            }
                          },
                          child: const Icon(
                            Icons.arrow_left,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: ElevatedButton(
                          onPressed: () {
                            if (startButton == "Stop") {
                              setState(() {
                                performAction = LastButtonPressed.right;
                              });
                              d_timer.add(DateTime.now());
                              calcInitialLat();
                            }
                          },
                          child: const Icon(
                            Icons.arrow_right,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: GestureDetector(
                      onTapDown: (details) {
                        if (startButton == "Stop") {
                          setState(() {
                            tempGameSpeed = gameSpeed;
                            timer.cancel();
                            gameSpeed = 50;
                            cont();
                          });
                          dropDownHolding = true;
                          currentBlock!.onDropDownY1 =
                              currentBlock!.rotationCenter.y;
                          d_timer.add(DateTime.now());
                          calcInitialLat();
                          currentBlock!.dropDownCounter++;
                          if (currentBlock!.dropDownCounter == 1) {
                            currentBlock!.drop_latency = DateTime.now()
                                .difference(drawBlockDate)
                                .inSeconds;
                          }
                        }
                      },
                      onTapCancel: () {
                        if (startButton == "Stop") {
                          setState(() {
                            print(
                                "GameSpeed: $gameSpeed // tempGameSpeed: $tempGameSpeed");
                            timer.cancel();
                            gameSpeed = tempGameSpeed;
                            cont();
                          });
                          dropDownHolding = false;
                          currentBlock!.onDropDownY2 =
                              currentBlock!.rotationCenter.y;
                        }
                      },
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Icon(
                          Icons.arrow_drop_down,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (startButton == "Stop") {
                        startButton = "Start";
                        timer.cancel();
                      } else {
                        startButton = "Stop";
                        if (currentBlock == null) {
                          startGame();
                        } else {
                          cont();
                        }
                      }
                    });
                  },
                  child: Text(
                    startButton,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    primary: Colors.red,
                    minimumSize: const Size(40, 40),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (startButton == "Stop") {
                      setState(() {
                        performAction = LastButtonPressed.rotateLeft;
                      });
                      d_timer.add(DateTime.now());
                      calcInitialLat();
                    }
                  },
                  child: const Icon(
                    Icons.rotate_left,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (startButton == "Stop") {
                      setState(() {
                        performAction = LastButtonPressed.rotateRight;
                      });
                      d_timer.add(DateTime.now());
                      calcInitialLat();
                    }
                  },
                  child: const Icon(
                    Icons.rotate_right,
                  ),
                ),
              ),
            ],
          )
        ]),
      ),
    );
  }
}
