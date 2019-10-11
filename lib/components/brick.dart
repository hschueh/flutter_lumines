import 'dart:ui';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flame/components/component.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_lumines/game-controller.dart';
import 'package:flutter_lumines/lumines-game.dart';

import 'base-game-object.dart';

class Brick extends BaseGameObject {
  static const double ANIMATION_LENGTH = 0.25;


  Rect rect;
  int color;//0: orange, 1: grey
  int x,y;
  
  var _paint = Paint()..color = Color(0xffffffff);
  var _rectSrc;
  var _rectDst;


  Brick(LuminesGame game, this.x, this.y, this.color) : super(game) {
    rect = Rect.fromLTWH(x*BOARD.BLOCK_WIDTH.toDouble(), y*BOARD.BLOCK_HEIGHT.toDouble(), BOARD.BLOCK_WIDTH.toDouble(), BOARD.BLOCK_HEIGHT.toDouble());
  }
  

  @override
  void render(Canvas c) {
    c.drawRect(this.rect, color==0?LuminesGame.orangePaint:LuminesGame.orangePaint);
  }

  @override
  void update(double t) {
  }

}