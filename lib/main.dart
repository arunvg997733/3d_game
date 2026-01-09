import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: Blender());
  }
}

class Blender extends StatefulWidget {
  Blender({super.key});

  @override
  State<Blender> createState() => _BlenderState();
}

class _BlenderState extends State<Blender> with SingleTickerProviderStateMixin {
  // late AnimationController controller;
  Flutter3DController carController = Flutter3DController();

  Flutter3DController roadController = Flutter3DController();

  int viewerKey = 0;
  Timer? _timer;

  double road = 6;

  void updateCamera() {
    setState(() {
      viewerKey++; // 🔥 forces WebView rebuild
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   controller = AnimationController(
  //     vsync: this,
  //     duration: const Duration(milliseconds: 1000),
  //   )..repeat();
  // }

  // @override
  // void dispose() {
  //   controller.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    // updateCamera();
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.green,
              child: Stack(
                children: [
                  // Align(
                  //   child: Transform.scale(
                  //     scale: 1.5,
                  //     child: Transform(
                  //       alignment: Alignment.center,
                  //       transform: Matrix4.identity()
                  //         ..setEntry(3, 2, 0.001)
                  //         ..rotateX(-10)
                  //         ..rotateY(0.0),

                  //       child: Container(width: 200, color: Colors.black),
                  //     ),
                  //   ),
                  // ),
                  Align(
                    child: Transform.scale(
                      scale: 1.5,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateX(150 * pi / 180)
                          ..rotateY(0.0),
                        child: SizedBox(
                          width: 200,
                          height: 700,
                          child: CustomPaint(
                            painter: RoadPainter(
                              // dashOffset: controller.value * 100,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Align(
                  //   child: SizedBox(
                  //     width: 200,
                  //     height: 700,
                  //     child: CustomPaint(
                  //       painter: RoadPainter(
                  //         // dashOffset: controller.value * 100,
                  //       ),
                  //     ),
                  //   ),
                  // ),

                  // Transform.scale(
                  //   scale: 4,
                  //   child: Flutter3DViewer(
                  //     enableTouch: false,
                  //     key: ValueKey(viewerKey),
                  //     src: 'assets/road.glb',
                  //     controller: roadController,
                  //     activeGestureInterceptor: false,
                  //     onProgress: (double progressValue) {
                  //       debugPrint('model loading progress : $progressValue');
                  //     },
                  //     //This callBack will call after model loaded successfully and will return model address
                  //     onLoad: (String modelAddress) {
                  //       debugPrint('model loaded : $modelAddress');
                  //       // roadController.setScale(5.0);

                  //       roadController.setCameraOrbit(0.0, 50, 5);
                  //       roadController.setCameraTarget(road, -5, 0);
                  //       roadController.playAnimation();
                  //     },
                  //     //this callBack will call when model failed to load and will return failure error
                  //     onError: (String error) {
                  //       debugPrint('model failed to load : $error');
                  //     },
                  //   ),
                  // ),
                  Align(
                    alignment: AlignmentGeometry.bottomCenter,
                    child: Container(
                      height: 150,
                      width: 150,
                      child: Flutter3DViewer(
                        key: ValueKey(viewerKey),
                        activeGestureInterceptor: false,
                        enableTouch: false,
                        controller: carController,
                        src: 'assets/lanb.glb',
                        onProgress: (double progressValue) {
                          debugPrint('model loading progress : $progressValue');
                        },
                        //This callBack will call after model loaded successfully and will return model address
                        onLoad: (String modelAddress) {
                          debugPrint('model loaded : $modelAddress');
                          carController.setCameraOrbit(0, 35, 100);
                          carController.setCameraTarget(0.0, 0.9, 0.0);
                        },
                        //this callBack will call when model failed to load and will return failure error
                        onError: (String error) {
                          debugPrint('model failed to load : $error');
                        },
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentGeometry.bottomCenter,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTapDown: (_) {
                            rotateLeft();
                          },
                          onTapUp: (_) async {
                            _stopAndReset();
                            await Future.delayed(Duration(milliseconds: 10));
                            carController.setCameraOrbit(0.0, 35, 100);
                            carController.setCameraTarget(0.0, 0.9, 0.0);
                          },
                          child: SizedBox(
                            height: 100,
                            width: 100,
                            child: FittedBox(
                              child: Icon(Icons.arrow_left_sharp),
                            ),
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTapDown: (_) {
                            rotateRight();
                          },
                          onTapUp: (_) async {
                            _stopAndReset();
                            await Future.delayed(Duration(milliseconds: 10));
                            carController.setCameraOrbit(0.0, 35, 100);
                            carController.setCameraTarget(0.0, 0.9, 0.0);
                          },

                          child: SizedBox(
                            height: 100,
                            width: 100,
                            child: FittedBox(
                              child: Icon(Icons.arrow_right_sharp),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  rotateLeft() {
    // road = road - 10;
    _startDecreasing();
    carController.setCameraOrbit(-20, 35, 100);
    carController.setCameraTarget(0.0, 0.9, 0.0);
    // roadController.setCameraTarget(road, -5, 0);
  }

  rotateRight() {
    // road = road + 10;
    _startIncreasing();
    carController.setCameraOrbit(20, 35, 100);
    carController.setCameraTarget(0.0, 0.9, 0.0);
    // roadController.setCameraTarget(road, -5, 0);
  }

  void _startIncreasing() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        road += 2;
        roadController.setCameraTarget(road, -5, 0);
        print("fjasjfiojas == $road");
      });
    });
  }

  void _startDecreasing() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        road -= 2;
        roadController.setCameraTarget(road, -5, 0);
        print("fjasjfiojas == $road");
      });
    });
  }

  void _stopAndReset() {
    _timer?.cancel();
    _timer = null;
    // setState(() {
    //   road = 6;
    // });
  }
}

// class Blender extends StatefulWidget {
//   const Blender({super.key});

//   @override
//   State<Blender> createState() => _BlenderState();
// }

// class _BlenderState extends State<Blender> {
//   int viewerKey = 0;

//   void updateCamera() {
//     setState(() {
//       viewerKey++; // 🔥 forces WebView rebuild
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Center(
//             child: ModelViewer(
//               src: 'assets/road.glb',
//               ar: false,
//               backgroundColor: Colors.black,
//               // autoRotate: true,
//               cameraOrbit: "0deg 50deg 0m", // horizontal, vertical, distance
//               cameraTarget: "0m 100m 0m", // focus point
//               fieldOfView: "900deg",
//               minCameraOrbit: "-45deg 60deg 2m",
//               maxCameraOrbit: "45deg 60deg 2m",
//               cameraControls: false,
//             ),
//           ),
//           Center(
//             child: Container(
//               // color: Colors.amber,
//               height: 200,
//               width: 200,
//               child: ModelViewer(
//                 key: ValueKey(viewerKey),
//                 src: 'assets/lanb.glb',
//                 ar: false,
//                 cameraOrbit:
//                     "-10deg 50deg 100m", // horizontal, vertical, distance
//                 // cameraTarget: "0m 0.9m 0m", // focus point
//                 // fieldOfView: "0deg",
//                 // autoRotate: true,
//                 cameraControls: true,
//               ),
//             ),
//           ),

//           Positioned(
//             bottom: 0,
//             child: ElevatedButton(
//               onPressed: () {
//                 updateCamera();
//               },
//               child: Text("left"),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class RoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 🌿 Background
    final bgPaint = Paint()..color = const Color(0xFF4CAF50);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 🛣 ROAD
    final roadPaint = Paint()..color = const Color(0xFF2E2E2E);

    final roadPath = Path()
      ..moveTo(size.width * 0.15, 0) // wide top
      ..lineTo(size.width * 0.85, 0)
      ..lineTo(size.width * 0.85, size.height) // narrow bottom
      ..lineTo(size.width * 0.15, size.height)
      ..close();

    canvas.drawPath(roadPath, roadPaint);

    // 🟤 ROAD SHOULDERS
    final shoulderPaint = Paint()..color = const Color(0xFF795548);

    final leftShoulder = Path()
      ..moveTo(size.width * 0.12, 0)
      ..lineTo(size.width * 0.15, 0)
      ..lineTo(size.width * 0.15, size.height)
      ..lineTo(size.width * 0.12, size.height)
      ..close();

    final rightShoulder = Path()
      ..moveTo(size.width * 0.85, 0)
      ..lineTo(size.width * 0.88, 0)
      ..lineTo(size.width * 0.88, size.height)
      ..lineTo(size.width * 0.85, size.height)
      ..close();

    canvas.drawPath(leftShoulder, shoulderPaint);
    canvas.drawPath(rightShoulder, shoulderPaint);

    // ➖ CENTER DASHED LINE (perspective)
    final dashPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    double y = 0;
    while (y < size.height) {
      final t = y / size.height;
      final dashHeight = lerpDouble(8, 30, t)!;
      final gap = lerpDouble(12, 40, t)!;

      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, y + dashHeight),
        dashPaint,
      );

      y += dashHeight + gap;
    }

    // 🌳 TREES (aligned like image)
    final treePaint = Paint()..color = const Color(0xFF2E7D32);
    final trunkPaint = Paint()..color = const Color(0xFF5D4037);

    for (double y = 40; y < size.height; y += 70) {
      // LEFT
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(size.width * 0.07, y + 15),
          width: 6,
          height: 20,
        ),
        trunkPaint,
      );
      canvas.drawCircle(Offset(size.width * 0.07, y), 18, treePaint);

      // RIGHT
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(size.width * 0.93, y + 15),
          width: 6,
          height: 20,
        ),
        trunkPaint,
      );
      canvas.drawCircle(Offset(size.width * 0.93, y), 18, treePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// class RoadPainter extends CustomPainter {
//   final Random _rand = Random(1);

//   @override
//   void paint(Canvas canvas, Size size) {
//     // 🌿 SKY / DISTANT FOG
//     final skyPaint = Paint()
//       ..shader = LinearGradient(
//         begin: Alignment.topCenter,
//         end: Alignment.bottomCenter,
//         colors: [Colors.lightBlue.shade200, Colors.green.shade700],
//       ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.4));

//     canvas.drawRect(
//       Rect.fromLTWH(0, 0, size.width, size.height),
//       Paint()..color = Colors.green.shade900,
//     );

//     canvas.drawRect(
//       Rect.fromLTWH(0, 0, size.width, size.height * 0.4),
//       skyPaint,
//     );

//     // 🌱 GRASS DEPTH (layers)
//     for (int i = 0; i < 5; i++) {
//       final grassPaint = Paint()
//         ..color = Colors.green.shade800.withOpacity(0.2);
//       canvas.drawRect(
//         Rect.fromLTWH(0, size.height * 0.3 + i * 30, size.width, size.height),
//         grassPaint,
//       );
//     }

//     // 🛣️ ROAD with depth gradient
//     final roadPaint = Paint()
//       ..shader = LinearGradient(
//         begin: Alignment.topCenter,
//         end: Alignment.bottomCenter,
//         colors: [Colors.grey.shade700, Colors.grey.shade900],
//       ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

//     final roadPath = Path()
//       ..moveTo(size.width * 0.45, size.height * 0.35)
//       ..lineTo(size.width * 0.55, size.height * 0.35)
//       ..lineTo(size.width * 0.8, size.height)
//       ..lineTo(size.width * 0.2, size.height)
//       ..close();

//     canvas.drawPath(roadPath, roadPaint);

//     // 🛣️ ROAD EDGES (shoulder)
//     final shoulderPaint = Paint()
//       ..color = Colors.brown.shade700
//       ..strokeWidth = 8
//       ..style = PaintingStyle.stroke;

//     canvas.drawPath(roadPath, shoulderPaint);

//     // ➖ CENTER LINE (perspective scaled)
//     final dashPaint = Paint()
//       ..color = Colors.white.withOpacity(0.9)
//       ..strokeWidth = 2;

//     double y = size.height * 0.4;
//     while (y < size.height) {
//       final t = (y - size.height * 0.4) / size.height;
//       final dashLength = lerpDouble(6, 40, t)!;
//       final gap = lerpDouble(6, 40, t)!;

//       canvas.drawLine(
//         Offset(size.width / 2, y),
//         Offset(size.width / 2, y + dashLength),
//         dashPaint,
//       );
//       y += dashLength + gap;
//     }

//     // 🌲 TREES (trunks + canopy with randomness)
//     for (int i = 0; i < 40; i++) {
//       final yPos = size.height * 0.35 + _rand.nextDouble() * size.height * 0.65;
//       final scale = lerpDouble(0.3, 1.2, yPos / size.height)!;

//       // Left trees
//       _drawTree(canvas, Offset(size.width * 0.15 * scale, yPos), scale);

//       // Right trees
//       _drawTree(
//         canvas,
//         Offset(size.width - size.width * 0.15 * scale, yPos),
//         scale,
//       );
//     }
//   }

//   void _drawTree(Canvas canvas, Offset pos, double scale) {
//     final trunkPaint = Paint()..color = Colors.brown.shade800;
//     final leafPaint = Paint()..color = Colors.green.shade800;

//     // Trunk
//     canvas.drawRect(
//       Rect.fromCenter(center: pos, width: 6 * scale, height: 25 * scale),
//       trunkPaint,
//     );

//     // Canopy
//     canvas.drawCircle(
//       Offset(pos.dx, pos.dy - 20 * scale),
//       18 * scale,
//       leafPaint,
//     );
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// class RoadPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final roadPaint = Paint()
//       ..shader = LinearGradient(
//         begin: Alignment.topCenter,
//         end: Alignment.bottomCenter,
//         colors: [Colors.grey.shade800, Colors.grey.shade900],
//       ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

//     // Road shape
//     final roadPath = Path()
//       ..moveTo(0, 0)
//       ..lineTo(size.width, 0)
//       ..lineTo(size.width * 0.9, size.height)
//       ..lineTo(size.width * 0.1, size.height)
//       ..close();

//     canvas.drawPath(roadPath, roadPaint);

//     // Side borders
//     final borderPaint = Paint()
//       ..color = Colors.grey.shade700
//       ..strokeWidth = 3
//       ..style = PaintingStyle.stroke;

//     canvas.drawPath(roadPath, borderPaint);

//     // Center dashed line
//     final dashPaint = Paint()
//       ..color = Colors.white
//       ..strokeWidth = 2;

//     const dashHeight = 50;
//     const dashSpace = 50;

//     double startY = 10;
//     while (startY < size.height) {
//       canvas.drawLine(
//         Offset(size.width / 2, startY),
//         Offset(size.width / 2, startY + dashHeight),
//         dashPaint,
//       );
//       startY += dashHeight + dashSpace;
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

class RoadPainter1 extends CustomPainter {
  final double dashOffset;

  RoadPainter1({required this.dashOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey.shade800, Colors.grey.shade900],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Road shape
    final roadPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width * 0.9, size.height)
      ..lineTo(size.width * 0.1, size.height)
      ..close();

    canvas.drawPath(roadPath, roadPaint);

    // Borders
    canvas.drawPath(
      roadPath,
      Paint()
        ..color = Colors.grey.shade700
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );

    // Center dashed line (MOVING)
    final dashPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    const dashHeight = 50.0;
    const dashSpace = 50.0;
    final totalDash = dashHeight + dashSpace;

    double startY = -totalDash + dashOffset;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        dashPaint,
      );
      startY += totalDash;
    }
  }

  @override
  bool shouldRepaint(covariant RoadPainter1 oldDelegate) {
    return oldDelegate.dashOffset != dashOffset;
  }
}
