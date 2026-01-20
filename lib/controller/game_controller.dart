import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sensors_plus/sensors_plus.dart';

class GameController extends ChangeNotifier {
  final Flutter3DController carController = Flutter3DController();

  final AudioPlayer _normalPlayer = AudioPlayer();
  final AudioPlayer _racePlayer = AudioPlayer();
  final AudioPlayer _hitPlayer = AudioPlayer();

  StreamSubscription? _sensorSub;
  Timer? _speedTimer;

  double carPosition = (ScreenUtil().screenWidth / 2) - 65.w;
  int carSpeed = 5;
  double carVertical = 30;

  final int maxSpeed = 15;
  final int minSpeed = 5;

  /// INIT
  void init() {
    _playNormalAudio();

    _sensorSub = accelerometerEvents.listen((event) {
      if (event.x > 2) {
        rotateLeft();
      } else if (event.x < -2) {
        rotateRight();
      } else {
        carController.setCameraOrbit(0, carVertical, 100);
      }
    });
  }

  /// AUDIO
  Future<void> _playNormalAudio() async {
    await _normalPlayer.setReleaseMode(ReleaseMode.loop);
    await _normalPlayer.play(AssetSource("audio/normal_ride.mp3"));
  }

  Future<void> playRaceAudio() async {
    await _normalPlayer.stop();
    await _racePlayer.setReleaseMode(ReleaseMode.loop);
    await _racePlayer.play(AssetSource("audio/race.mp3"));
  }

  Future<void> playHitAudio() async {
    await _hitPlayer.play(AssetSource("audio/car_hit _side.wav"));
  }

  /// SPEED CONTROL
  void accelerate() {
    carVertical = 5;
    notifyListeners();

    _speedTimer?.cancel();
    _speedTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (carSpeed < maxSpeed) {
        carSpeed++;
        notifyListeners();
      }
    });
  }

  void decelerate() {
    carVertical = 30;
    notifyListeners();

    _racePlayer.stop();
    _playNormalAudio();

    _speedTimer?.cancel();
    _speedTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (carSpeed > minSpeed) {
        carSpeed--;
        notifyListeners();
      } else {
        _speedTimer?.cancel();
      }
    });
  }

  /// MOVEMENT
  void rotateLeft() {
    if (carPosition > 0) {
      carPosition -= 1;
      carController.setCameraOrbit(-10, carVertical, 100);
    } else {
      playHitAudio();
      carController.setCameraOrbit(2, carVertical, 100);
    }
    print("fjasfioasjfdo == $carPosition");
    notifyListeners();
  }

  void rotateRight() {
    if (carPosition < ScreenUtil().screenWidth - 130.w) {
      carPosition += 2;
      carController.setCameraOrbit(10, carVertical, 100);
    } else {
      playHitAudio();
      carController.setCameraOrbit(-2, carVertical, 100);
    }
    notifyListeners();
  }

  /// DISPOSE
  @override
  void dispose() {
    _sensorSub?.cancel();
    _speedTimer?.cancel();
    _normalPlayer.dispose();
    _racePlayer.dispose();
    _hitPlayer.dispose();
    super.dispose();
  }
}
