import 'dart:async';

import 'package:flutter/services.dart';

class Audioset {
  static const MethodChannel _channel = const MethodChannel('audioset');
  static const methodPlay = "playMusic";
  static const methodSetMusicSide = "playMusicSpeaker";
  static const nativeMethodSetVolume = "setMusicVolume";

  static const asset = "asset";
  static const type = "type";
  static const file = "file";
  static const url = "url";
  static const musicF = "musicFile";
  static const spkSide = "speakerSide";
  static const vol = "volume";

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  void plaMusic(String assetPath, int musicFile) {
    _invokeNativeMethod(
      methodPlay,
      arguments: <String, dynamic>{
        asset: assetPath,
        type: "mp3",
        file: musicFile,
      },
    );
  }
  //1 min

  void setMusicSide(double speakerSide, int musicFile) {
    _invokeNativeMethod(
      methodSetMusicSide,
      arguments: <String, dynamic>{
        spkSide: speakerSide,
        file: musicFile,
      },
    );
  }

  void setVolume(int musicFile, int volume) {
    _invokeNativeMethod(
      nativeMethodSetVolume,
      arguments: <String, dynamic>{file: musicFile, vol: volume},
    );
  }

  Future _invokeNativeMethod(String method,
      {Map<String, dynamic> arguments}) async {
    try {
      await _channel.invokeMethod(method, arguments);
    } on PlatformException catch (e) {
      print("Failed to call native method: " + e.message);
    }
  }
}
