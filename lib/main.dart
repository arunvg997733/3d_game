import 'dart:ui';

import 'package:blendertest/controller/game_controller.dart';
import 'package:blendertest/view/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 836),
      builder: (_, __) {
        return MultiProvider(
          providers: [ChangeNotifierProvider(create: (_) => GameController())],
          child: const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Blender(),
          ),
        );
      },
    );
  }
}
