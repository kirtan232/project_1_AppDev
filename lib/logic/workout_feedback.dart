import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

import 'app_settings.dart';

// This class plays the beep and the vibration during a workout.
// It follows the Volume, Music, and Vibration choices in Settings.
class WorkoutFeedback {
  // One player is shared for the whole app, so it is never disposed.
  static final AudioPlayer _player = AudioPlayer();

  // This method runs when a countdown reaches zero.
  static Future<void> play() async {
    final settings = AppSettings.instance;

    if (settings.vibrationOn) {
      await HapticFeedback.vibrate();
    }

    if (!settings.musicOn || settings.volume == 0) return;

    // A sound problem should never stop the workout, so errors are ignored here.
    try {
      await _player.stop();
      await _player.play(
        AssetSource('sounds/beep.wav'),
        volume: settings.volume,
      );
    } catch (e) {
      return;
    }
  }
}
