import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flame/util.dart';
import 'package:flutter_lumines/lumines-game.dart';
import 'package:firebase_admob/firebase_admob.dart';

void main() async {
  FirebaseAdMob.instance.initialize(appId: "ca-app-pub-3940256099942544~3347511713");
  MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: <String>['flutterio', 'beautiful apps'],
    contentUrl: 'https://flutter.io',
    childDirected: false,
    testDevices: <String>[], // Android emulators are considered test devices
  );
  BannerAd myBanner = BannerAd(
    // Replace the testAdUnitId with an ad unit id from the AdMob dash.
    // https://developers.google.com/admob/android/test-ads
    // https://developers.google.com/admob/ios/test-ads
    adUnitId: BannerAd.testAdUnitId,
    size: AdSize.smartBanner,
    targetingInfo: targetingInfo,
    listener: (MobileAdEvent event) {
      print("BannerAd event is $event");
    },
  );
  myBanner
  // typically this happens well before the ad is shown
  ..load()
  ..show(
    anchorOffset: 0.0,
    anchorType: AnchorType.bottom,
  );

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  Util flameUtil = Util();
  await flameUtil.fullScreen();

  LuminesGame game = LuminesGame();
  runApp(GameApp(game));
  flameUtil.addGestureRecognizer(createTapRecognizer(game));
  flameUtil.addGestureRecognizer(createDragRecognizer(game));

}
GestureRecognizer createDragRecognizer(LuminesGame game) {
  return new ImmediateMultiDragGestureRecognizer()
    ..onStart = (Offset position) => game.handleDrag(position);
}
GestureRecognizer createTapRecognizer(LuminesGame game) {
  return new TapGestureRecognizer()
    ..onTapDown = game.onTapDown
    ..onTapUp = game.onTapUp;
}

class GameApp extends StatefulWidget {
  final LuminesGame game;
  GameApp(this.game);

  startGame() {
    game.startGame();
  }

  pauseGame() {
    game.pauseGame();
  }

  resumeGame() {
    game.resumeGame();
  }

  @override
  GameAppState createState() {
    State<GameApp> state = GameAppState();
    game.setGameAppState(state);
    return state;
  }
}

class GameAppState extends State<GameApp> {
  int state = 0;

  @override
  Widget build(BuildContext context) {
  final List<FloatingActionButton> fabList =[ FloatingActionButton.extended(
                    onPressed: () {
                      widget.startGame();
                    },
                    label: Text('開始'),
                    icon: Icon(Icons.play_arrow)
                  ),
                  FloatingActionButton.extended(
                    onPressed: () {
                      widget.pauseGame();
                    },
                    label: Text('暫停'),
                    icon: Icon(Icons.pause)
                  ),
                  FloatingActionButton.extended(
                    onPressed: () {
                      widget.resumeGame();
                    },
                    label: Text('回到遊戲'),
                    icon: Icon(Icons.restore)
                  )];
    return MaterialApp(
      title: 'Playing Scene',
      home: Stack(
        children: [
          Center(
            child: widget.game.widget,
          ),
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.fromLTRB(16, 0, 0, 64),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: fabList[state%3]
                ),
              ]
            ),
          ),
        ],
      ),
    );
  }
}