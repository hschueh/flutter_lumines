import 'dart:math';
import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:tuple/tuple.dart';

import 'components/text-button.dart';
import 'game-controller.dart';

class LuminesGame extends Game {
  Size screenSize;
  double tileSize;
  Size margin;
  LuminesController controller;
  int touchedRow = -1;
  // double touchY = -1;

  static Paint darkBluePaint = Paint()..color = Color(0xff171779);
  static Paint bluePaint = Paint()..color = Color(0xff4f4ff7);
  static Paint orangePaint = Paint()..color = Color(0xffff8000);
  static Paint darkOrangePaint = Paint()..color = Color(0xffb33903);
  static Paint greyPaint = Paint()..color = Color(0xffe5e5e5);
  static Paint darkGreyPaint = Paint()..color = Color(0xff575757);
  static Paint slideBarPaint = Paint()..color = Color(0xffff6666)..strokeWidth = 5;
  static Paint roofPaint = Paint()..color = Color(0xff800080)..strokeWidth = 5;
  static Paint gridPaint = Paint()..color = Color(0xff000000)..strokeWidth = 1.5;
  static Rect _nextRect;
  static Paint _nextPaint = Paint()..color = Color(0xfffc66ff);
  
  Rect _bgColorRect;
  Paint _bgPaint = Paint()..color = Color(0xffffffff);
  BOARD board;
  DraggableMain mainDragger;
  DraggableSpinner spinnerDragger;

  LuminesGame() {
    initialize();
  }

  void initialize() async {
    resize(await Flame.util.initialDimensions());
    mainDragger = DraggableMain(this);
    spinnerDragger = DraggableSpinner(this);
  }

  void render(Canvas canvas) {
    canvas.drawPaint(_bgPaint);
    // Draw main board.
    canvas.drawRect(_nextRect, _nextPaint);
    canvas.drawRect(_bgColorRect, darkBluePaint);


    if(touchedRow != -1) {
      Rect lightBlueRect = Rect.fromLTWH(touchedRow*board.blockWidth, 75, 2*board.blockWidth, board.boardHeight);
      canvas.drawRect(lightBlueRect, bluePaint);
    }


    for(int i = 1; i < BOARD.COL_NUM; ++i) {
      canvas.drawLine(Offset(i*board.blockSize,_bgColorRect.top), Offset(i*board.blockSize,_bgColorRect.top+board.boardHeight), gridPaint);
    }
    for(int i = 1; i < BOARD.ROW_NUM+2; ++i) {
      canvas.drawLine(Offset(0,_bgColorRect.top+i*board.blockSize), Offset(board.boardWidth,_bgColorRect.top+i*board.blockSize), gridPaint);
    }
    canvas.drawLine(Offset(0,_bgColorRect.top+2*board.blockSize), Offset(board.boardWidth,_bgColorRect.top+2*board.blockSize), roofPaint);
    // End of draw main board.
  }

  void update(double t) {
  }

  void resize(Size size) {
    board = BOARD.getInstance(size);
    screenSize = size;

    _bgColorRect = Rect.fromLTWH(0, 75, board.boardWidth, board.boardHeight);
    _nextRect = Rect.fromLTWH(0, 0, board.boardWidth, 75);
  }

  void onTapDown(TapDownDetails details) {
    if(_bgColorRect.contains(details.globalPosition)) {
      touchedRow = max(0, min(board.boardWidth-2*board.blockWidth, details.globalPosition.dx))~/board.blockWidth;
    }
  }
  void onTapUp(TapUpDetails details) {
    if(_bgColorRect.contains(details.globalPosition)) {
      touchedRow = -1;
    }
  }

  Drag handleDrag(Offset offset) {
    if(_bgColorRect.contains(offset)) {
      return mainDragger;
    } else {
      // do nothing
    }
  }

  handleSpinUpdate(double x, double y) {
    
  }
  handleMainUpdate(double x, double y) {
    if(x < 0)
      touchedRow = -1;
    else
      touchedRow = max(0, min(board.boardWidth-2*board.blockWidth, x))~/board.blockWidth;
  }


  static Future<void> selectionClick() async {
    await SystemChannels.platform.invokeMethod<void>(
      'HapticFeedback.vibrate',
      'HapticFeedbackType.selectionClick',
    );
  }

  static Future<void> lightImpact() async {
    await SystemChannels.platform.invokeMethod<void>(
      'HapticFeedback.vibrate',
      'HapticFeedbackType.lightImpact',
    );
  }
}

class DraggableMain implements Drag {
  LuminesGame game;
  DraggableMain(this.game);
  @override
  void cancel() {
    game.handleMainUpdate(-1, -1);
  }

  @override
  void end(DragEndDetails details) {
    game.handleMainUpdate(-1, -1);
  }

  @override
  void update(DragUpdateDetails details) {
    game.handleMainUpdate(details.globalPosition.dx, details.globalPosition.dy);
  }
}

class DraggableSpinner implements Drag {
  LuminesGame game;
  DraggableSpinner(this.game);
  @override
  void cancel() {
    // TODO: implement cancel
  }

  @override
  void end(DragEndDetails details) {
    // TODO: implement end
  }

  @override
  void update(DragUpdateDetails details) {
    game.handleSpinUpdate(details.globalPosition.dx, details.globalPosition.dy);
  }
}