import 'dart:ui';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flame/components/component.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_lumines/game-controller.dart';
import 'package:flutter_lumines/lumines-game.dart';

import 'base-game-object.dart';

// class BrickTile extends BaseGameObject {
//   BrickTile(LuminesGame game, this.x, this.y, this.color, this.isSmall) : super(game) {
//     rect = Rect.fromLTWH(x*BOARD.BLOCK_WIDTH.toDouble(), y*BOARD.BLOCK_HEIGHT.toDouble(), BOARD.BLOCK_WIDTH.toDouble(), BOARD.BLOCK_HEIGHT.toDouble());
//   }

//   @override
//   void render(Canvas c) {
//     // TODO: implement render
//   }

//   @override
//   void update(double t) {
//     // TODO: implement update
//   }
// }

class Brick extends BaseGameObject {
  Rect rect;
  Border border = Border.all();
  int color;//0: orange, 1: grey
  // int x,y;
  double x,y;
  bool isSmall = false;
  
  var _paint = Paint()..color = Color(0xffffffff);
  var _rectSrc;
  var _rectDst;


  Brick(LuminesGame game, this.x, this.y, this.color, this.isSmall) : super(game) {
    // rect = Rect.fromLTWH(x*BOARD.BLOCK_WIDTH.toDouble(), y*BOARD.BLOCK_HEIGHT.toDouble(), BOARD.BLOCK_WIDTH.toDouble(), BOARD.BLOCK_HEIGHT.toDouble());
    rect = Rect.fromLTWH(x, y, isSmall?game.board.blockSizeSmall:game.board.blockSize, isSmall?game.board.blockSizeSmall:game.board.blockSize);
  }
  

  @override
  void render(Canvas c) {
    c.drawRect(this.rect, color==0?LuminesGame.orangePaint:LuminesGame.greyPaint);
    border.paint(c, rect);
  }

  @override
  void update(double t) {
  }

}