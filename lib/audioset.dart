import 'dart:async';

import 'package:flutter/services.dart';

class Audioset {
  static const MethodChannel _channel = const MethodChannel('audioset');
  static const methodPlay = "playMusic";
  static const methodSetMusicSide = "playMusicSpeaker";
  static const nativeMethodSetVolume = "setMusicVolume";
  static const resumeMethod = "playMusicResumed";
  static const pauseMethod = "playMusicPaused";
  static const stopMethod = "playMusicPaused";
  static const muteMethod = "playMusicMuted";

  static const asset = "asset";
  static const type = "type";
  static const file = "file";
  static const url = "url";
  static const musicF = "musicFile";
  static const spkSide = "speakerSide";
  static const vol = "volume";
  static const isRepeat = "isRepeat";

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
        isRepeat: true,
      },
    );
  }

  //1 min
  void plaFreqMusic(String assetPath, int musicFile, double speakerSide,
      List frequency, bool isIncreasedVolume, int filterType) {
    _invokeNativeMethod(
      "playMusicFrerquency",
      arguments: <String, dynamic>{
        asset: assetPath,
        type: "mp3",
        file: musicFile,
        spkSide: speakerSide,
        "frequency": frequency,
        "isEveryFiveSecIncreseVolume": isIncreasedVolume,
        "filterType": filterType,
      },
    );
  }

  void setMusicSide(double speakerSide, int musicFile) {
    _invokeNativeMethod(
      methodSetMusicSide,
      arguments: <String, dynamic>{
        spkSide: speakerSide,
        file: musicFile,
      },
    );
  }

  void resume(int musicFile) {
    _invokeNativeMethod(
      resumeMethod,
      arguments: <String, dynamic>{file: musicFile},
    );
  }

  void pause(int musicFile) {
    _invokeNativeMethod(
      pauseMethod,
      arguments: <String, dynamic>{file: musicFile},
    );
  }

  void stop(int musicFile) {
    _invokeNativeMethod(
      stopMethod,
      arguments: <String, dynamic>{file: musicFile},
    );
  }

  void mute(int musicFile) {
    _invokeNativeMethod(
      muteMethod,
      arguments: <String, dynamic>{file: musicFile},
    );
  }

  void setVolume(int musicFile, double volume) {
    _invokeNativeMethod(
      nativeMethodSetVolume,
      arguments: <String, dynamic>{file: musicFile, vol: volume},
    );
  }

  Future<dynamic> getVolume(int musicFile) async {
    Map<dynamic, dynamic> volume =
        await _channel.invokeMethod('getMusicVolume');
    return volume;
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
