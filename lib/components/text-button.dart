import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/widgets.dart' as prefix0;
import 'package:flutter_lumines/lumines-game.dart';

import 'base-game-object.dart';

class TextButton extends BaseGameObject {
  Rect rect;
  bool pressed = false;
  List<Paint> paint;
  TextPainter tp;
  TextButton(LuminesGame game, this.rect, String data) : super(game) {
    TextSpan text = TextSpan(text: data, style: new prefix0.TextStyle(color: Colors.red));
    this.tp = new TextPainter(text: text, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    paint = [Paint(), Paint()];
    paint[0].color = Color(0xFFAAAAAA);
    paint[1].color = Color(0xFF888888);
  }

  @override
  bool onTapDown(TapDownDetails details) {
    if(!rect.contains(details.globalPosition))
      return false;

    pressed = true;
    Future.delayed(const Duration(milliseconds: 500), () {
      pressed = false;
    });
    
    return true;
  }

  @override
  void render(Canvas c) {
    c.drawRect(pressed?this.rect:this.rect.inflate(1.01), this.paint[pressed?1:0]);
    tp.layout(maxWidth: rect.width, minWidth: rect.width);
    tp.paint(c, Offset(rect.left, rect.top+(rect.height-tp.height)/2));
  }

  @override
  void update(double t) {}
}