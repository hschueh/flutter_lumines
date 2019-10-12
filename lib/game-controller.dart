import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter_lumines/lumines-game.dart';
import 'package:tuple/tuple.dart';

class LuminesController {
  final LuminesGame game;
  Tuple4 curBr;
  List<List<int>> board;
  List<int> boardHeight;
  Queue<Tuple4<int, int, int, int>> nextFive;
  static Random random;
  LuminesController(this.game){
    initialize();
  }
  void initialize() async {
    curBr = getRandomBrickTuple4();
    nextFive = Queue<Tuple4<int, int, int, int>>();
    for(int i = 0; i < 5; ++i) {
      nextFive.addLast(getRandomBrickTuple4());
    }
    board = new List<List<int>>.generate(BOARD.COL_NUM, (_) => [], growable: false);

    // for(int i = 0; i < BOARD.COL_NUM; ++i) {
    //   board.add(new List<int>.filled(BOARD.ROW_NUM, 0));
    // }
    boardHeight = new List<int>.filled(BOARD.COL_NUM, 0);
  }

  void putByTuple(int col, Tuple2<int, int> left, Tuple2<int, int> right) {
    boardHeight[col] += 2;
    boardHeight[col+1] += 2;
    if(boardHeight[col] > BOARD.ROW_NUM || boardHeight[col+1] > BOARD.ROW_NUM) {
      // died
    }
    board[col].add(left.item2);
    board[col].add(left.item1);
    board[col+1].add(right.item2);
    board[col+1].add(right.item1);

    curBr = nextFive.removeFirst();
    nextFive.addLast(getRandomBrickTuple4());
  }

  static Tuple4<int, int, int, int> getRandomBrickTuple4() {
    if(random == null) {
      // Could let user set seed.
      random = Random(DateTime.now().microsecondsSinceEpoch);
    }
    return Tuple4<int, int, int, int>(
      random.nextInt(100)%2,
      random.nextInt(100)%2,
      random.nextInt(100)%2,
      random.nextInt(100)%2,
    );
  }
}

class BOARD {
  static BOARD _instance;
  static BOARD getInstance(Size boardSize) {
    if(_instance == null)
      _instance = BOARD(boardSize);
    return _instance;
  }
  BOARD(Size actualSize) {
    boardWidth = actualSize.width;
    boardHeight = boardWidth * BOARD_HEIGHT/BOARD_WIDTH;
    blockSize = boardWidth / COL_NUM;
    blockWidth = blockSize;
    blockHeight = blockSize;
    blockSizeSmall = blockSize*(BLOCK_SIZE_SMALL/BLOCK_SIZE);
    yOffset = boardHeight / 5;
  }
  static const int BOARD_HEIGHT = 360;
  static const int BOARD_WIDTH = 480;
  static const int BLOCK_WIDTH = 30;
  static const int BLOCK_HEIGHT = 30;
  static const int BLOCK_SIZE = 30;
  static const int BLOCK_SIZE_SMALL = 20;
  static const int COL_NUM = 16;
  static const int ROW_NUM = 10;
  static const int BLOCK_NUM = 4;
  static const int MAP_OFFSET = 60;
  static const double GAME_LENGTH = 90;

  double boardHeight;
  double boardWidth;
  double blockWidth;
  double blockHeight;
  double blockSize;
  double blockSizeSmall;
  double yOffset;
}