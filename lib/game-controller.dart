import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter_lumines/lumines-game.dart';
import 'package:tuple/tuple.dart';

class LuminesController {
  final LuminesGame game;
  LuminesController(this.game);
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

  double boardHeight;
  double boardWidth;
  double blockWidth;
  double blockHeight;
  double blockSize;
  double blockSizeSmall;
}