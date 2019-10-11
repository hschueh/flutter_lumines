import 'dart:math';
import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_lumines/components/bar.dart';
import 'package:flutter_lumines/components/spinning-wheel.dart';
import 'package:tuple/tuple.dart';
import 'components/brick.dart';
import 'components/text-button.dart';
import 'game-controller.dart';
import 'vibration-util.dart';

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
  static Rect _countDownRect;

  Rect _bgColorRect;
  Paint _bgPaint = Paint()..color = Color(0xffffffff);
  BOARD board;
  DraggableMain mainDragger;
  DraggableSpinner spinnerDragger;
  Bar slidingBar;
  SpinningWheel spinningWheel;
  double timeLeft;
  int gameState = 0;

  List<Brick> waitingBrick = List<Brick>();

  LuminesGame() {
    initialize();
    controller = LuminesController(this);
  }
  /*
  @override
  void render(Canvas c) {
    c.drawRect(pressed?this.rect:this.rect.inflate(1.01), this.paint[pressed?1:0]);
    tp.layout(maxWidth: rect.width, minWidth: rect.width);
    tp.paint(c, Offset(rect.left, rect.top+(rect.height-tp.height)/2));
   */

  void initialize() async {
    resize(await Flame.util.initialDimensions());
    mainDragger = DraggableMain(this);
    spinnerDragger = DraggableSpinner(this);
    slidingBar = Bar(this, board.yOffset, slideBarPaint);
    spinningWheel = SpinningWheel(this, board.boardWidth/2, board.boardHeight+board.yOffset+95, greyPaint, darkGreyPaint);
    timeLeft = BOARD.GAME_LENGTH;
    double renderFrom = screenSize.width/4;
    for(int i = 0; i < 5; ++i) {
      double size = i>0?board.blockSizeSmall:board.blockSize;
      waitingBrick.add(Brick(this, renderFrom, 0, 0, i>0));
      waitingBrick.add(Brick(this, renderFrom, size, 0, i>0));
      waitingBrick.add(Brick(this, renderFrom+size, 0, 0, i>0));
      waitingBrick.add(Brick(this, renderFrom+size, size, 0, i>0));
      renderFrom += 2.5*size;
    }
  }
  void resize(Size size) {
    board = BOARD.getInstance(size);
    screenSize = size;

    _bgColorRect = Rect.fromLTWH(0, board.yOffset, board.boardWidth, board.boardHeight);
    _nextRect = Rect.fromLTWH(0, 0, board.boardWidth, board.yOffset);
    _countDownRect = Rect.fromLTWH(0, 0, board.boardWidth, board.yOffset);
  }

  void render(Canvas canvas) {
    canvas.drawPaint(_bgPaint);
    // Draw main board.
    canvas.drawRect(_nextRect, _nextPaint);
    canvas.drawRect(_bgColorRect, darkBluePaint);

    if(controller.nextFive != null) {
      List<Tuple4<int, int, int, int>> nexts = controller.nextFive.toList();
      for(int i = 0; i < nexts.length; ++i) {
        waitingBrick[i*4].color = nexts[i].item1;
        waitingBrick[i*4+1].color = nexts[i].item2;
        waitingBrick[i*4+2].color = nexts[i].item3;
        waitingBrick[i*4+3].color = nexts[i].item4;
      }
    }
    waitingBrick.forEach((brick)=>brick.render(canvas));


    if(touchedRow != -1) {
      Rect lightBlueRect = Rect.fromLTWH(touchedRow*board.blockWidth, board.yOffset, 2*board.blockWidth, board.boardHeight);
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
    slidingBar.render(canvas);

    TextPainter textPainter = new TextPainter(
      text: TextSpan(text: timeLeft.truncate().toString(), style: new TextStyle(color: Colors.black, fontSize: 36)),
      textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    textPainter.layout(maxWidth: screenSize.width, minWidth: screenSize.width/5);
    textPainter.paint(canvas, Offset(0,0));

    spinningWheel.render(canvas);
  }

  void update(double t) {
    if(gameState == 1) {
      slidingBar.update(t);
      timeLeft -= t;
    }

    if(timeLeft <= 0)
      gameState = 0;
  }

  void startGame() {
    if(gameState == 0 || timeLeft <= 0)
      timeLeft = BOARD.GAME_LENGTH;
    gameState = 1;
  }

  void pause() {
    gameState = 2;
  }

  // Gestures
  void onTapDown(TapDownDetails details) {
    if(_bgColorRect.contains(details.globalPosition)) {
      int rowNum = max(0, min(board.boardWidth-2*board.blockWidth, details.globalPosition.dx))~/board.blockWidth;
      if(touchedRow != rowNum){
        VibrationUtil.lightImpact();
      }
      touchedRow = rowNum;
    }
    else if(spinningWheel.rrect.contains(details.globalPosition)) {
      spinningWheel.setOffset(details.globalPosition);
    }
  }
  void onTapUp(TapUpDetails details) {
    if(_bgColorRect.contains(details.globalPosition)) {
      if(touchedRow != -1){
        VibrationUtil.lightImpact();
      }
      touchedRow = -1;
    }
    else if(spinningWheel.rrect.contains(details.globalPosition)) {
      spinningWheel.setOffset(Offset(-1, -1));
    }
  }

  Drag handleDrag(Offset offset) {
    if(_bgColorRect.contains(offset)) {
      return mainDragger;
    } 
    else if(spinningWheel.rrect.contains(offset)) {
      return spinnerDragger;
    }
  }

  handleSpinUpdate(double x, double y) {
    spinningWheel.setOffset(Offset(x, y));
  }

  handleMainUpdate(double x, double y) {
    if(x < 0) {
      if(touchedRow != -1){
        VibrationUtil.lightImpact();
      }
      touchedRow = -1;
    } else {
      int rowNum = max(0, min(board.boardWidth-2*board.blockWidth, x))~/board.blockWidth;
      if(touchedRow != rowNum){
        VibrationUtil.lightImpact();
      }
      touchedRow = rowNum;
    }
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
    game.handleSpinUpdate(-1, -1);
  }

  @override
  void end(DragEndDetails details) {
    game.handleSpinUpdate(-1, -1);
  }

  @override
  void update(DragUpdateDetails details) {
    game.handleSpinUpdate(details.globalPosition.dx, details.globalPosition.dy);
  }
}