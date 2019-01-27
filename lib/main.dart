import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tertis_game_flutter/area_unit.dart';
import 'package:tertis_game_flutter/block.dart';
import 'package:tertis_game_flutter/block_provider.dart';
import 'package:tertis_game_flutter/coordinate.dart';
import 'package:tertis_game_flutter/game_theme.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tertis Game',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Tertis Game'),
    );
  }
}

class MyHomePage extends StatefulWidget {

  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


const int COUNT_ROW = 14;
const int COUNT_COL = 10;
const double SIZE_AREA_UNIT = 36;

class _MyHomePageState extends State<MyHomePage> {

  List<List<AreaUnit>> gameArea;
  List<List<AreaUnit>> gameAreaTemp;

  Timer timer;

  int speed = 500;
  Block block;
  bool draging = false;

  @override
  void initState() {
    initGameArea();
    initGameAreaTemp();
    block = createBlock();
    timer = Timer.periodic(Duration(milliseconds: speed), (Timer t) => process());
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void process() {
    setState(() {
      initGameAreaTemp(); // clear game area temp
      moveBlockDown(block);
      copyBlockToGameAreaTemp(block); //copy block to game area temp.

      if (isBlockCrashOnGround(block)) {
        copyBlockToGameArea(block);
        block = createBlock();
      }
    });
  }

  bool moveBlockDown(Block block) {
    for (Coordinate c in block.currentCoordinatesOnGameArea) {
      if (c.row + 1 >= COUNT_ROW || !gameArea[c.row + 1][c.col].available) {
        return false;
      }
    }

    for (Coordinate c in block.currentCoordinatesOnGameArea) {
      c.row = c.row + 1;
    }
    return true;
  }

  bool moveBlockRight(Block block) {
    for (Coordinate c in block.currentCoordinatesOnGameArea) {
      if (c.col + 1 >= COUNT_COL || !gameArea[c.row][c.col + 1].available) {
        return false;
      }
    }

    for (Coordinate c in block.currentCoordinatesOnGameArea) {
      c.col = c.col + 1;
    }
    return true;
  }

  bool moveBlockLeft(Block block) {
    for (Coordinate c in block.currentCoordinatesOnGameArea) {
      if (c.col - 1 < 0 || !gameArea[c.row][c.col - 1].available) {
        return false;
      }
    }

    for (Coordinate c in block.currentCoordinatesOnGameArea) {
      c.col = c.col - 1;
    }
    return true;
  }

  void moveGameAreaTempDown() {
    List<AreaUnit> list = List.of(gameAreaTemp[COUNT_ROW - 1]);
    gameAreaTemp.removeAt(COUNT_ROW - 1);
    gameAreaTemp.insert(0, list);
  }

  void copyBlockToGameAreaTemp(Block block) {
    for (Coordinate c in block.currentCoordinatesOnGameArea) {
      gameAreaTemp[c.row][c.col] = AreaUnit(color: block.color, available: false);
    }
  }

  void copyBlockToGameArea(Block block) {
    for (Coordinate c in block.currentCoordinatesOnGameArea) {
      gameArea[c.row][c.col] = AreaUnit(color: block.color, available: false);
    }
  }

  void initGameAreaTemp() {
    gameAreaTemp = List();
    for (int i = 0; i < COUNT_ROW; i++) {
      List<AreaUnit> listAreaTemp = List();
      for (int j = 0; j < COUNT_COL; j++) {
        listAreaTemp.add(AreaUnit());
      }
      gameAreaTemp.add(listAreaTemp);
    }
  }

  void initGameArea() {
    gameArea = List();
    for (int i = 0; i < COUNT_ROW; i++) {
      List<AreaUnit> listArea = List();
      for (int j = 0; j < COUNT_COL; j++) {
        listArea.add(AreaUnit());
      }
      gameArea.add(listArea);
    }

//    gameArea[COUNT_ROW - 2][2] = AreaUnit(available: false, color: Colors.red);
//    gameArea[COUNT_ROW - 1][1] = AreaUnit(available: false, color: Colors.red);
//    gameArea[COUNT_ROW - 1][2] = AreaUnit(available: false, color: Colors.red);
//    gameArea[COUNT_ROW - 1][1] = AreaUnit(available: false, color: Colors.red);
//    gameArea[COUNT_ROW - 1][6] = AreaUnit(available: false, color: Colors.red);
//    gameArea[COUNT_ROW - 2][6] = AreaUnit(available: false, color: Colors.red);
//    gameArea[COUNT_ROW - 3][6] = AreaUnit(available: false, color: Colors.red);
//    gameArea[COUNT_ROW - 4][6] = AreaUnit(available: false, color: Colors.red);
//    gameArea[COUNT_ROW - 5][6] = AreaUnit(available: false, color: Colors.red);
//    gameArea[COUNT_ROW - 6][6] = AreaUnit(available: false, color: Colors.red);
  }


  Block createBlock() {
    return BlockProvider.randomBlock();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(color: colorBackgroundApp,
          child: Center(
              child: GestureDetector(
                  onHorizontalDragUpdate: (detail) {
                    if (!draging) {
                      draging = true;
                      setState(() {
                        bool canMove = false;
                        if (detail.primaryDelta > 0) {
                          canMove = moveBlockRight(block);
                        } else {
                          canMove = moveBlockLeft(block);
                        }

                        if (canMove) {
                          initGameAreaTemp();
                          copyBlockToGameAreaTemp(block);
                        }
                      });
                      print(detail.primaryDelta.toString());

                      Future.delayed(const Duration(milliseconds: 100), () {
                        draging = false;
                      });
                    }
                  },
                  child: Container(
                      decoration: BoxDecoration(border: Border.all(width: 12, color: colorBorderGameArea),
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: buildGameArea()
                      )))
          )),
    );
  }

  List<Widget> buildGameArea() {
    List<Widget> list = List();
    for (int i = 0; i < COUNT_ROW; i++) {
      list.add(buildRow(i));
    }
    return list;
  }

  Row buildRow(int row) {
    List<Widget> list = List();
    for (int i = 0; i < COUNT_COL; i++) {
      list.add(buildAreaUnit(row, i));
    }
    return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: list);
  }

  Widget buildAreaUnit(int row, int col) {
    AreaUnit areaUnit = gameArea[row][col];
    AreaUnit areaUnitTemp = gameAreaTemp[row][col];

    if (areaUnit.available) {
      if (areaUnitTemp.available) {
        return buildAreaUnitView(colorBackgroundGameArea);
      } else {
        return buildAreaUnitView(areaUnitTemp.color);
      }
    } else {
      return buildAreaUnitView(areaUnit.color);
    }
  }

  Container buildAreaUnitView(Color color) {
    return Container(width: SIZE_AREA_UNIT, height: SIZE_AREA_UNIT,
        decoration: BoxDecoration(color: color,
            border: Border.all(width: 1, color: colorBorderAreaUnit)));
  }

  bool isBlockCrashOnGround(Block block) {
    for (Coordinate c in block.currentCoordinatesOnGameArea) {
      if (c.row + 1 < COUNT_ROW) {
        if (!gameArea[c.row + 1][c.col].available) {
          return true;
        }
      } else {
        return true;
      }
    }
    return false;
  }
}