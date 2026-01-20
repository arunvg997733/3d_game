import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:blendertest/controller/game_controller.dart';
import 'package:blendertest/main.dart';
import 'package:blendertest/view/widget.dart/road.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

class Blender extends StatefulWidget {
  const Blender({super.key});

  @override
  State<Blender> createState() => _BlenderState();
}

class _BlenderState extends State<Blender> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  // final AudioPlayer _player = AudioPlayer();
  // final AudioPlayer _player1 = AudioPlayer();

  // final Flutter3DController carController = Flutter3DController();
  // StreamSubscription? _subscription;
  // Timer? _timer;

  // double carPosition = (ScreenUtil().screenWidth / 2) - 65.w;
  // int carSpeed = 5;
  // double carVertical = 30;

  // final int maxSpeed = 15;
  // final int minSpeed = 5;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 1), // infinite time
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameController>().init();
    });
    // playAudio();
    // _subscription = accelerometerEvents.listen((event) {
    //   if (event.x > 2) {
    //     rotateLeft();
    //   } else if (event.x < -2) {
    //     rotateRight();
    //   } else {
    //     carController.setCameraOrbit(0, carVertical, 100);
    //   }
    // });
  }

  // Future<void> playAudio() async {
  //   await _player.setReleaseMode(ReleaseMode.loop);
  //   await _player.play(AssetSource("audio/normal_ride.mp3"));
  // }

  // Future<void> playRace() async {
  //   await _player.setReleaseMode(ReleaseMode.loop);
  //   await _player.play(AssetSource("audio/race.mp3"));
  // }

  // Future<void> playHit() async {
  //   await _player1.play(AssetSource("audio/car_hit _side.wav"));
  // }

  // Future<void> stopAudio() async {
  //   await _player.stop();
  // }

  // @override
  // void dispose() {
  //   controller.dispose();
  //   _subscription?.cancel();
  //   _player.dispose();
  //   _timer?.cancel();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<GameController>();
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) {
          provider.carVertical = 5;
          provider.playRaceAudio();
        },
        onLongPressStart: (_) async {
          provider.accelerate();
        },

        onLongPressEnd: (_) {
          provider.decelerate();
        },

        onPanEnd: (_) {
          provider.decelerate();
        },

        // onTapDown: (_) => _accelerate(),
        // onTapUp: (_) => _decelerate(),
        // onTapCancel: _decelerate,
        child: Container(
          color: Colors.green,
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  final elapsed =
                      controller.lastElapsedDuration?.inMilliseconds ?? 0;

                  return Align(
                    child: Transform.scale(
                      scale: 1.5,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateX(-30 * pi / 180),
                        child: SizedBox(
                          width: 200,
                          height: 700,
                          child: CustomPaint(
                            painter: RoadPainter(
                              elapsed * 0.05 * provider.carSpeed,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // 🚗 CAR
              Consumer(
                builder: (context, value, child) {
                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    bottom: 100.h,
                    left: provider.carPosition,
                    child: SizedBox(
                      height: 130.w,
                      width: 130.w,
                      child: Flutter3DViewer(
                        enableTouch: false,
                        activeGestureInterceptor: false,
                        controller: provider.carController,
                        src: 'assets/lanb.glb',
                        onLoad: (_) {
                          provider.carController.setCameraOrbit(
                            0,
                            provider.carVertical,
                            100,
                          );
                          provider.carController.setCameraTarget(0, 0.9, 0);
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // void _accelerate() {
  //   carVertical = 5;
  //   _timer?.cancel();
  //   _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
  //     if (carSpeed < maxSpeed) {
  //       setState(() => carSpeed += 1);
  //       print("car speed ------------- $carSpeed");
  //     }
  //   });
  // }

  // void _decelerate() {
  //   stopAudio();
  //   playAudio();
  //   setState(() {
  //     carVertical = 30;
  //   });
  //   // carController.setCameraOrbit(0, 35, 100);
  //   _timer?.cancel();
  //   _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
  //     if (carSpeed > minSpeed) {
  //       setState(() => carSpeed -= 1);
  //       print("car speed ------------- $carSpeed");
  //     } else {
  //       _timer?.cancel();
  //     }
  //   });
  // }

  // void rotateLeft() {
  //   if (carPosition > 0) {
  //     setState(() => carPosition -= 2);
  //     carController.setCameraOrbit(-10, carVertical, 100);
  //   } else {
  //     playHit();
  //     carController.setCameraOrbit(2, carVertical, 100);
  //   }
  // }

  // void rotateRight() {
  //   if (carPosition < ScreenUtil().screenWidth - 130.w) {
  //     setState(() => carPosition += 2);
  //     carController.setCameraOrbit(10, carVertical, 100);
  //   } else {
  //     playHit();
  //     carController.setCameraOrbit(-2, carVertical, 100);
  //   }
  // }
}
