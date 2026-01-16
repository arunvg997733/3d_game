import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 836),
      builder: (_, __) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Blender(),
        );
      },
    );
  }
}

class Blender extends StatefulWidget {
  const Blender({super.key});

  @override
  State<Blender> createState() => _BlenderState();
}

class _BlenderState extends State<Blender> with SingleTickerProviderStateMixin {
  late AnimationController controller;

  final Flutter3DController carController = Flutter3DController();
  StreamSubscription? _subscription;
  Timer? _timer;

  double carPosition = (ScreenUtil().screenWidth / 2) - 65.w;
  int carSpeed = 3;
  double carVertical = 30;

  final int maxSpeed = 15;
  final int minSpeed = 3;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 1), // infinite time
    )..forward();

    _subscription = accelerometerEvents.listen((event) {
      if (event.x > 2) {
        rotateLeft();
      } else if (event.x < -2) {
        rotateRight();
      } else {
        carController.setCameraOrbit(0, carVertical, 100);
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    _subscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) {
          carVertical = 5;
        },
        onLongPressStart: (_) {
          _accelerate();
        },

        onLongPressEnd: (_) {
          _decelerate();
        },

        onPanEnd: (_) {
          _decelerate();
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
                            painter: RoadPainter(elapsed * 0.05 * carSpeed),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // 🚗 CAR
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                bottom: 0,
                left: carPosition,
                child: SizedBox(
                  height: 130.w,
                  width: 130.w,
                  child: Flutter3DViewer(
                    enableTouch: false,
                    activeGestureInterceptor: false,
                    controller: carController,
                    src: 'assets/lanb.glb',
                    onLoad: (_) {
                      carController.setCameraOrbit(0, carVertical, 100);
                      carController.setCameraTarget(0, 0.9, 0);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _accelerate() {
    carVertical = 5;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (carSpeed < maxSpeed) {
        setState(() => carSpeed += 1);
        print("car speed ------------- $carSpeed");
      }
    });
  }

  void _decelerate() {
    setState(() {
      carVertical = 30;
    });
    // carController.setCameraOrbit(0, 35, 100);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (carSpeed > minSpeed) {
        setState(() => carSpeed -= 1);
        print("car speed ------------- $carSpeed");
      } else {
        _timer?.cancel();
      }
    });
  }

  void rotateLeft() {
    if (carPosition > 0) {
      setState(() => carPosition -= 2);
    }
    carController.setCameraOrbit(-10, carVertical, 100);
  }

  void rotateRight() {
    if (carPosition < ScreenUtil().screenWidth - 130.w) {
      setState(() => carPosition += 2);
    }
    carController.setCameraOrbit(10, carVertical, 100);
  }
}

class RoadPainter extends CustomPainter {
  final double offset;
  RoadPainter(this.offset);

  @override
  void paint(Canvas canvas, Size size) {
    // 🌿 Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF4CAF50),
    );

    // 🛣 Road
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.05, 0, size.width * 0.9, size.height),
      Paint()..color = const Color(0xFF2E2E2E),
    );

    // 🟤 ROAD SHOULDERS
    final shoulderPaint = Paint()..color = const Color(0xFF795548);

    final leftShoulder = Path()
      ..moveTo(size.width * 0.02, 0)
      ..lineTo(size.width * 0.05, 0)
      ..lineTo(size.width * 0.05, size.height)
      ..lineTo(size.width * 0.02, size.height)
      ..close();

    final rightShoulder = Path()
      ..moveTo(size.width * 0.95, 0)
      ..lineTo(size.width * 0.98, 0)
      ..lineTo(size.width * 0.98, size.height)
      ..lineTo(size.width * 0.95, size.height)
      ..close();

    canvas.drawPath(leftShoulder, shoulderPaint);
    canvas.drawPath(rightShoulder, shoulderPaint);

    // ➖ Center Line
    const dashHeight = 30.0;
    const gap = 30.0;
    final step = dashHeight + gap;

    double y = -step + (offset % step);

    final dashPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    while (y < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, y + dashHeight),
        dashPaint,
      );
      y += step;
    }

    // 🌳 Trees
    const treeStep = 70.0;
    double treeY = -treeStep + (offset % treeStep);

    final treePaint = Paint()..color = const Color(0xFF2E7D32);
    final trunkPaint = Paint()..color = const Color(0xFF5D4037);

    while (treeY < size.height) {
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(size.width * -0.05, treeY + 15),
          width: 6,
          height: 20,
        ),
        trunkPaint,
      );
      canvas.drawCircle(Offset(size.width * -0.05, treeY), 18, treePaint);

      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(size.width * 1.05, treeY + 15),
          width: 6,
          height: 20,
        ),
        trunkPaint,
      );
      canvas.drawCircle(Offset(size.width * 1.05, treeY), 18, treePaint);

      treeY += treeStep;
    }
  }

  @override
  bool shouldRepaint(covariant RoadPainter oldDelegate) {
    return oldDelegate.offset != offset;
  }
}

// void main(List<String> args) {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: Size(390, 836),
//       child: MaterialApp(debugShowCheckedModeBanner: false, home: Blender()),
//     );
//   }
// }

// class Blender extends StatefulWidget {
//   Blender({super.key});

//   @override
//   State<Blender> createState() => _BlenderState();
// }

// class _BlenderState extends State<Blender> with SingleTickerProviderStateMixin {
//   late AnimationController controller;
//   Flutter3DController carController = Flutter3DController();

//   Flutter3DController roadController = Flutter3DController();
//   StreamSubscription? _subscription;

//   int viewerKey = 0;
//   Timer? _timer;

//   double carPosition = (ScreenUtil().screenWidth / 2) - 65.w;
//   int carSpeed = 100;

//   int maxSpeed = 1000;
//   int minSpeed = 100;
//   void updateCamera() {
//     setState(() {
//       viewerKey++; // 🔥 forces WebView rebuild
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 1),
//     )..repeat();
//     _subscription = accelerometerEvents.listen((event) async {
//       if (event.x > 2) {
//         rotateLeft();
//         print("Right-----------------");
//       } else if (event.x < -2) {
//         rotateRight();

//         print("Left-----------------");
//       } else {
//         print("Center-----------------");
//         print("fjasjfiojas == $carPosition");

//         await Future.delayed(Duration(milliseconds: 10));
//         carController.setCameraOrbit(0.0, 35, 100);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // updateCamera();
//     return Scaffold(
//       body: Column(
//         children: [
//           Expanded(
//             child: GestureDetector(
//               onTapDown: (_) {
//                 _timer?.cancel(); // stop previous timer

//                 _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
//                   setState(() {
//                     if (carSpeed < maxSpeed) {
//                       carSpeed += 50;
//                     }
//                     print("Speed ↑ = $carSpeed");
//                   });
//                 });
//               },
//               onTapUp: (_) => _startDecelerating(),
//               onTapCancel: _startDecelerating,
//               child: Container(
//                 color: Colors.green,
//                 child: Stack(
//                   children: [
//                     AnimatedBuilder(
//                       animation: controller,
//                       builder: (context, child) {
//                         return Align(
//                           child: Transform.scale(
//                             scale: 1.5,
//                             child: Transform(
//                               alignment: Alignment.center,
//                               transform: Matrix4.identity()
//                                 ..setEntry(3, 2, 0.001)
//                                 ..rotateX(-30 * pi / 180)
//                                 ..rotateY(0.0),
//                               child: SizedBox(
//                                 width: 200,
//                                 height: 700,
//                                 child: CustomPaint(
//                                   painter: RoadPainter(
//                                     controller.value * carSpeed,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),

//                     AnimatedPositioned(
//                       duration: Duration(milliseconds: 500),
//                       // alignment: AlignmentGeometry.bottomCenter,
//                       bottom: 0,
//                       left: carPosition,
//                       child: Container(
//                         height: 130.w,
//                         width: 130.w,
//                         child: Flutter3DViewer(
//                           key: ValueKey(viewerKey),
//                           activeGestureInterceptor: false,
//                           enableTouch: false,
//                           controller: carController,
//                           src: 'assets/lanb.glb',
//                           onProgress: (double progressValue) {
//                             debugPrint(
//                               'model loading progress : $progressValue',
//                             );
//                           },
//                           //This callBack will call after model loaded successfully and will return model address
//                           onLoad: (String modelAddress) {
//                             debugPrint('model loaded : $modelAddress');
//                             carController.setCameraOrbit(0, 25, 100);
//                             carController.setCameraTarget(0.0, 0.9, 0.0);
//                           },
//                           //this callBack will call when model failed to load and will return failure error
//                           onError: (String error) {
//                             debugPrint('model failed to load : $error');
//                           },
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _startDecelerating() {
//     _timer?.cancel();

//     _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
//       setState(() {
//         if (carSpeed > minSpeed) {
//           carSpeed -= 50;
//         } else {
//           _timer?.cancel(); // stop when min reached
//         }
//         print("Speed ↓ = $carSpeed");
//       });
//     });
//   }

//   rotateLeft() {
//     if (carPosition > 0) {
//       setState(() {
//         carPosition -= 1;
//         print("fjasjfiojas == $carPosition");
//       });
//     }

//     carController.setCameraOrbit(-10, 35, 100);
//   }

//   rotateRight() {
//     if (carPosition < ScreenUtil().screenWidth - 130.w) {
//       setState(() {
//         carPosition += 1;
//         print("fjasjfiojas == $carPosition");
//       });
//     }

//     carController.setCameraOrbit(10, 35, 100);
//   }
// }

// class RoadPainter extends CustomPainter {
//   final double offset;

//   RoadPainter(this.offset);

//   @override
//   void paint(Canvas canvas, Size size) {
//     // 🌿 Background
//     final bgPaint = Paint()..color = const Color(0xFF4CAF50);
//     canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

//     // 🛣 ROAD
//     final roadPaint = Paint()..color = const Color(0xFF2E2E2E);
//     canvas.drawRect(
//       Rect.fromLTWH(size.width * 0.05, 0, size.width * 0.9, size.height),
//       roadPaint,
//     );

//     // 🟤 ROAD SHOULDERS
//     final shoulderPaint = Paint()..color = const Color(0xFF795548);

//     final leftShoulder = Path()
//       ..moveTo(size.width * 0.02, 0)
//       ..lineTo(size.width * 0.05, 0)
//       ..lineTo(size.width * 0.05, size.height)
//       ..lineTo(size.width * 0.02, size.height)
//       ..close();

//     final rightShoulder = Path()
//       ..moveTo(size.width * 0.95, 0)
//       ..lineTo(size.width * 0.98, 0)
//       ..lineTo(size.width * 0.98, size.height)
//       ..lineTo(size.width * 0.95, size.height)
//       ..close();

//     canvas.drawPath(leftShoulder, shoulderPaint);
//     canvas.drawPath(rightShoulder, shoulderPaint);

//     // ➖ DASHED CENTER LINE (MOVING)
//     final dashPaint = Paint()
//       ..color = Colors.white
//       ..strokeWidth = 2;

//     const double dashHeight = 30;
//     const double gap = 30;
//     final double step = dashHeight + gap;

//     double y = -step + (offset % step);

//     while (y < size.height) {
//       canvas.drawLine(
//         Offset(size.width / 2, y),
//         Offset(size.width / 2, y + dashHeight),
//         dashPaint,
//       );
//       y += step;
//     }

//     // 🌳 TREES (MOVING)
//     final treePaint = Paint()..color = const Color(0xFF2E7D32);
//     final trunkPaint = Paint()..color = const Color(0xFF5D4037);

//     const double treeStep = 70;
//     double treeY = -treeStep + (offset % treeStep);

//     while (treeY < size.height) {
//       // LEFT
//       canvas.drawRect(
//         Rect.fromCenter(
//           center: Offset(size.width * -0.05, treeY + 15),
//           width: 6,
//           height: 20,
//         ),
//         trunkPaint,
//       );
//       canvas.drawCircle(Offset(size.width * -0.05, treeY), 18, treePaint);

//       // RIGHT
//       canvas.drawRect(
//         Rect.fromCenter(
//           center: Offset(size.width * 1.05, treeY + 15),
//           width: 6,
//           height: 20,
//         ),
//         trunkPaint,
//       );
//       canvas.drawCircle(Offset(size.width * 1.05, treeY), 18, treePaint);

//       treeY += treeStep;
//     }
//   }

//   @override
//   bool shouldRepaint(covariant RoadPainter oldDelegate) {
//     return oldDelegate.offset != offset;
//   }
// }
