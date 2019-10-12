import 'dart:math';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter_lumines/lumines-game.dart';
import 'package:flutter_lumines/vibration-util.dart';

import 'base-game-object.dart';

class SpinningWheel extends BaseGameObject {
  double speed = 100;

  RRect rrect;
  Rect rect;
  int color;//0: orange, 1: grey
  double y;
  double x = 0;
  Paint lightPaint;
  Paint darkPaint;
  Paint blackPaint = new Paint()..color = Color(0xff000000)..strokeWidth = 2.5;
  int rotateState = -1;
  int rotation = 0;

  SpinningWheel(LuminesGame game, this.x, this.y, this.lightPaint, this.darkPaint) : super(game) {
    rect = Rect.fromCenter(center: Offset(x, y), width:150, height:150);
    rrect = RRect.fromRectAndRadius(rect, Radius.circular(75));
  }

  @override
  void render(Canvas c) {
    c.drawRRect(rrect, lightPaint);
    if(rotateState != -1)
      c.drawArc(rect, (90*rotateState.toDouble()-135)/57.3, 90/57.2, true, darkPaint);
    c.drawLine(rrect.center+Offset(-53, -53), rrect.center+Offset(53, 53), blackPaint);
    c.drawLine(rrect.center+Offset(53, -53), rrect.center+Offset(-53, 53), blackPaint);
  }

  @override
  void update(double t) {

  }

  @override
  void contains(double t) {

  }

  // 0: unrotated
  // 1: 90 degree
  // 2: 180 degree
  // 3: 270 degree
  void setOffset(Offset offset) {
    Offset diff = offset - rrect.center;
    int tmpRotateState = -1;
    if(offset.dx == -1 && offset.dy == -1) {
      tmpRotateState = -1;
    } else if(diff.dx.abs() > diff.dy.abs()) {
      if(diff.dx > 0) {
        tmpRotateState = 1;
      } else {
        tmpRotateState = 3;
      }
    } else {
      if(diff.dy > 0) {
        tmpRotateState = 2;
      } else {
        tmpRotateState = 0;
      }
    }
    if(tmpRotateState == -1) {
      VibrationUtil.lightImpact();
      rotateState = tmpRotateState;
    } else if(tmpRotateState != rotateState) {
      VibrationUtil.lightImpact();
      rotation += tmpRotateState - max(0, rotateState);
      rotateState = tmpRotateState;
      rotation = rotation%4;
    }
  }
}