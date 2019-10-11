import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter_lumines/lumines-game.dart';

abstract class BaseGameObject {
  final LuminesGame game;
  BaseGameObject(this.game);
  void update(double t);
  void render(Canvas c);
  // Return false to continue the event passing.
  bool onTapDown(TapDownDetails details){
    return false;
  }
}