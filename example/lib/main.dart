import 'package:flutter/material.dart';
import 'package:audioset/audioset.dart';

import 'custom_button.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
//    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Audioset audioset = Audioset();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HOME"),
      ),
      body: Container(
        child: Column(
          children: [
            CustomButton(
              text: "Play 1",
              onTap: () {
                audioset.plaFreqMusic("assets/sounds/bear.mp3", 1, 1.0,
                    [100.0, 500.0, 750.0, 1000, 0]);
              },
            ),

            // And path pn get kre j che iOS ma
            CustomButton(
              text: "Play 2",
              onTap: () {
                audioset.plaMusic("assets/sounds/bear.mp3", 2);
              },
            ),

            // And path pn get kre j che iOS ma
            CustomButton(
              text: "Play Bo Mp3",
              onTap: () {
                audioset.plaMusic("assets/sounds/bear.mp3", 1);
                audioset.plaMusic("assets/sounds/nat.mp3", 2);
              },
            ),

            CustomButton(
              text: "Speaker Left Both",
              onTap: () {
                audioset.setMusicSide(-1.0, 1);
                audioset.setMusicSide(-1.0, 2);
              },
            ),

            CustomButton(
              text: "Speaker Right BOTH",
              onTap: () {
                audioset.setMusicSide(1.0, 1);
                audioset.setMusicSide(1.0, 2);
              },
            ),

            CustomButton(
              text: "Speaker Both Files",
              onTap: () {
                audioset.setMusicSide(0.0, 1);
                audioset.setMusicSide(0.0, 2);
              },
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: CustomButton(
                    text: "Volume Increase File 1",
                    onTap: () {
                      //   audioset.setVolume(1, 1);
                    },
                  ),
                ),
                Flexible(
                  child: CustomButton(
                    text: "Volume Decrease File 1 ",
                    onTap: () {
                      //  audioset.setVolume(1, 0);
                    },
                  ),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: CustomButton(
                    text: "Resume File 1",
                    onTap: () {
                      audioset.resume(1);
                    },
                  ),
                ),
                Flexible(
                  child: CustomButton(
                    text: "Pause File 1 ",
                    onTap: () {
                      audioset.pause(1);
                    },
                  ),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: CustomButton(
                    text: "STOP File 1",
                    onTap: () {
                      audioset.stop(1);
                    },
                  ),
                ),
                Flexible(
                  child: CustomButton(
                    text: "STOP File 2 ",
                    onTap: () {
                      audioset.stop(2);
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
