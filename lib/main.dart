import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flame/util.dart';
import 'package:flutter_lumines/lumines-game.dart';
import 'package:firebase_admob/firebase_admob.dart';

void main() async {
  // FirebaseAdMob.instance.initialize(appId: "ca-app-pub-3940256099942544~3347511713");
  // MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  //   keywords: <String>['flutterio', 'beautiful apps'],
  //   contentUrl: 'https://flutter.io',
  //   birthday: DateTime.now(),
  //   childDirected: false,
  //   designedForFamilies: false,
  //   gender: MobileAdGender.male, // or MobileAdGender.female, MobileAdGender.unknown
  //   testDevices: <String>[], // Android emulators are considered test devices
  // );
  // BannerAd myBanner = BannerAd(
  //   // Replace the testAdUnitId with an ad unit id from the AdMob dash.
  //   // https://developers.google.com/admob/android/test-ads
  //   // https://developers.google.com/admob/ios/test-ads
  //   adUnitId: BannerAd.testAdUnitId,
  //   size: AdSize.smartBanner,
  //   targetingInfo: targetingInfo,
  //   listener: (MobileAdEvent event) {
  //     print("BannerAd event is $event");
  //   },
  // );
  // myBanner
  // // typically this happens well before the ad is shown
  // ..load()
  // ..show(
  //   anchorOffset: 0.0,
  //   anchorType: AnchorType.top,
  // );

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

class GameApp extends StatelessWidget {
  LuminesGame game;
  GameApp(this.game);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Playing Scene',
      home: Stack(
        children: [
          Center(
            child: game.widget,
          ),
          // Container(
          //   alignment: Alignment.center,
          //   margin: EdgeInsets.all(16),
          //   child: Stack(
          //     children: [
          //       Align(
          //         alignment: Alignment.bottomLeft,
          //         child: FloatingActionButton.extended(
          //           onPressed: () {
          //             // Add your onPressed code here!
          //           },
          //           label: Text('退出'),
          //           icon: Icon(Icons.arrow_back)
          //         )
          //       ),
          //     ]
          //   ),
          // ),
        ],
      ),
    );
  }
}