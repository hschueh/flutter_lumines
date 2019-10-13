import 'dart:math';
import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_lumines/components/bar.dart';
import 'package:flutter_lumines/components/spinning-wheel.dart';
import 'package:tuple/tuple.dart';
import 'components/brick.dart';
import 'game-controller.dart';
import 'main.dart';
import 'vibration-util.dart';

class LuminesGame extends Game {
  Size screenSize;
  double tileSize;
  Size margin;
  LuminesController controller;
  int touchedCol = -1;
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
  GameAppState gameAppState;

  List<Brick> waitingBrick = List<Brick>();
  BrickTile curTile;

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
    double renderFrom = screenSize.width/4;
    for(int i = 0; i < 5; ++i) {
      double size = i>0?board.blockSizeSmall:board.blockSize;
      waitingBrick.add(Brick(this, renderFrom, 0, 0, i>0));
      waitingBrick.add(Brick(this, renderFrom+size, 0, 0, i>0));
      waitingBrick.add(Brick(this, renderFrom+size, size, 0, i>0));
      waitingBrick.add(Brick(this, renderFrom, size, 0, i>0));
      renderFrom += 2.5*size;
    }
    curTile = BrickTile(this, 7, 0, controller.curBr);
  }
  void setGameAppState(GameAppState state) {
    this.gameAppState = state;
  }

  void reset() {
    controller.initialize();
  }

  void resize(Size size) {
    board = BOARD.getInstance(size);
    screenSize = size;

    _bgColorRect = Rect.fromLTWH(0, board.yOffset, board.boardWidth, board.boardHeight);
    _nextRect = Rect.fromLTWH(0, 0, board.boardWidth, board.yOffset);
    _countDownRect = Rect.fromLTWH(0, 0, board.boardWidth/5, board.yOffset);
  }

  void render(Canvas canvas) {
    canvas.drawPaint(_bgPaint);
    // Draw main board.
    canvas.drawRect(_nextRect, _nextPaint);
    canvas.drawRect(_bgColorRect, darkBluePaint);


    if(touchedCol != -1) {
      Rect lightBlueRect = Rect.fromLTWH(touchedCol*board.blockWidth, board.yOffset, 2*board.blockWidth, board.boardHeight);
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

    // Draw bricks
    if(controller.curBr != null) {
      curTile.layout = controller.curBr;
      // -1 is default state
      curTile.rotate = max(spinningWheel.rotation, 0);
    }

    if(touchedCol != -1) {
      curTile.x = touchedCol;
    } else {
      curTile.x = 7;
    }
    curTile.render(canvas);

    if(controller.nextFive != null) {
      List<Tuple4<int, int, int, int>> nexts = controller.nextFive.toList(growable: false);
      for(int i = 0; i < nexts.length; ++i) {
        waitingBrick[i*4].color = nexts[i].item1;
        waitingBrick[i*4+1].color = nexts[i].item2;
        waitingBrick[i*4+2].color = nexts[i].item3;
        waitingBrick[i*4+3].color = nexts[i].item4;
      }
    }
    waitingBrick.forEach((brick)=>brick.render(canvas));

    if(controller.board != null) {
      List<List<int>> cols = controller.board.toList(growable: false);
      for(int i = 0; i < cols.length; ++i) {
        for(int j = 0; j < cols[i].length; ++j) {
          Brick.renderSingleByXY(this, canvas, cols[i][j], i, BOARD.ROW_NUM-j+1, Brick.borders[controller.borders[i][j]]);
        }
      }
    }
    // End of draw bricks

    slidingBar.render(canvas);

    TextPainter timePainter = new TextPainter(
      text: TextSpan(text: controller.timeLeft.truncate().toString(), style: new TextStyle(color: Colors.black, fontSize: 36)),
      textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    timePainter.layout(maxWidth: screenSize.width, minWidth: _countDownRect.width);
    timePainter.paint(canvas, Offset(_countDownRect.left,_countDownRect.top));

    TextPainter scorePainter = new TextPainter(
      text: TextSpan(text: controller.score.toString(), style: new TextStyle(color: Colors.black, fontSize: 36)),
      textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    scorePainter.layout(maxWidth: screenSize.width, minWidth: screenSize.width/5);
    scorePainter.paint(canvas, Offset(0,board.yOffset+board.boardHeight));

    spinningWheel.render(canvas);
  }

  void update(double t) {
    if(controller.gameState == 1) {
      slidingBar.update(t);
      controller.update(t);
    }
  }

  void startGame() {
    controller.gameState = 1;
    gameAppState.setState(
      () { gameAppState.state=1; }
    );
    reset();
  }

  void pauseGame() {
    controller.gameState = 2;
    gameAppState.setState(
      () { gameAppState.state=2; }
    );
  }

  void resumeGame() {
    controller.gameState = 1;
    gameAppState.setState(
      () { gameAppState.state=1; }
    );
  }

  void cleanUpCol(int col) {
    controller.cleanUpCol(col);
  }

  // Gestures
  void onTapDown(TapDownDetails details) {
    if(_bgColorRect.contains(details.globalPosition)) {
      int colNum = max(0, min(board.boardWidth-2*board.blockWidth, details.globalPosition.dx))~/board.blockWidth;
      if(touchedCol != colNum){
        VibrationUtil.lightImpact();
      }
      touchedCol = colNum;
    }
    else if(spinningWheel.rrect.contains(details.globalPosition)) {
      spinningWheel.setOffset(details.globalPosition);
    }
  }
  void onTapUp(TapUpDetails details) {
    if(_bgColorRect.contains(details.globalPosition)) {
      if(touchedCol != -1){
        VibrationUtil.lightImpact();
        Tuple2<Tuple2<int, int>, Tuple2<int, int>> cur = curTile.getBySide();
        controller.putByTuple(touchedCol, cur.item1, cur.item2);
        spinningWheel.rotation = 0;
        spinningWheel.rotateState = -1;
      }
      touchedCol = -1;
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
    return null;
  }

  handleSpinUpdate(double x, double y) {
    spinningWheel.setOffset(Offset(x, y));
  }

  handleMainUpdate(double x, double y) {
    if(x < 0) {
      if(touchedCol != -1){
        VibrationUtil.lightImpact();
        Tuple2<Tuple2<int, int>, Tuple2<int, int>> cur = curTile.getBySide();
        controller.putByTuple(touchedCol, cur.item1, cur.item2);
        spinningWheel.rotation = 0;
        spinningWheel.rotateState = -1;
      }
      touchedCol = -1;
    } else {
      int colNum = max(0, min(board.boardWidth-2*board.blockWidth, x))~/board.blockWidth;
      if(touchedCol != colNum){
        VibrationUtil.lightImpact();
      }
      touchedCol = colNum;
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