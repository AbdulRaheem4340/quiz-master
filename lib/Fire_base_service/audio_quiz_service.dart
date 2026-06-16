import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';  

class QuizAudioService {
  static final AudioPlayer _player=AudioPlayer();

  static Future<void> playCorrect() async {
    try {
      await _player.stop();

      await _player.play(AssetSource('ding.mp3'));
    } catch (e) {
      debugPrint("❌ Error playing sound: $e");
    }
  }
  static Future<void> playWrong() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('buzz.mp3'));
    } catch (e) {
      debugPrint("❌ Error playing sound: $e");
    }
  }

  static Future<void> playCongrats() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('win.mp3'));
    } catch (e) {
      debugPrint("❌ Error playing sound: $e");
    }
  }
}
