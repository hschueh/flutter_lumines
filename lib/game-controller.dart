import 'dart:collection';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter_lumines/lumines-game.dart';
import 'package:tuple/tuple.dart';

class LuminesController {
  final LuminesGame game;
  Tuple4 curBr;
  List<List<int>> board;
  //1: lt, 2: rt, 3: lb, 4: rb
  List<List<int>> borders;
  List<List<int>> scores;
  List<int> boardHeight;
  Queue<Tuple4<int, int, int, int>> nextFive;
  int gameState = 0; // 0: idle. 1: playing. 2: pause. 3: end.
  int score;
  double timeLeft;
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
    borders = new List<List<int>>.generate(BOARD.COL_NUM, (_) => [0,0,0,0,0,0,0,0,0,0], growable: false);
    scores = new List<List<int>>.generate(BOARD.COL_NUM, (_) => [0,0,0,0,0,0,0,0,0,0], growable: false);
    score = 0;
    timeLeft = BOARD.GAME_LENGTH;
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

    checkCouldClear();
  }

  void checkCouldClear({int column:BOARD.COL_NUM}) {
      List<List<int>> cols = board.toList(growable: false);
      // Not sure if this is good way... remove the "could be clear" related state everytime.
      for(int i = 0; i < column; ++i) {
        for(int j = 0; j < cols[i].length; ++j) {
          cols[i][j] = cols[i][j]%2;
          borders[i][j] = 0;
          scores[i][j] = 0;
        }
      }

      for(int i = 0; i < column-1; ++i) {
        for(int j = 1; j < cols[i].length; ++j) {
          if(!(j < cols[i+1].length))
            continue;
          if(cols[i][j]%2 == cols[i+1][j]%2 &&
              cols[i][j]%2 == cols[i][j-1]%2 &&
              cols[i][j]%2 == cols[i+1][j-1]%2) {
            int newVal = cols[i][j]%2+2;
            cols[i][j] = newVal;
            cols[i][j-1] = newVal;
            cols[i+1][j] = newVal;
            cols[i+1][j-1] = newVal;
            borders[i][j] = 1;
            borders[i+1][j] = 2;
            borders[i][j-1] = 3;
            borders[i+1][j-1] = 4;
            scores[i+1][j-1] = 1;
          }
        }
      }
  }

  void cleanUpCol(int col) {
    int sum = 0;
    for(int i = 0; i < scores[col].length; ++i) {
      sum += scores[col][i];
      scores[col][i] = 0;
    }
    borders[col] = [0,0,0,0,0,0,0,0,0,0];
    int pointer = 0;
    while(pointer < board[col].length) {
      if(board[col][pointer] > 1)
        board[col].removeAt(pointer);
      else
        ++pointer;
    }
    boardHeight[col] = board[col].length;
    score += sum;
    checkCouldClear(column:col);
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

  void update(double t) {
    timeLeft -= t;
    if(timeLeft < 0) {
      gameState = 3;
      game.gameAppState.setState(
        () { game.gameAppState.state=3; }
      );
    }
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