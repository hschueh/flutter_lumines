import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter_lumines/game-controller.dart';
import 'package:flutter_lumines/lumines-game.dart';

import 'base-game-object.dart';

class Bar extends BaseGameObject {
  double speed;

  Rect rect;
  int color;//0: orange, 1: grey
  double y;
  double x = 0;
  int column = 0;
  Paint paint;

  Bar(LuminesGame game, this.y, this.paint) : super(game) {
    speed = game.board.boardWidth / 5;
    rect = Rect.fromLTWH(x*BOARD.BLOCK_WIDTH.toDouble(), y*BOARD.BLOCK_HEIGHT.toDouble(), BOARD.BLOCK_WIDTH.toDouble(), BOARD.BLOCK_HEIGHT.toDouble());
  }

  @override
  void render(Canvas c) {
    c.drawLine(Offset(x, y), Offset(x, BOARD.getInstance(null).boardHeight+y), paint);
  }

  @override
  void update(double t) {
    x += t*speed;
    x = x%BOARD.getInstance(null).boardWidth;
    int newCol = (x/game.board.blockWidth).floor();
    if(newCol != column) {
      game.cleanUpCol(column);
      column = newCol;
    }
  }
}