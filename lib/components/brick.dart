import 'dart:ui';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flame/components/component.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_lumines/game-controller.dart';
import 'package:flutter_lumines/lumines-game.dart';
import 'package:tuple/tuple.dart';

import 'base-game-object.dart';

class BrickTile extends BaseGameObject {
  int x,y;
  int rotate = 0;
  // Layout
  // 1 2
  // 4 3
  Tuple4<int, int, int, int> layout;
  List<Brick> bricks = List<Brick>();
  BrickTile(LuminesGame game, this.x, this.y, this.layout) : super(game) {
    Offset offsetTopLeft = Offset(0, game.board.yOffset);
    bricks.add(Brick(game, offsetTopLeft.dx+x*game.board.blockSize, offsetTopLeft.dy+y*game.board.blockSize, layout.item1, false));
    bricks.add(Brick(game, offsetTopLeft.dx+(x+1)*game.board.blockSize, offsetTopLeft.dy+y*game.board.blockSize, layout.item2, false));
    bricks.add(Brick(game, offsetTopLeft.dx+(x+1)*game.board.blockSize, offsetTopLeft.dy+(y+1)*game.board.blockSize, layout.item3, false));
    bricks.add(Brick(game, offsetTopLeft.dx+x*game.board.blockSize, offsetTopLeft.dy+(y+1)*game.board.blockSize, layout.item4, false));
  }

  @override
  void render(Canvas c) {
    bricks[(rotate)%4].color = layout.item1;
    bricks[(rotate+1)%4].color = layout.item2;
    bricks[(rotate+2)%4].color = layout.item3;
    bricks[(rotate+3)%4].color = layout.item4;

    Offset offsetTopLeft = Offset(0, game.board.yOffset);
    bricks[0].x = offsetTopLeft.dx+x*game.board.blockSize;
    bricks[1].x = offsetTopLeft.dx+(x+1)*game.board.blockSize;
    bricks[2].x = offsetTopLeft.dx+(x+1)*game.board.blockSize;
    bricks[3].x = offsetTopLeft.dx+x*game.board.blockSize;

    bricks.forEach((brick)=>brick.render(c));
  }

  @override
  void update(double t) {
  }

  Tuple2<Tuple2<int, int>, Tuple2<int, int>> getBySide() {
    return Tuple2<Tuple2<int, int>, Tuple2<int, int>> (
      Tuple2<int, int>(bricks[0].color, bricks[3].color),
      Tuple2<int, int>(bricks[1].color, bricks[2].color)
    );
  }
}

class Brick extends BaseGameObject {
  Rect rect;
  static Border border = Border.all();
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
    rect = Rect.fromLTWH(x, y, isSmall?game.board.blockSizeSmall:game.board.blockSize, isSmall?game.board.blockSizeSmall:game.board.blockSize);
    c.drawRect(this.rect, color==0?LuminesGame.orangePaint:LuminesGame.greyPaint);
    border.paint(c, rect);
  }

  @override
  void update(double t) {
  }

  static void renderSingleByXY(LuminesGame game, Canvas c, int color, int x, int y) {
    Offset offsetTopLeft = Offset(0, game.board.yOffset);
    Rect rect = Rect.fromLTWH(offsetTopLeft.dx+x*game.board.blockSize, offsetTopLeft.dy+y*game.board.blockSize, game.board.blockSize, game.board.blockSize);
    c.drawRect(rect, color==0?LuminesGame.orangePaint:LuminesGame.greyPaint);
    border.paint(c, rect);
  }
}