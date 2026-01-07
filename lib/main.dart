import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:flutter/material.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Blender());
  }
}

class Blender extends StatelessWidget {
  Blender({super.key});

  Flutter3DController carController = Flutter3DController();
  Flutter3DController roadController = Flutter3DController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Transform.scale(
                  scale: 1,
                  child: Flutter3DViewer(
                    src: 'assets/road.glb',
                    controller: roadController,
                    onProgress: (double progressValue) {
                      debugPrint('model loading progress : $progressValue');
                    },
                    //This callBack will call after model loaded successfully and will return model address
                    onLoad: (String modelAddress) {
                      debugPrint('model loaded : $modelAddress');
                      // roadController.setScale(5.0);

                      roadController.setCameraOrbit(0.0, 40, 20.0);
                      roadController.setCameraTarget(5, 20, 5);
                    },
                    //this callBack will call when model failed to load and will return failure error
                    onError: (String error) {
                      debugPrint('model failed to load : $error');
                    },
                  ),
                ),
                Align(
                  alignment: AlignmentGeometry.bottomCenter,
                  child: Container(
                    height: 200,
                    width: 200,
                    child: Flutter3DViewer(
                      controller: carController,
                      src: 'assets/lanb.glb',
                      onProgress: (double progressValue) {
                        debugPrint('model loading progress : $progressValue');
                      },
                      //This callBack will call after model loaded successfully and will return model address
                      onLoad: (String modelAddress) {
                        debugPrint('model loaded : $modelAddress');
                        carController.setCameraOrbit(0, 40, 100);
                        carController.setCameraTarget(0.0, 0.9, 0.0);
                      },
                      //this callBack will call when model failed to load and will return failure error
                      onError: (String error) {
                        debugPrint('model failed to load : $error');
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTapDown: (_) {
                  carController.setCameraOrbit(-20, 40, 100);
                  carController.setCameraTarget(0.0, 0.9, 0.0);
                },
                onTapUp: (_) async {
                  await Future.delayed(Duration(milliseconds: 20));
                  carController.setCameraOrbit(0.0, 40, 100);
                  carController.setCameraTarget(0.0, 0.9, 0.0);
                },
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: FittedBox(child: Icon(Icons.arrow_left_sharp)),
                ),
              ),
              Spacer(),
              GestureDetector(
                onTapDown: (_) {
                  carController.setCameraOrbit(20, 40, 100);
                  carController.setCameraTarget(0.0, 0.9, 0.0);
                },
                onTapUp: (_) async {
                  print("jdasjidjsaod---");
                  await Future.delayed(Duration(milliseconds: 20));
                  carController.setCameraOrbit(0.0, 40, 100);
                  carController.setCameraTarget(0.0, 0.9, 0.0);
                },

                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: FittedBox(child: Icon(Icons.arrow_right_sharp)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
